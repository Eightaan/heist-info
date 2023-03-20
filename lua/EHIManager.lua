local EHI = EHI
EHIManager = class()
EHIManager.GetAchievementIcon = EHI.GetAchievementIconString
function EHIManager:init()
    self:CreateWorkspace()
    self._t = 0
    self._trackers = {}
    setmetatable(self._trackers, {__mode = "k"})
    self._stealth_trackers = { pagers = {}, lasers = {} }
    self._pager_trackers = {}
    self._laser_trackers = {}
    self._trackers_to_update = {}
    setmetatable(self._trackers_to_update, {__mode = "k"})
    self._trackers_pos = {}
    setmetatable(self._trackers_pos, {__mode = "k"})
    self._trade = {
        ai = false,
        normal = false
    }
    self._n_of_trackers = 0
    self._cache = { _deployables = {}, TradeDelay = {} }
    local x, y = managers.gui_data:safe_to_full(EHI:GetOption("x_offset"), EHI:GetOption("y_offset"))
    self._x = x
    self._y = y
    self._level_started_from_beginning = true
    self._delay_popups = true
    self._panel_size = 32 * self._scale
    self._panel_offset = 6 * self._scale
end

function EHIManager:CreateWorkspace()
    self._ws = managers.gui_data:create_fullscreen_workspace()
    self._ws:hide()
    self._scale = EHI:GetOption("scale")
    self._hud_panel = self._ws:panel():panel({
        name = "ehi_panel",
        layer = -10
    })
end

function EHIManager:init_finalize()
    managers.network:add_event_listener("EHIDropIn", "on_set_dropin", callback(self, self, "DisableStartFromBeginning"))
    EHI:AddOnAlarmCallback(callback(self, self, "SwitchToLoudMode"))
    EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(self, self, "Spawned"))
end

function EHIManager:Spawned()
    self._delay_popups = false
end

function EHIManager:ShowPanel()
    self._ws:show()
end

function EHIManager:HidePanel()
    self._ws:hide()
end

function EHIManager:LoadTime(t)
    self._t = t
end

function EHIManager:IsMissionElementEnabled(id)
    local element = managers.mission:get_element_by_id(id)
    if not element then
        return false
    end
    return element:enabled()
end

function EHIManager:IsMissionElementDisabled(id)
    return not self:IsMissionElementEnabled(id)
end

function EHIManager:InteractionExists(tweak_data)
    local interactions = managers.interaction._interactive_units or {}
    for _, unit in ipairs(interactions) do
        if unit:interaction().tweak_data == tweak_data then
            return true
        end
    end
    return false
end

function EHIManager:CountInteractionAvailable(tweak_data)
    local interactions = managers.interaction._interactive_units or {}
    local count = 0
    for _, unit in pairs(interactions) do
        if unit:interaction().tweak_data == tweak_data then
            count = count + 1
        end
    end
    return count
end

function EHIManager:CountLootbagsOnTheGround()
    local excluded = { value_multiplier = true, dye = true, types = true, small_loot = true }
    local lootbags = {}
    for key, data in pairs(tweak_data.carry) do
        if not (excluded[key] or data.is_unique_loot or data.skip_exit_secure) then
            lootbags[key] = true
        end
    end
    local interactions = managers.interaction._interactive_units or {}
    local count = 0
    for _, unit in pairs(interactions) do
        if unit:carry_data() and lootbags[unit:carry_data():carry_id()] then
            count = count + 1
        end
    end
    return count
end

function EHIManager:CountSpecificLootVisible(carry_id)
    local interactions = managers.interaction._interactive_units or {}
    local count = 0
    for _, unit in pairs(interactions) do
        if unit:carry_data() and unit:carry_data():carry_id() == carry_id then
            count = count + 1
        end
    end
    EHI:Log("Found: " .. tostring(count))
    return count
end

function EHIManager:CountUnitAvailable(path, slotmask)
    return #self:GetUnits(path, slotmask)
end

