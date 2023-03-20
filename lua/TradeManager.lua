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

if not EHI:GetOption("show_trade_delay") then
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

local TrackerID = "CustodyTime"

local function OnPlayerCriminalDeath(peer_id, respawn_penalty)
    if suppress_in_stealth and managers.groupai:state():whisper_mode() then
        managers.ehi:AddToTradeDelayCache(peer_id, respawn_penalty, true)
        return
    end
    local tracker = managers.ehi:GetTracker(TrackerID)
    if tracker and not tracker:PeerExists(peer_id) then
        tracker:AddPeerCustodyTime(peer_id, respawn_penalty)
    else
        managers.ehi:AddCustodyTimeTrackerWithPeer(peer_id, respawn_penalty)
    end
end

local function CreateTracker(peer_id, respawn_penalty)
    if respawn_penalty == tweak_data.player.damage.base_respawn_time_penalty then
        return
    end
    if show_trade_for_other_players and peer_id == managers.network:session():local_peer():id() then
        return
    end
    OnPlayerCriminalDeath(peer_id, respawn_penalty)
end

local function SetTrackerPause(character_name, t)
    managers.ehi:SetTrade("ai", character_name ~= nil, t)
end

function TradeManager:init(...)
    original.init(self, ...)
    EHI:Hook(self, "set_trade_countdown", function(s, enabled)
        managers.ehi:SetTrade("normal", enabled, self._trade_counter_tick)
    end)
    local function alarm(dropin)
        managers.ehi:LoadFromTradeDelayCache()
        if not dropin then
            managers.ehi:SetTrade("normal", true, self:GetTradeCounterTick())
        end
    end
    EHI:AddOnAlarmCallback(alarm)
    local function f(peer, peer_id, reason)
        managers.ehi:CallFunction(TrackerID, "RemovePeerFromCustody", peer_id)
    end
    Hooks:Add("BaseNetworkSessionOnPeerRemoved", "BaseNetworkSessionOnPeerRemoved_EHI", f)
end

function TradeManager:pause_trade(time, ...)
    original.pause_trade(self, time, ...)
    managers.ehi:CallFunction(TrackerID, "SetTradePause", time)
end

function TradeManager:GetTradeCounterTick()
    return self._trade_counter_tick
end

function TradeManager:on_player_criminal_death(criminal_name, respawn_penalty, ...)
    local crim = original.on_player_criminal_death(self, criminal_name, respawn_penalty, ...)
    if crim and type(crim) == "table" then -- Apparently OVK sometimes send empty criminal, not sure why; Probably mods
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
            CreateTracker(peer_id, respawn_penalty)
        elseif respawn_penalty ~= tweak_data.player.damage.base_respawn_time_penalty then
            if suppress_in_stealth and managers.groupai:state():whisper_mode() then
                if managers.ehi:CachedPeerInCustodyExists(peer_id) then
                    managers.ehi:SetCachedPeerCustodyTime(peer_id, respawn_penalty)
                else
                    managers.ehi:AddToTradeDelayCache(peer_id, respawn_penalty)
                end
                managers.ehi:SetCachedPeerInCustody(peer_id)
                return
            end
            local tracker = managers.ehi:GetTracker(TrackerID)
            if tracker then
                if tracker:PeerExists(peer_id) then
                    tracker:UpdatePeerCustodyTime(peer_id, respawn_penalty)
                else
                    tracker:AddPeerCustodyTime(peer_id, respawn_penalty)
                end
            end
        end
        managers.ehi:CallFunction(TrackerID, "SetPeerInCustody", peer_id)
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