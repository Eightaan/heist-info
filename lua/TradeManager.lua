local EHI = EHI
if EHI:CheckLoadHook("TradeManager") then
    return
end

if EHI:IsXPTrackerVisible() then
    if BB and BB.grace_period and Global.game_settings.single_player and Global.game_settings.team_ai then
        EHI:HookWithID(TradeManager, "on_AI_criminal_death", "EHI_ExperienceManager_AICriminalDeath", function(...)
            managers.experience:DecreaseAlivePlayers()
        end)
    elseif not Global.game_settings.single_player then
        EHI:HookWithID(TradeManager, "on_player_criminal_death", "EHI_ExperienceManager_PlayerCriminalDeath", function(...)
            managers.experience:DecreaseAlivePlayers(true)
        end)
    end
end

if EHI:IsTradeTrackerDisabled() then
    return
end

dofile(EHI.LuaPath .. "trackers/EHITradeDelayTracker.lua")
local show_trade_for_other_players = EHI:GetOption("show_trade_delay_other_players_only")
local on_death_show = EHI:GetOption("show_trade_delay_option") == 2
local suppress_in_stealth = EHI:GetOption("show_trade_delay_suppress_in_stealth")

local original =
{
    init = TradeManager.init,
    pause_trade = TradeManager.pause_trade,
    on_player_criminal_death = TradeManager.on_player_criminal_death,
    _set_auto_assault_ai_trade = TradeManager._set_auto_assault_ai_trade,
    sync_set_auto_assault_ai_trade = TradeManager.sync_set_auto_assault_ai_trade
}

local function OnPlayerCriminalDeath(peer_id, respawn_penalty, civilians_killed)
    if suppress_in_stealth and managers.groupai:state():whisper_mode() then
        managers.ehi_trade:AddToTradeDelayCache(peer_id, respawn_penalty, civilians_killed, true)
        return
    end
    local tracker = managers.ehi_trade:GetTracker()
    if tracker and not tracker:PeerExists(peer_id) then
        tracker:AddPeerCustodyTime(peer_id, respawn_penalty, civilians_killed)
    else
        managers.ehi_trade:AddCustodyTimeTrackerWithPeer(peer_id, respawn_penalty, civilians_killed)
    end
end

local function CreateTracker(peer_id, respawn_penalty, civilians_killed)
    if respawn_penalty == tweak_data.player.damage.base_respawn_time_penalty then
        return
    end
    if show_trade_for_other_players and peer_id == managers.network:session():local_peer():id() then
        return
    end
    OnPlayerCriminalDeath(peer_id, respawn_penalty, civilians_killed)
end

local function SetTrackerPause(character_name, t)
    managers.ehi_trade:SetTrade("ai", character_name ~= nil, t)
end

function TradeManager:init(...)
    original.init(self, ...)
    EHI:Hook(self, "set_trade_countdown", function(s, enabled)
        managers.ehi_trade:SetTrade("normal", enabled, self._trade_counter_tick)
        if not enabled then
            for _, crim in ipairs(self._criminals_to_respawn) do
                if crim.peer_id and crim.respawn_penalty and (crim.hostages_killed and crim.hostages_killed > 0) then
                    managers.ehi_trade:CallFunction("AddOrUpdatePeerCustodyTime", crim.peer_id, crim.respawn_penalty, crim.hostages_killed, true)
                end
            end
        end
    end)
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_trade:LoadFromTradeDelayCache()
        if not dropin then
            managers.ehi_trade:SetTrade("normal", true, self:GetTradeCounterTick())
        end
    end)
    Hooks:Add("BaseNetworkSessionOnPeerRemoved", "BaseNetworkSessionOnPeerRemoved_EHI", function(peer, peer_id, reason)
        managers.ehi_trade:CallFunction("RemovePeerFromCustody", peer_id)
    end)
end

function TradeManager:pause_trade(time, ...)
    original.pause_trade(self, time, ...)
    managers.ehi_trade:CallFunction("SetTradePause", time)
end

function TradeManager:GetTradeCounterTick()
    return self._trade_counter_tick
end

function TradeManager:on_player_criminal_death(criminal_name, respawn_penalty, hostages_killed, ...)
    local crim = original.on_player_criminal_death(self, criminal_name, respawn_penalty, hostages_killed, ...)
    if type(crim) == "table" then -- A nil criminal can be returned (because it is already in custody); Shouldn't happen again, probably mods
        local peer_id = crim.peer_id
        if not peer_id then
            for _, peer in pairs(managers.network:session():peers()) do
                if peer:character() == criminal_name then
                    peer_id = peer:id()
                    break
                end
            end
            if not peer_id then -- If peer_id is still nil, return the value and GTFO
                return crim
            end
        end
        if on_death_show then
            CreateTracker(peer_id, respawn_penalty, hostages_killed)
        elseif respawn_penalty ~= tweak_data.player.damage.base_respawn_time_penalty then
            if suppress_in_stealth and managers.groupai:state():whisper_mode() then
                managers.ehi_trade:AddOrUpdateCachedPeer(peer_id, respawn_penalty, hostages_killed)
                managers.ehi_trade:SetCachedPeerInCustody(peer_id)
                return
            end
            local tracker = managers.ehi_trade:GetTracker()
            if tracker then
                if tracker:PeerExists(peer_id) then
                    tracker:UpdatePeerCustodyTime(peer_id, respawn_penalty, hostages_killed)
                else
                    tracker:AddPeerCustodyTime(peer_id, respawn_penalty, hostages_killed)
                end
            end
        end
        managers.ehi_trade:CallFunction("SetPeerInCustody", peer_id)
    end
    return crim
end

function TradeManager:_set_auto_assault_ai_trade(character_name, ...)
    if self._auto_assault_ai_trade_criminal_name ~= character_name then
        SetTrackerPause(character_name, self._trade_counter_tick)
	end
    original._set_auto_assault_ai_trade(self, character_name, ...)
end

function TradeManager:sync_set_auto_assault_ai_trade(character_name, ...)
    original.sync_set_auto_assault_ai_trade(self, character_name, ...)
    SetTrackerPause(character_name, self._trade_counter_tick)
end