function EHIManager:GetUnits(path, slotmask)
    local tbl = {}
    local tbl_i = 1
    local idstring = Idstring(path)
    local units = World:find_units_quick("all", slotmask)
    for _, unit in pairs(units) do
        if unit and unit:name() == idstring then
            tbl[tbl_i] = unit
            tbl_i = tbl_i + 1
        end
    end
    return tbl
end

function EHIManager:GetUnit(path, slotmask, pos)
    return self:GetUnits(path, slotmask)[pos or 1]
end

function EHIManager:CountLootbagsAvailable(path, loot_type, slotmask)
    slotmask = slotmask or 14
    local count = 0
    local idstring = Idstring(path)
    local units = World:find_units_quick("all", slotmask)
    for _, unit in pairs(units) do
        if unit and unit:name() == idstring and unit:carry_data() and unit:carry_data():carry_id() == loot_type then
            count = count + 1
        end
    end
    return count
end

function EHIManager:LoadSync()
    if self._level_started_from_beginning then
        for _, f in ipairs(self._full_sync or {}) do
            f(self)
        end
    else
        for _, f in ipairs(self._load_sync or {}) do
            f(self)
        end
        EHI:DelayCall("EHI_Converts_UpdatePeerColors", 2, function()
            managers.ehi:CallFunction("Converts", "UpdatePeerColors")
        end)
    end
    -- Clear used memory
    self._full_sync = nil
    self._load_sync = nil
end

function EHIManager:AddLoadSyncFunction(f)
    self._load_sync = self._load_sync or {}
    self._load_sync[#self._load_sync + 1] = f
end

function EHIManager:AddFullSyncFunction(f)
    self._full_sync = self._full_sync or {}
    self._full_sync[#self._full_sync + 1] = f
end

function EHIManager:DisableStartFromBeginning()
    self._level_started_from_beginning = false
end

function EHIManager:GetStartedFromBeginning()
    return self._level_started_from_beginning
end

function EHIManager:GetDropin()
    return not self:GetStartedFromBeginning()
end

function EHIManager:update(t, dt)
    for _, tracker in pairs(self._trackers_to_update) do
        tracker:update(t, dt)
    end
end

function EHIManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(t, dt)
end

function EHIManager:destroy()
    for _, tracker in pairs(self._trackers) do
        tracker:destroy(true)
    end
    if self._ws and alive(self._ws) then
        managers.gui_data:destroy_workspace(self._ws)
        self._ws = nil
    end
end

function EHIManager:AddTracker(params, pos)
    if self._trackers[params.id] then
        EHI:Log("Tracker with ID '" .. tostring(params.id) .. "' exists!")
        EHI:LogTraceback()
        self._trackers[params.id]:ForceDelete()
    end
    pos = self:MoveTracker(pos, params.icons)
    params.parent_class = self
    params.x = self:GetX(pos)
    params.y = self:GetY(pos)
    params.dynamic = true
    local class = params.class or "EHITracker"
    local tracker = _G[class]:new(self._hud_panel, params)
    if tracker._update then
        self._trackers_to_update[params.id] = tracker
    end
    self._trackers[params.id] = tracker
    self._trackers_pos[params.id] = { tracker = tracker, pos = pos or self._n_of_trackers, x = params.x, y = params.y, w = tracker:GetPanelW() }
    self._n_of_trackers = self._n_of_trackers + 1
end

function EHIManager:PreloadTracker(params)
    if self._trackers[params.id] then
        EHI:Log("Tracker with ID '" .. tostring(params.id) .. "' exists!")
        EHI:LogTraceback()
        self._trackers[params.id]:ForceDelete()
    end
    params.parent_class = self
    params.x = 0
    params.y = 0
    local class = params.class or "EHITracker"
    local tracker = _G[class]:new(self._hud_panel, params)
    self._trackers[params.id] = tracker
end

function EHIManager:RunTracker(id, params)
    local tracker = self._trackers[id]
    if not tracker then
        EHI:Log("Preloaded tracker with ID '" .. tostring(id) .. "' not found!")
        return
    end
    tracker:Run(params)
    if self._trackers_pos[id] then
        return
    end
    local x = self:GetX()
    local y = self:GetY()
    tracker:PosAndSetVisible(x, y)
    self._trackers_pos[id] = { tracker = tracker, pos = self._n_of_trackers, x = x, y = y, w = tracker:GetPanelW() }
    if tracker._update then
        self:AddTrackerToUpdate(id, tracker)
    end
    self._n_of_trackers = self._n_of_trackers + 1
end

-- Called by host only. Clients with EHI call EHIManager:AddTracker() when synced
function EHIManager:AddTrackerAndSync(params, id, delay)
    self:AddTracker(params)
    self:Sync(id, delay)
end

function EHIManager:Sync(id, delay)
    EHI:Sync(EHI.SyncMessages.EHISyncAddTracker, LuaNetworking:TableToString({ id = id, delay = delay or 0 }))
end

if Global.game_settings and Global.game_settings.single_player then
    EHIManager.Sync = function(...) end
end

function EHIManager:AddPagerTracker(id)
    self._stealth_trackers.pagers[id] = true
    local params =
    {
        id = id,
        class = "EHIPagerTracker"
    }
    self:AddTracker(params)
end

function EHIManager:AddLaserTracker(params)
    for id, _ in pairs(self._stealth_trackers.lasers) do
        -- Don't add this tracker if the "next_cycle_t" is the same as time to prevent duplication
        local tracker = self:GetTracker(id)
        if tracker and tracker._next_cycle_t == params.time then
            return
        end
    end
    self._stealth_trackers.lasers[params.id] = true
    self:AddTracker(params)
end

function EHIManager:AddTimedAchievementTracker(id, time_max, icon)
    local t = time_max - self._t
    if t <= 0 then
        return
    end
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        time = t,
        icons = { icon },
        class = EHI.Trackers.Achievement
    })
