local EHI = EHI
if EHI:CheckLoadHook("CivilianDamage") then
    return
end

local original = {}

if EHI:GetOption("show_escape_chance") then
    original._unregister_from_enemy_manager = CivilianDamage._unregister_from_enemy_manager
    function CivilianDamage:_unregister_from_enemy_manager(damage_info, ...)
        original._unregister_from_enemy_manager(self, damage_info, ...)
        if not tweak_data.character[self._unit:base()._tweak_table].no_civ_penalty then
            managers.ehi:IncreaseCivilianKilled()
        end
    end
end

if not EHI:GetOption("show_trade_delay") or EHI:GetOption("show_trade_delay_option") == 2 then
    return
end

local other_players_only = EHI:GetOption("show_trade_delay_other_players_only")
local suppress_in_stealth = EHI:GetOption("show_trade_delay_suppress_in_stealth")

local function AddTracker(peer_id)
    if other_players_only and peer_id == managers.network:session():local_peer():id() then
        return
    end
    local tweak_data = tweak_data.player.damage
    local delay = tweak_data.base_respawn_time_penalty + tweak_data.respawn_time_penalty
    if suppress_in_stealth and managers.groupai:state():whisper_mode() then
        if managers.ehi:CachedPeerInCustodyExists(peer_id) then
            managers.ehi:IncreaseCachedPeerCustodyTime(peer_id, tweak_data.respawn_time_penalty)
        else
            managers.ehi:AddToTradeDelayCache(peer_id, delay)
        end
        return
    end
    local tracker = managers.ehi:GetTracker("CustodyTime")
    if tracker then
        if tracker:PeerExists(peer_id) then
            tracker:IncreasePeerCustodyTime(peer_id, tweak_data.respawn_time_penalty)
        else
            tracker:AddPeerCustodyTime(peer_id, delay)
        end
    else
        managers.ehi:AddCustodyTimeTrackerWithPeer(peer_id, delay)
    end
end

original._f_on_damage_received = CivilianDamage._on_damage_received
function CivilianDamage:_on_damage_received(damage_info, ...)
    original._f_on_damage_received(self, damage_info, ...)
    local attacker_unit = damage_info and damage_info.attacker_unit
    if damage_info.result.type == "death" and attacker_unit and not tweak_data.character[self._unit:base()._tweak_table].no_civ_penalty then
        local peer_id = managers.criminals:character_peer_id_by_unit(attacker_unit)
        if peer_id then
            AddTracker(peer_id)
        end
    end
end

function CopDamage:_on_car_damage_received(attacker_unit)
end

function CivilianDamage:_on_car_damage_received(attacker_unit)
    if attacker_unit then
        local peer_id = managers.criminals:character_peer_id_by_unit(attacker_unit)
        if peer_id and not tweak_data.character[self._unit:base()._tweak_table].no_civ_penalty then
            AddTracker(peer_id)
        end
    end
end