---@class EHITradeManager
EHITradeManager = {}
---@param ehi_tracker EHITrackerManager
---@return EHITradeManager
function EHITradeManager:new(ehi_tracker)
    self._trackers = ehi_tracker
    self._trade = {
        ai = false,
        normal = false
    }
    self._trade_delay = {}
    return self
end

---@param type string
---@param pause boolean
---@param t number
function EHITradeManager:SetTrade(type, pause, t)
    self._trade[type] = pause
    local f = type == "normal" and "SetTrade" or "SetAITrade"
    self:CallFunction(f, pause, t)
end

function EHITradeManager:AddCustodyTimeTracker()
    self._trackers:AddTracker({
        id = "CustodyTime",
        class = "EHITradeDelayTracker"
    })
end

---@param peer_id number
---@param time number
---@param civilians_killed number?
function EHITradeManager:AddCustodyTimeTrackerWithPeer(peer_id, time, civilians_killed)
    self:AddCustodyTimeTracker()
    self:AddPeerCustodyTime(peer_id, time, civilians_killed)
    if self._trade.normal or self._trade.ai then
        local f = self._trade.normal and "SetTrade" or "SetAITrade"
        self:CallFunction(f, true, managers.trade:GetTradeCounterTick(), true)
    end
end

---@param peer_id number
---@param respawn_time_penalty number
---@param civilians_killed number?
function EHITradeManager:AddPeerCustodyTime(peer_id, respawn_time_penalty, civilians_killed)
    self:CallFunction("AddPeerCustodyTime", peer_id, respawn_time_penalty, civilians_killed)
end

---@param peer_id number
---@param respawn_penalty number
---@param civilians_killed number
function EHITradeManager:AddOrUpdateCachedPeer(peer_id, respawn_penalty, civilians_killed)
    if self:CachedPeerInCustodyExists(peer_id) then
        self:SetCachedPeerCustodyTime(peer_id, respawn_penalty, civilians_killed)
    else
        self:AddToTradeDelayCache(peer_id, respawn_penalty, civilians_killed)
    end
end

---@param peer_id number
---@param delay number
---@param tweak_respawn_penalty number
function EHITradeManager:AddOrIncreaseCachedPeerCustodyTime(peer_id, delay, tweak_respawn_penalty)
    if self:CachedPeerInCustodyExists(peer_id) then
        self:IncreaseCachedPeerCustodyTime(peer_id, tweak_respawn_penalty)
    else
        self:AddToTradeDelayCache(peer_id, delay)
    end
end

---@param peer_id number
---@param respawn_penalty number
---@param civilians_killed number?
---@param in_custody boolean?
function EHITradeManager:AddToTradeDelayCache(peer_id, respawn_penalty, civilians_killed, in_custody)
    if self._trade_processed_after_alarm then
        self:PostPeerCustodyTime(peer_id, respawn_penalty, civilians_killed, in_custody)
        return
    end
    self._trade_delay[peer_id] =
    {
        respawn_t = respawn_penalty,
        in_custody = in_custody,
        civilians_killed = civilians_killed or 1
    }
end

---@param peer_id number
function EHITradeManager:SetCachedPeerInCustody(peer_id)
    if not self._trade_delay[peer_id] then
        return
    end
    if self._trade_processed_after_alarm then
        local data = self._trade_delay[peer_id]
        self:PostPeerCustodyTime(peer_id, data.respawn_t, data.civilians_killed, true)
        return
    end
    self._trade_delay[peer_id].in_custody = true
end

---@param peer_id number
---@param time number
function EHITradeManager:IncreaseCachedPeerCustodyTime(peer_id, time)
    if not self._trade_delay[peer_id] then
        return
    end
    local data = self._trade_delay[peer_id]
    local respawn_t = data.respawn_t
    local new_t = respawn_t + time
    if self._trade_processed_after_alarm then
        self:PostPeerCustodyTime(peer_id, new_t, 1)
        return
    end
    data.respawn_t = new_t
    data.civilians_killed = data.civilians_killed + 1
end

---@param peer_id number
---@param time number
---@param civilians_killed number
function EHITradeManager:SetCachedPeerCustodyTime(peer_id, time, civilians_killed)
    if not self._trade_delay[peer_id] then
        return
    end
    if self._trade_processed_after_alarm then
        self:PostPeerCustodyTime(peer_id, time, civilians_killed)
        return
    end
    self._trade_delay[peer_id].respawn_t = time
    self._trade_delay[peer_id].civilians_killed = civilians_killed or 1
end

---@param peer_id number
function EHITradeManager:CachedPeerInCustodyExists(peer_id)
    return self._trade_delay[peer_id] ~= nil
end

function EHITradeManager:LoadFromTradeDelayCache()
    if next(self._trade_delay) then
        -- The tracker may get created the frame before, only create it when the tracker does not exist
        if self._trackers:TrackerDoesNotExist("CustodyTime") then
            self:AddCustodyTimeTracker()
        end
        for peer_id, crim in pairs(self._trade_delay) do
            self:CallFunction("AddOrUpdatePeerCustodyTime", peer_id, crim.respawn_t, crim.civilians_killed, crim.in_custody)
        end
        self._trade_delay = {}
    end
    self._trade_processed_after_alarm = true
end

---@param peer_id number
---@param time number
---@param civilians_killed number?
---@param in_custody boolean?
function EHITradeManager:PostPeerCustodyTime(peer_id, time, civilians_killed, in_custody) -- In case the civilian is killed at the same time when alarm went off
    local tracker = self:GetTracker()
    if tracker then
        if tracker:PeerExists(peer_id) then
            tracker:IncreasePeerCustodyTime(peer_id, time)
        else
            tracker:AddPeerCustodyTime(peer_id, time, civilians_killed)
        end
        if in_custody then
            tracker:SetPeerInCustody(peer_id)
        end
    else
        self:AddCustodyTimeTracker()
        self:AddPeerCustodyTime(peer_id, time, civilians_killed)
        if in_custody then
            self:CallFunction("SetPeerInCustody", peer_id)
        end
    end
end

---@return EHITradeDelayTracker?
function EHITradeManager:GetTracker()
    return self._trackers:GetTracker("CustodyTime") --[[@as EHITradeDelayTracker]]
end

---@param f string
---@param ... any
function EHITradeManager:CallFunction(f, ...)
    self._trackers:CallFunction("CustodyTime", f, ...)
end