end

function EHIManager:AddAchievementProgressTracker(id, max, progress, remove_after_reaching_target, icon)
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = { icon },
        delay_popup = self._delay_popups,
        remove_after_reaching_target = remove_after_reaching_target,
        class = EHI.Trackers.AchievementProgress
    })
end

function EHIManager:AddAchievementStatusTracker(id, status, icon)
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        status = status,
        icons = { icon },
        class = EHI.Trackers.AchievementStatus
    })
end

function EHIManager:AddAchievementBagValueCounter(id, to_secure, remove_after_reaching_target, icon)
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        to_secure = to_secure,
        icons = { icon },
        delay_popup = true,
        remove_after_reaching_target = remove_after_reaching_target,
        class = EHI.Trackers.AchievementBagValue
    })
end

function EHIManager:ShowLootCounter(max, additional_loot, max_random, offset)
    self:AddTracker({
        id = "LootCounter",
        max = (max or 0) + (additional_loot or 0),
        max_random = max_random or 0,
        offset = offset,
        class = "EHILootTracker"
    })
end

function EHIManager:SyncSecuredLoot()
    self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
end

function EHIManager:AddAchievementKillCounter(id, progress, max)
    local icon = self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = { icon },
        delay_popup = true,
        class = EHI.Trackers.AchievementProgress
    })
end

function EHIManager:AddEscapeChanceTracker(dropin, chance, civilian_killed_multiplier)
    if dropin or managers.assets:IsEscapeDriverAssetUnlocked() then
        return
    end
    self:DisableIncreaseCivilianKilled()
    civilian_killed_multiplier = civilian_killed_multiplier or 5
    self:AddTracker({
        id = "EscapeChance",
        chance = chance + (self:GetAndRemoveFromCache("CiviliansKilled", 0) * civilian_killed_multiplier),
        icons = { { icon = EHI.Icons.Car, color = Color.red } },
        class = EHI.Trackers.Chance
    })
end

function EHIManager:RemovePager(id)
    self._stealth_trackers.pagers[id] = nil
end

function EHIManager:RemoveLaser(id)
    self._stealth_trackers.lasers[id] = nil
end

function EHIManager:SwitchToLoudMode()
    for _, trackers in pairs(self._stealth_trackers) do
        for key, _ in pairs(trackers) do
            self:RemoveTracker(key)
        end
    end
    self:CallFunction("Deployables", "AddToIgnore", "bodybags_bag")
    self._deployables_ignore = { bodybags_bag = true }
end

if EHI:GetOption("tracker_alignment") == 1 then -- Vertical
    function EHIManager:GetX(pos)
        return self._x
    end

    function EHIManager:GetY(pos)
        pos = pos or self._n_of_trackers
        return self._y + (pos * (self._panel_size + self._panel_offset))
    end

    function EHIManager:MoveTracker(pos, icons)
        if pos and type(pos) == "number" and self._n_of_trackers ~= 0 then
            local move = false
            for _, tbl in pairs(self._trackers_pos) do
                if tbl.pos >= pos then
                    move = true
                    break
                end
            end
            if move then
                for _, tbl in pairs(self._trackers_pos) do
                    if tbl.pos >= pos then
                        local final_pos = tbl.pos + 1
                        tbl.tracker:SetTop(self:GetY(final_pos))
                        tbl.pos = final_pos
                    end
                end
            else
                -- No tracker found on the provided pos
                -- Scrap this and create the tracker on the first available position
                pos = nil
            end
        else
            -- Received crap or no tracker exists
            pos = nil
        end
        return pos
    end

    function EHIManager:RearrangeTrackers(pos, w)
        if not pos then
            return
        end
        for _, value in pairs(self._trackers_pos) do
            if value.pos > pos then
                local final_pos = value.pos - 1
                value.tracker:SetTop(self:GetY(final_pos))
                value.pos = final_pos
            end
        end
    end

    function EHIManager:ChangeTrackerWidth(id, new_w)
    end
else -- Horizontal
    function EHIManager:GetX(pos)
        if self._n_of_trackers == 0 or pos and pos == 0 then
            return self._x
        end
        local x = 0
        local pos_create = pos or (self._n_of_trackers - 1)
        for _, value in pairs(self._trackers_pos) do
            if value.pos == pos_create then
                x = value.x + value.w + self._panel_offset
                break
            end
        end
        return x
    end

    function EHIManager:GetY(pos)
        return self._y
    end

    function EHIManager:MoveTracker(pos, icons)
        if pos and type(pos) == "number" and self._n_of_trackers ~= 0 then
            local move = false
            for _, tbl in pairs(self._trackers_pos) do
                if tbl.pos >= pos then
                    move = true
                    break
                end
            end
            if move then
                local w = 64 * self._scale
                if type(icons) == "table" then
                    local n = #icons
                    local gap = 5 * n
                    w = ((64 + gap + (32 * n)) * self._scale)
                end
                for _, tbl in pairs(self._trackers_pos) do
                    if tbl.pos >= pos then
                        local final_x = tbl.x + w + self._panel_offset
                        tbl.tracker:SetLeft(final_x)
                        tbl.x = final_x
                        tbl.pos = tbl.pos + 1
                    end
                end
            else
                -- No tracker found on the provided pos
                -- Scrap this and create the tracker on the first available position
                pos = nil
            end
        else
            -- Received crap or no tracker exists
            pos = nil
        end
        return pos
    end

    function EHIManager:RearrangeTrackers(pos, w, pos_move, panel_offset_move)
        if not pos then
            return
        end
        pos_move = pos_move or 1
        panel_offset_move = panel_offset_move or self._panel_offset
        for id, value in pairs(self._trackers_pos) do
            if value.pos > pos then
                local final_x = value.x - w - panel_offset_move
                value.tracker:SetLeft(final_x)
                value.x = final_x
                value.pos = value.pos - pos_move
            end
        end
    end

    function EHIManager:ChangeTrackerWidth(id, new_w)
        if not self._trackers_pos[id] then
            return
        end
        local tracker = self._trackers_pos[id]
        local w = tracker.w
        tracker.w = new_w
        self:RearrangeTrackers(tracker.pos, -(new_w - w), 0, 0)
    end
end

function EHIManager:AddTrackerToUpdate(id, tracker)
    self._trackers_to_update[id] = tracker
end

function EHIManager:RemoveTrackerFromUpdate(id)
    self._trackers_to_update[id] = nil
end

function EHIManager:GetTracker(id)
    return id and self._trackers[id]
end

function EHIManager:RemoveTracker(id)
    local tracker = self._trackers[id]
    if tracker then
        tracker:delete()
    end
end

function EHIManager:ForceRemoveTracker(id)
    local tracker = self._trackers[id]
    if tracker then
        tracker:ForceDelete()
    end
end

function EHIManager:HideTracker(id)
    self._trackers_to_update[id] = nil
    local tracker_pos = self._trackers_pos[id]
    if tracker_pos then
        local pos = tracker_pos.pos
        local w = tracker_pos.w
        self._trackers_pos[id] = nil
        self._n_of_trackers = self._n_of_trackers - 1
        self:RearrangeTrackers(pos, w)
    end
end

function EHIManager:DestroyTracker(id)
    self._trackers[id] = nil
    self._trackers_to_update[id] = nil
    local tracker_pos = self._trackers_pos[id]
    if tracker_pos then
        local pos = tracker_pos.pos
        local w = tracker_pos.w
        self._trackers_pos[id] = nil
        self._n_of_trackers = self._n_of_trackers - 1
        self:RearrangeTrackers(pos, w)
    end
end

function EHIManager:TrackerExists(id)
    return self._trackers[id] ~= nil
end

function EHIManager:TrackerDoesNotExist(id)
    return not self:TrackerExists(id)
end

function EHIManager:SetTrackerPaused(id, pause)
    local tracker = self._trackers[id]
    if tracker and tracker.SetPause then
        tracker:SetPause(pause)
    end
end

function EHIManager:PauseTracker(id)
    self:SetTrackerPaused(id, true)
end

function EHIManager:UnpauseTracker(id)
    self:SetTrackerPaused(id, false)
end

function EHIManager:AddMoneyToTracker(id, money)
    local tracker = self._trackers[id]
    if tracker and tracker.AddMoney then
        tracker:AddMoney(money)
    end
end

function EHIManager:RemoveMoneyFromTracker(id, money)
    local tracker = self._trackers[id]
    if tracker and tracker.RemoveMoney then
        tracker:RemoveMoney(money)
    end
end

function EHIManager:AddXPToTracker(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.AddXP then
        tracker:AddXP(amount)
    end
end

function EHIManager:SetXPInTracker(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.SetXP then
        tracker:SetXP(amount)
    end
end

function EHIManager:SetTrackerTime(id, time)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetTime(time)
    end
end

function EHIManager:SetTrackerTimeNoAnim(id, time)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetTimeNoAnim(time)
    end
end

function EHIManager:SetTimerJammed(id, jammed)
    local tracker = self._trackers[id]
    if tracker and tracker.SetJammed then
        tracker:SetJammed(jammed)
    end
end

function EHIManager:SetTimerPowered(id, powered)
    local tracker = self._trackers[id]
    if tracker and tracker.SetPowered then
        tracker:SetPowered(powered)
    end
end

function EHIManager:SetTimerRunning(id)
    local tracker = self._trackers[id]
    if tracker and tracker.SetRunning then
        tracker:SetRunning()
    end
end

function EHIManager:SetTrackerIcon(id, icon)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetIcon(icon)
    end
end

function EHIManager:AddToCache(id, data)
    self._cache[id] = data
end

function EHIManager:GetAndRemoveFromCache(id, default)
    local data = self._cache[id]
    self._cache[id] = nil
    return data or default
end

function EHIManager:AddToTradeDelayCache(peer_id, respawn_penalty, in_custody)
    if self._cache.TradeDelayShowed then
        self:PostPeerCustodyTime(peer_id, respawn_penalty, in_custody)
        return
    end
    self._cache.TradeDelay[peer_id] =
    {
        respawn_t = respawn_penalty,
        in_custody = in_custody
    }
end

function EHIManager:SetCachedPeerInCustody(peer_id)
    if not self._cache.TradeDelay[peer_id] then
        return
    end
    if self._cache.TradeDelayShowed then
        local data = self._cache.TradeDelay[peer_id]
        self:PostPeerCustodyTime(peer_id, data.respawn_t, true)
        return
    end
    self._cache.TradeDelay[peer_id].in_custody = true
end

function EHIManager:IncreaseCachedPeerCustodyTime(peer_id, time)
    if not self._cache.TradeDelay[peer_id] then
        return
    end
    local respawn_t = self._cache.TradeDelay[peer_id].respawn_t
    local new_t = respawn_t + time
    if self._cache.TradeDelayShowed then
        self:PostPeerCustodyTime(peer_id, new_t)
        return
    end
    self._cache.TradeDelay[peer_id].respawn_t = new_t
end

function EHIManager:SetCachedPeerCustodyTime(peer_id, time)
    if not self._cache.TradeDelay[peer_id] then
        return
    end
    if self._cache.TradeDelayShowed then
        self:PostPeerCustodyTime(peer_id, time)
        return
    end
    self._cache.TradeDelay[peer_id].respawn_t = time
end

function EHIManager:CachedPeerInCustodyExists(peer_id)
    return self._cache.TradeDelay[peer_id] ~= nil
end

function EHIManager:LoadFromTradeDelayCache()
    if next(self._cache.TradeDelay) then
        self:AddCustodyTimeTracker()
        for peer_id, crim in pairs(self._cache.TradeDelay) do
            self:AddPeerCustodyTime(peer_id, crim.respawn_t)
            if crim.in_custody then
                self:CallFunction("CustodyTime", "SetPeerInCustody", peer_id)
            end
        end
    end
    self._cache.TradeDelayShowed = true
end

function EHIManager:PostPeerCustodyTime(peer_id, time, in_custody) -- In case the civilian is killed at the same time when alarm went off
    local tracker = self:GetTracker("CustodyTime")
    if tracker then
        if tracker:PeerExists(peer_id) then
            tracker:IncreasePeerCustodyTime(peer_id, time)
        else
            tracker:AddPeerCustodyTime(peer_id, time)
        end
        if in_custody then
            tracker:SetPeerInCustody(peer_id)
        end
    else
        self:AddCustodyTimeTracker()
        self:AddPeerCustodyTime(peer_id, time)
        if in_custody then
            self:CallFunction("CustodyTime", "SetPeerInCustody", peer_id)
        end
    end
end

function EHIManager:AddToDeployableCache(type, key, unit, tracker_type)
    if not key then
        return
    end
    self._cache._deployables[type] = self._cache._deployables[type] or {}
    self._cache._deployables[type][key] = { unit = unit, tracker_type = tracker_type }
    local tracker = self:GetTracker(type)
    if tracker then
        if tracker_type then
            tracker:UpdateAmount(tracker_type, unit, key, 0)
        else
            tracker:UpdateAmount(unit, key, 0)
        end
    end
end

function EHIManager:LoadFromDeployableCache(type, key)
    if not key then
        return
    end
    self._cache._deployables[type] = self._cache._deployables[type] or {}
    if self._cache._deployables[type][key] then
        if self:TrackerDoesNotExist(type) then
            self:CreateDeployableTracker(type)
        end
        local deployable = self._cache._deployables[type][key]
        local unit = deployable.unit
        local tracker = self:GetTracker(type)
        if tracker then
            if deployable.tracker_type then
                tracker:UpdateAmount(deployable.tracker_type, unit, key, unit:base():GetRealAmount())
            else
                tracker:UpdateAmount(unit, key, unit:base():GetRealAmount())
            end
        end
        self._cache._deployables[type][key] = nil
    end
end

function EHIManager:RemoveFromDeployableCache(type, key)
    if not key then
        return
    end
    self._cache._deployables[type] = self._cache._deployables[type] or {}
    self._cache._deployables[type][key] = nil
end

function EHIManager:CreateDeployableTracker(type)
    if type == "Deployables" then
        self:AddAggregatedDeployablesTracker()
    elseif type == "Health" then
        self:AddAggregatedHealthTracker()
    elseif type == "DoctorBags" then
        self:AddTracker({
            id = "DoctorBags",
            icons = { "doctor_bag" },
            class = "EHIEquipmentTracker"
        })
    elseif type == "AmmoBags" then
        self:AddTracker({
            id = "AmmoBags",
            format = "percent",
            icons = { "ammo_bag" },
            class = "EHIEquipmentTracker"
        })
    elseif type == "BodyBags" then
        self:AddTracker({
            id = "BodyBags",
            icons = { "bodybags_bag" },
            class = "EHIEquipmentTracker"
        })
    elseif type == "FirstAidKits" then
        self:AddTracker({
            id = "FirstAidKits",
            icons = { "first_aid_kit" },
            dont_show_placed = true,
            class = "EHIEquipmentTracker"
        })
    end
end

function EHIManager:IncreaseChance(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseChance then
        tracker:IncreaseChance(amount)
    end
end

function EHIManager:DecreaseChance(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.DecreaseChance then
        tracker:DecreaseChance(amount)
    end
end

function EHIManager:SetChance(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.SetChance then
        tracker:SetChance(amount)
    end
end

function EHIManager:SetTrackerProgress(id, progress)
    local tracker = self._trackers[id]
    if tracker and tracker.SetProgress then
        tracker:SetProgress(progress)
    end
end

function EHIManager:IncreaseTrackerProgress(id, value)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseProgress then
        tracker:IncreaseProgress(value)
    end
end

function EHIManager:DecreaseTrackerProgress(id, value)
    local tracker = self._trackers[id]
    if tracker and tracker.DecreaseProgress then
        tracker:DecreaseProgress(value)
    end
end

function EHIManager:IncreaseTrackerProgressMax(id, max)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseProgressMax then
        tracker:IncreaseProgressMax(max)
    end
end

function EHIManager:DecreaseTrackerProgressMax(id, max)
    local tracker = self._trackers[id]
    if tracker and tracker.DecreaseProgressMax then
        tracker:DecreaseProgressMax(max)
    end
end

function EHIManager:SetTrackerProgressMax(id, max)
    local tracker = self._trackers[id]
    if tracker and tracker.SetProgressMax then
        tracker:SetProgressMax(max)
    end
end

function EHIManager:SetTrackerProgressRemaining(id, remaining)
    local tracker = self._trackers[id]
    if tracker and tracker.SetProgressRemaining then
        tracker:SetProgressRemaining(remaining)
    end
end

function EHIManager:SetTrackerAccurate(id, time)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetTrackerAccurate(time)
    end
end

function EHIManager:StartTrackerCountdown(id)
    local tracker = self._trackers[id]
    if tracker then
        self:AddTrackerToUpdate(id, tracker)
    end
end

function EHIManager:AddAggregatedDeployablesTracker()
    self:AddTracker({
        id = "Deployables",
        icons = { "deployables" },
        ignore = self._deployables_ignore or {},
        format = { ammo_bag = "percent" },
        class = "EHIAggregatedEquipmentTracker"
    })
end

function EHIManager:AddAggregatedHealthTracker()
    self:AddTracker({
        id = "Health",
        class = "EHIAggregatedHealthEquipmentTracker"
    })
end

function EHIManager:SetAchievementComplete(id, force)
    local tracker = self._trackers[id]
    if tracker and tracker.SetCompleted then
        tracker:SetCompleted(force)
    end
end

function EHIManager:SetAchievementFailed(id)
    local tracker = self._trackers[id]
    if tracker and tracker.SetFailed then
        tracker:SetFailed()
    end
end

function EHIManager:SetAchievementStatus(id, status)
    local tracker = self._trackers[id]
    if tracker and tracker.SetStatus then
        tracker:SetStatus(status)
    end
end

function EHIManager:SetTrackerCount(id, count)
    local tracker = self._trackers[id]
    if tracker and tracker.SetCount then
        tracker:SetCount(count)
    end
end

function EHIManager:IncreaseTrackerCount(id)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseCount then
        tracker:IncreaseCount()
    end
end

function EHIManager:DecreaseTrackerCount(id)
    local tracker = self._trackers[id]
    if tracker and tracker.DecreaseCount then
        tracker:DecreaseCount()
    end
end

function EHIManager:AddCustodyTimeTracker()
    self:AddTracker({
        id = "CustodyTime",
        class = "EHITradeDelayTracker"
    })
end

function EHIManager:AddCustodyTimeTrackerWithPeer(peer_id, time)
    self:AddCustodyTimeTracker()
    self:AddPeerCustodyTime(peer_id, time)
    if self._trade.normal or self._trade.ai then
        local f = self._trade.normal and "SetTrade" or "SetAITrade"
        self:CallFunction("CustodyTime", f, true, managers.trade:GetTradeCounterTick(), true)
    end
end

function EHIManager:AddPeerCustodyTime(peer_id, respawn_time_penalty)
    self:CallFunction("CustodyTime", "AddPeerCustodyTime", peer_id, respawn_time_penalty)
end

function EHIManager:SetTrade(type, pause, t)
    self._trade[type] = pause
    local f = type == "normal" and "SetTrade" or "SetAITrade"
    self:CallFunction("CustodyTime", f, pause, t)
end

function EHIManager:IncreaseCivilianKilled()
    if self._cache.CiviliansKilledDisabled then
        return
    end
    self._cache.CiviliansKilled = (self._cache.CiviliansKilled or 0) + 1
end

function EHIManager:DisableIncreaseCivilianKilled()
    self._cache.CiviliansKilledDisabled = true
end

function EHIManager:CallFunction(id, f, ...)
    local tracker = self._trackers[id]
    if tracker and tracker[f] then
        tracker[f](tracker, ...)
    end
end

function EHIManager:ReturnValue(id, f, ...)
    local tracker = self._trackers[id]
    if tracker and tracker[f] then
        return tracker[f](tracker, ...)
    end
end

if Global.load_level then
    local path = EHI.LuaPath .. "trackers/"
    dofile(path .. "EHITracker.lua")
    dofile(path .. "EHIWarningTracker.lua")
    dofile(path .. "EHIPausableTracker.lua")
    dofile(path .. "EHITimerTracker.lua")
    dofile(path .. "EHIMoneyCounterTracker.lua")
    dofile(path .. "EHIChanceTracker.lua")
    dofile(path .. "EHIProgressTracker.lua")
    dofile(path .. "EHICountTracker.lua")
    dofile(path .. "EHINeededValueTracker.lua")
    dofile(path .. "EHIAchievementTrackers.lua")
    dofile(path .. "EHITrophyTrackers.lua")
    dofile(path .. "EHIDailyTrackers.lua")
    dofile(path .. "EHIInaccurateTrackers.lua")
    dofile(path .. "EHIColoredCodesTracker.lua")
    if EHI:GetOption("xp_panel") <= 2 and EHI:IsXPTrackerVisible() then
        dofile(path .. "EHIXPTracker.lua")
    end
    if EHI:GetOption("show_timers") then
        dofile(path .. "EHISecurityLockGuiTracker.lua")
    end
    if EHI:GetOption("show_equipment_tracker") or (EHI:GetOption("show_minion_tracker") and not EHI:GetOption("show_minion_per_player")) then
        dofile(path .. "EHIEquipmentTracker.lua")
    end
    if EHI:GetOption("show_equipment_tracker") then
        dofile(path .. "EHIAggregatedEquipmentTracker.lua")
        dofile(path .. "EHIAggregatedHealthEquipmentTracker.lua")
        dofile(path .. "EHIECMTracker.lua")
    end
    if EHI:GetOption("show_loot_counter") then
        dofile(path .. "EHILootTracker.lua")
    end
end