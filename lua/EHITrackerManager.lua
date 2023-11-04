local EHI = EHI
---@class EHITrackerManager
---@field IsLoading fun(self: self): boolean VR only (EHITrackerManagerVR)
---@field AddToLoadQueue fun(self: self, key: string, data: table, f: function, add: boolean?) VR only (EHITrackerManagerVR)
---@field SetPanel fun(self: self, panel: Panel) VR only (EHITrackerManagerVR)
EHITrackerManager = {}
EHITrackerManager.GetAchievementIcon = EHI.GetAchievementIconString
function EHITrackerManager:new()
    self:CreateWorkspace()
    self._t = 0
    self._trackers = setmetatable({}, {__mode = "k"}) ---@type table<string, EHITracker?>
    self._stealth_trackers = { pagers = {}, lasers = {} }
    self._trackers_to_update = setmetatable({}, {__mode = "k"}) ---@type table<string, EHITracker?>
    self._trackers_pos = setmetatable({}, {__mode = "k"}) ---@type table<string, { tracker: EHITracker, pos: number, x: number, y: number, w: number }?>
    self._n_of_trackers = 0
    self._delay_popups = true
    self._panel_size = 32 * self._scale
    self._panel_offset = 6 * self._scale
    self._base_tracker_class = EHI.Trackers.Base
    return self
end

function EHITrackerManager:CreateWorkspace()
    local x, y = managers.gui_data:safe_to_full(EHI:GetOption("x_offset"), EHI:GetOption("y_offset"))
    self._x = x
    self._y = y
    self._ws = managers.gui_data:create_fullscreen_workspace()
    self._ws:hide()
    self._scale = EHI:GetOption("scale")
    self._hud_panel = self._ws:panel():panel({
        name = "ehi_panel",
        layer = -10
    })
end

function EHITrackerManager:init_finalize()
    EHI:AddOnAlarmCallback(callback(self, self, "SwitchToLoudMode"))
    EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(self, self, "Spawned"))
end

function EHITrackerManager:Spawned()
    self._delay_popups = false
end

function EHITrackerManager:ShowPanel()
    self._ws:show()
end

function EHITrackerManager:HidePanel()
    self._ws:hide()
end

---@param t number
function EHITrackerManager:LoadTime(t)
    self._t = t
end

function EHITrackerManager:LoadSync()
    EHI:DelayCall("EHI_Converts_UpdatePeerColors", 2, function()
        self:CallFunction("Converts", "UpdatePeerColors")
    end)
end

---@param t number
---@param dt number
function EHITrackerManager:update(t, dt)
    for _, tracker in pairs(self._trackers_to_update) do
        tracker:update(t, dt)
    end
end

---@param t number
function EHITrackerManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(t, dt)
end

function EHITrackerManager:destroy()
    for _, tracker in pairs(self._trackers) do
        tracker:destroy(true)
    end
    if self._ws and alive(self._ws) then
        managers.gui_data:destroy_workspace(self._ws)
        self._ws = nil
    end
end

---@param params AddTrackerTable|ElementTrigger
---@param pos integer?
function EHITrackerManager:AddTracker(params, pos)
    if self._trackers[params.id] then
        EHI:Log("Tracker with ID '" .. tostring(params.id) .. "' exists!")
        EHI:LogTraceback()
        self._trackers[params.id]:ForceDelete()
    end
    local class = params.class or self._base_tracker_class
    local tracker_class = _G[class] --[[@as EHITracker]]
    pos = self:MoveTracker(pos, tracker_class._forced_icons or params.icons)
    params.parent_class = self
    params.x = self:GetX(pos)
    params.y = self:GetY(pos)
    params.dynamic = true
    local tracker = tracker_class:new(self._hud_panel, params)
    if tracker._update then
        self._trackers_to_update[params.id] = tracker
    end
    self._trackers[params.id] = tracker
    self._trackers_pos[params.id] = { tracker = tracker, pos = pos or self._n_of_trackers, x = params.x, y = params.y, w = tracker:GetPanelW() }
    self._n_of_trackers = self._n_of_trackers + 1
end

---@param params AddTrackerTable
function EHITrackerManager:PreloadTracker(params)
    if self._trackers[params.id] then
        EHI:Log("Tracker with ID '" .. tostring(params.id) .. "' exists!")
        EHI:LogTraceback()
        self._trackers[params.id]:ForceDelete()
    end
    params.parent_class = self
    params.x = 0
    params.y = 0
    local class = params.class or self._base_tracker_class
    local tracker = _G[class]:new(self._hud_panel, params) --[[@as EHITracker]]
    self._trackers[params.id] = tracker
end

---@param id string
---@param params AddTrackerTable|ElementTrigger
function EHITrackerManager:RunTracker(id, params)
    local tracker = self._trackers[id]
    if not tracker then
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

---Called by host only. Clients with EHI call EHITrackerManager:AddTracker() when synced
---@param params AddTrackerTable
---@param id integer
---@param delay number
function EHITrackerManager:AddTrackerAndSync(params, id, delay)
    self:AddTracker(params)
    self:Sync(id, delay)
end

---@param id integer
---@param delay number
function EHITrackerManager:Sync(id, delay)
    EHI:SyncTable(EHI.SyncMessages.EHISyncAddTracker, { id = id, delay = delay or 0 })
end

if Global.game_settings.single_player then
    EHITrackerManager.Sync = function(...) end
end

---@param id string
function EHITrackerManager:AddPagerTracker(id)
    self._stealth_trackers.pagers[id] = true
    local params =
    {
        id = id,
        class = "EHIPagerTracker"
    }
    self:AddTracker(params)
end

---@param params table
function EHITrackerManager:AddLaserTracker(params)
    for id, _ in pairs(self._stealth_trackers.lasers) do
        -- Don't add this tracker if the "next_cycle_t" is the same as time to prevent duplication
        local tracker = self:GetTracker(id)
        ---@diagnostic disable-next-line
        if tracker and tracker._next_cycle_t == params.time then
            return
        end
    end
    self._stealth_trackers.lasers[params.id] = true
    self:AddTracker(params)
end

---@param id string
---@param time_max number
---@param icon string?
function EHITrackerManager:AddTimedAchievementTracker(id, time_max, icon)
    local t = time_max - self._t
    if t <= 0 then
        return
    end
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        time = t,
        icons = { icon },
        class = EHI.Trackers.Achievement.Base
    })
end

---@param id string
---@param max integer
---@param progress integer?
---@param show_finish_after_reaching_target boolean?
---@param class string?
---@param icon string?
function EHITrackerManager:AddAchievementProgressTracker(id, max, progress, show_finish_after_reaching_target, class, icon)
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = { icon },
        delay_popup = self._delay_popups,
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        class = class or EHI.Trackers.Achievement.Progress
    })
end

---@param id string
---@param status string?
---@param icon string?
function EHITrackerManager:AddAchievementStatusTracker(id, status, icon)
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        status = status,
        icons = { icon },
        class = EHI.Trackers.Achievement.Status
    })
end

---@param id string
---@param max number
---@param loot_counter_on_fail boolean?
---@param start_silent boolean?
---@param icon string?
function EHITrackerManager:AddAchievementLootCounter(id, max, loot_counter_on_fail, start_silent, icon)
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        max = max,
        icons = { icon },
        delay_popup = self._delay_popups,
        loot_counter_on_fail = loot_counter_on_fail,
        start_silent = start_silent,
        class = EHI.Trackers.Achievement.LootCounter
    })
end

---@param id string
---@param max number
---@param show_finish_after_reaching_target boolean?
---@param icon string?
function EHITrackerManager:AddAchievementBagValueCounter(id, max, show_finish_after_reaching_target, icon)
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        max = max,
        icons = { icon },
        delay_popup = true,
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        class = EHI.Trackers.Achievement.BagValue
    })
end

---Shows Loot Counter, needs to be hooked to count correctly
---@param max integer?
---@param max_random any?
---@param offset any?
function EHITrackerManager:ShowLootCounter(max, max_random, offset)
    self:AddTracker({
        id = "LootCounter",
        max = (max or 0),
        max_random = max_random or 0,
        offset = offset or 0,
        class = "EHILootTracker"
    })
end

---@param tracker_id string? Defaults to `LootCounter` if not provided
function EHITrackerManager:SyncSecuredLoot(tracker_id)
    self:SetTrackerProgress(tracker_id or "LootCounter", managers.loot:GetSecuredBagsAmount())
end

---@param id string
---@param progress number
---@param max number
function EHITrackerManager:AddAchievementKillCounter(id, progress, max)
    local icon = self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = { icon },
        delay_popup = true,
        class = EHI.Trackers.Achievement.Progress
    })
end

---@param params AddTrackerTable|ElementTrigger
---@param pos integer?
function EHITrackerManager:AddTrackerIfDoesNotExist(params, pos)
    if self:TrackerDoesNotExist(params.id) then
        self:AddTracker(params, pos)
    end
end

---@param id string
---@param params AddTrackerTable|ElementTrigger
function EHITrackerManager:RunTrackerIfDoesNotExist(id, params)
    if self:TrackerExists(id) and not self._trackers_pos[id] then
        self:RunTracker(id, params)
    end
end

---@param id string
---@param stealth_id string
function EHITrackerManager:RemoveStealthTracker(id, stealth_id)
    self._stealth_trackers[stealth_id][id] = nil
    self:RemoveTracker(id)
end

---@param id string
function EHITrackerManager:RemoveLaserTracker(id)
    self._stealth_trackers.lasers[id] = nil
    self:RemoveTracker(id)
end

function EHITrackerManager:SwitchToLoudMode()
    for _, trackers in pairs(self._stealth_trackers) do
        for key, _ in pairs(trackers) do
            self:RemoveTracker(key)
        end
    end
end

if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", 1) then -- Vertical in VR or in non-VR
    ---@param pos number?
    ---@return number
    function EHITrackerManager:GetX(pos)
        return self._x
    end

    ---@param pos number?
    ---@return number
    function EHITrackerManager:GetY(pos)
        pos = pos or self._n_of_trackers
        return self._y + (pos * (self._panel_size + self._panel_offset))
    end

    ---@param pos number?
    ---@param icons table?
    ---@return number?
    function EHITrackerManager:MoveTracker(pos, icons)
        if type(pos) == "number" and self._n_of_trackers > 0 and pos <= self._n_of_trackers then
            for _, tbl in pairs(self._trackers_pos) do
                if tbl.pos >= pos then
                    local final_pos = tbl.pos + 1
                    tbl.tracker:AnimateTop(self:GetY(final_pos))
                    tbl.pos = final_pos
                end
            end
            return pos
        end
        return nil -- Received crap or no tracker exists; create tracker on the first available position
    end

    ---@param pos number
    ---@param w number
    ---@param pos_move number?
    ---@param panel_offset_move number?
    function EHITrackerManager:RearrangeTrackers(pos, w, pos_move, panel_offset_move)
        if not pos then
            return
        end
        for _, value in pairs(self._trackers_pos) do
            if value.pos > pos then
                local final_pos = value.pos - 1
                value.tracker:AnimateTop(self:GetY(final_pos))
                value.pos = final_pos
            end
        end
    end

    ---Call this function only from trackers themselves
    ---@param id string
    ---@param new_w number
    function EHITrackerManager:ChangeTrackerWidth(id, new_w)
    end
else -- Horizontal
    ---@param pos number?
    ---@return number
    function EHITrackerManager:GetX(pos)
        if self._n_of_trackers == 0 or pos and pos <= 0 then
            return self._x
        end
        local x = 0
        local pos_create = pos and (pos - 1) or (self._n_of_trackers - 1)
        for _, value in pairs(self._trackers_pos) do
            if value.pos == pos_create then
                x = value.x + value.w + self._panel_offset
                break
            end
        end
        return x
    end

    ---@param pos number?
    ---@return number
    function EHITrackerManager:GetY(pos)
        return self._y
    end

    ---@param pos number?
    ---@param icons table?
    ---@return number?
    function EHITrackerManager:MoveTracker(pos, icons)
        if type(pos) == "number" and self._n_of_trackers > 0 and pos <= self._n_of_trackers then
            local w = 64 * self._scale
            if type(icons) == "table" then
                local n = #icons
                local gap = 5 * n
                w = (64 + gap + (32 * n)) * self._scale
            end
            for _, tbl in pairs(self._trackers_pos) do
                if tbl.pos >= pos then
                    local final_x = tbl.x + w + self._panel_offset
                    tbl.tracker:AnimateLeft(final_x)
                    tbl.x = final_x
                    tbl.pos = tbl.pos + 1
                end
            end
            return pos
        end
        return nil -- Received crap or no tracker exists; create tracker on the first available position
    end

    ---@param pos number
    ---@param w number
    ---@param pos_move number?
    ---@param panel_offset_move number?
    function EHITrackerManager:RearrangeTrackers(pos, w, pos_move, panel_offset_move)
        if not pos then
            return
        end
        pos_move = pos_move or 1
        panel_offset_move = panel_offset_move or self._panel_offset
        for _, value in pairs(self._trackers_pos) do
            if value.pos > pos then
                local final_x = value.x - w - panel_offset_move
                value.tracker:AnimateLeft(final_x)
                value.x = final_x
                value.pos = value.pos - pos_move
            end
        end
    end

    ---Call this function only from trackers themselves
    ---@param id string
    ---@param new_w number
    function EHITrackerManager:ChangeTrackerWidth(id, new_w)
        local tracker = self._trackers_pos[id]
        if not tracker then
            return
        end
        local w = tracker.w
        tracker.w = new_w
        self:RearrangeTrackers(tracker.pos, -(new_w - w), 0, 0)
    end
end

---@param id string
---@param tracker EHITracker
function EHITrackerManager:AddTrackerToUpdate(id, tracker)
    self._trackers_to_update[id] = tracker
end

---@param id string
function EHITrackerManager:RemoveTrackerFromUpdate(id)
    self._trackers_to_update[id] = nil
end

---@param id string
---@param new_id string
function EHITrackerManager:UpdateTrackerID(id, new_id)
    if self:TrackerExists(new_id) or self:TrackerDoesNotExist(id) then
        return
    end
    local tracker = self._trackers[id] --[[@as EHITracker]]
    tracker:UpdateID(new_id)
    self._trackers[id] = nil
    self._trackers[new_id] = tracker
    if self._trackers_to_update[id] then
        local update = self._trackers_to_update[id]
        self._trackers_to_update[id] = nil
        self._trackers_to_update[new_id] = update
    end
    if self._trackers_pos[id] then
        local pos = self._trackers_pos[id]
        self._trackers_pos[id] = nil
        self._trackers_pos[new_id] = pos
    end
end

---@param id string
---@return EHITracker?
function EHITrackerManager:GetTracker(id)
    return id and self._trackers[id]
end

---@param id string
function EHITrackerManager:RemoveTracker(id)
    local tracker = self._trackers[id]
    if tracker then
        tracker:delete()
    end
end

---@param id string
function EHITrackerManager:ForceRemoveTracker(id)
    local tracker = self._trackers[id]
    if tracker then
        tracker:ForceDelete()
    end
end

---@param id string
function EHITrackerManager:HideTracker(id)
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

---@param id string
function EHITrackerManager:DestroyTracker(id)
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

---@param id string
function EHITrackerManager:TrackerExists(id)
    return self._trackers_pos[id] ~= nil
end

---@param id string
function EHITrackerManager:TrackerDoesNotExist(id)
    return not self:TrackerExists(id)
end

---@diagnostic disable
---@param id string
---@param pause boolean
function EHITrackerManager:SetTrackerPaused(id, pause)
    local tracker = self._trackers[id]
    if tracker and tracker.SetPause then
        tracker:SetPause(pause)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:AddXPToTracker(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.AddXP then
        tracker:AddXP(amount)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:SetXPInTracker(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.SetXP then
        tracker:SetXP(amount)
    end
end

---@param id string
---@param time number
function EHITrackerManager:SetTrackerTime(id, time)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetTime(time)
    end
end

---@param id string
---@param time number
function EHITrackerManager:SetTrackerTimeNoAnim(id, time)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetTimeNoAnim(time)
    end
end

---@param id string
---@param jammed boolean
function EHITrackerManager:SetTimerJammed(id, jammed)
    local tracker = self._trackers[id]
    if tracker and tracker.SetJammed then
        tracker:SetJammed(jammed)
    end
end

---@param id string
---@param powered boolean
function EHITrackerManager:SetTimerPowered(id, powered)
    local tracker = self._trackers[id]
    if tracker and tracker.SetPowered then
        tracker:SetPowered(powered)
    end
end

---@param id string
---@param icon string
function EHITrackerManager:SetTrackerIcon(id, icon)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetIcon(icon)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:IncreaseChance(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseChance then
        tracker:IncreaseChance(amount)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:DecreaseChance(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.DecreaseChance then
        tracker:DecreaseChance(amount)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:SetChance(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.SetChance then
        tracker:SetChance(amount)
    end
end

---@param id string
---@param progress number
function EHITrackerManager:SetTrackerProgress(id, progress)
    local tracker = self._trackers[id]
    if tracker and tracker.SetProgress then
        tracker:SetProgress(progress)
    end
end

---@param id string
---@param value number?
function EHITrackerManager:IncreaseTrackerProgress(id, value)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseProgress then
        tracker:IncreaseProgress(value)
    end
end

---@param id string
---@param value number?
function EHITrackerManager:DecreaseTrackerProgress(id, value)
    local tracker = self._trackers[id]
    if tracker and tracker.DecreaseProgress then
        tracker:DecreaseProgress(value)
    end
end

---@param id string
---@param max number?
function EHITrackerManager:IncreaseTrackerProgressMax(id, max)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseProgressMax then
        tracker:IncreaseProgressMax(max)
    end
end

---@param id string
---@param max number?
function EHITrackerManager:DecreaseTrackerProgressMax(id, max)
    local tracker = self._trackers[id]
    if tracker and tracker.DecreaseProgressMax then
        tracker:DecreaseProgressMax(max)
    end
end

---@param id string
---@param max number
function EHITrackerManager:SetTrackerProgressMax(id, max)
    local tracker = self._trackers[id]
    if tracker and tracker.SetProgressMax then
        tracker:SetProgressMax(max)
    end
end

---@param id string
---@param remaining number
function EHITrackerManager:SetTrackerProgressRemaining(id, remaining)
    local tracker = self._trackers[id]
    if tracker and tracker.SetProgressRemaining then
        tracker:SetProgressRemaining(remaining)
    end
end

---@param id string
---@param time number
function EHITrackerManager:SetTrackerAccurate(id, time)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetTrackerAccurate(time)
    end
end

---@param id string
function EHITrackerManager:StartTrackerCountdown(id)
    local tracker = self._trackers[id]
    if tracker then
        self:AddTrackerToUpdate(id, tracker)
    end
end

---@param id string
---@param force boolean?
function EHITrackerManager:SetAchievementComplete(id, force)
    local tracker = self._trackers[id]
    if tracker and tracker.SetCompleted then
        tracker:SetCompleted(force)
    end
end

---@param id string
function EHITrackerManager:SetAchievementFailed(id)
    local tracker = self._trackers[id]
    if tracker and tracker.SetFailed then
        tracker:SetFailed()
    end
end

---@param id string
---@param status string
function EHITrackerManager:SetAchievementStatus(id, status)
    local tracker = self._trackers[id]
    if tracker and tracker.SetStatus then
        tracker:SetStatus(status)
    end
end

---@param id string
---@param count number
function EHITrackerManager:SetTrackerCount(id, count)
    local tracker = self._trackers[id]
    if tracker and tracker.SetCount then
        tracker:SetCount(count)
    end
end

---@param id string
---@param count number?
function EHITrackerManager:IncreaseTrackerCount(id, count)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseCount then
        tracker:IncreaseCount(count)
    end
end

---@param id string
---@param count number?
function EHITrackerManager:DecreaseTrackerCount(id, count)
    local tracker = self._trackers[id]
    if tracker and tracker.DecreaseCount then
        tracker:DecreaseCount(count)
    end
end
---@diagnostic enable

function EHITrackerManager:SecuredMissionLoot()
    self:CallFunction("LootCounter", "SecuredMissionLoot")
end

---@param max number?
function EHITrackerManager:IncreaseLootCounterProgressMax(max)
    self:IncreaseTrackerProgressMax("LootCounter", max)
end

---@param max number?
function EHITrackerManager:DecreaseLootCounterProgressMax(max)
    self:DecreaseTrackerProgressMax("LootCounter", max)
end

---@param max_random number?
function EHITrackerManager:SetLootCounterMaxRandom(max_random)
    self:CallFunction("LootCounter", "SetMaxRandom", max_random)
end

---@param progress number?
function EHITrackerManager:IncreaseLootCounterMaxRandom(progress)
    self:CallFunction("LootCounter", "IncreaseMaxRandom", progress)
end

---@param progress number?
function EHITrackerManager:DecreaseLootCounterMaxRandom(progress)
    self:CallFunction("LootCounter", "DecreaseMaxRandom", progress)
end

---@param random number?
function EHITrackerManager:RandomLootSpawned(random)
    self:CallFunction("LootCounter", "RandomLootSpawned", random)
end

---@param random number?
function EHITrackerManager:RandomLootDeclined(random)
    self:CallFunction("LootCounter", "RandomLootDeclined", random)
end

---@param id string Element ID
---@param force boolean? Force loot spawn event if the element does not have "fail" state (desync workaround)
function EHITrackerManager:RandomLootSpawnedCheck(id, force)
    self:CallFunction("LootCounter", "RandomLootSpawned2", id, force)
end

---@param id string Element ID
function EHITrackerManager:RandomLootDeclinedCheck(id)
    self:CallFunction("LootCounter", "RandomLootDeclined2", id)
end

---@param id string
---@param f string
---@param ... any
function EHITrackerManager:CallFunction(id, f, ...)
    local tracker = self._trackers[id]
    if tracker and tracker[f] then
        tracker[f](tracker, ...)
    end
end

---@param id string
---@param f string
---@param ... any
---@return ...
function EHITrackerManager:ReturnValue(id, f, ...)
    local tracker = self._trackers[id]
    if tracker and tracker[f] then
        return tracker[f](tracker, ...)
    end
end

do
    local path = EHI.LuaPath .. "trackers/"
    dofile(path .. "EHITracker.lua")
    dofile(path .. "EHIWarningTracker.lua")
    dofile(path .. "EHIPausableTracker.lua")
    dofile(path .. "EHIChanceTracker.lua")
    dofile(path .. "EHIProgressTracker.lua")
    dofile(path .. "EHICountTracker.lua")
    dofile(path .. "EHINeededValueTracker.lua")
    dofile(path .. "EHIInaccurateTrackers.lua")
    dofile(path .. "EHIColoredCodesTracker.lua")
    dofile(path .. "EHIAchievementTrackers.lua")
    dofile(path .. "EHITrophyTrackers.lua")
    dofile(path .. "EHIDailyTrackers.lua")
    if EHI:GetOption("xp_panel") <= 2 and EHI:IsXPTrackerVisible() then
        dofile(path .. "EHIXPTracker.lua")
    end
    if EHI:GetOption("show_equipment_tracker") or (EHI:GetOption("show_minion_tracker") and EHI:GetOption("show_minion_option") == 2) then
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
    if EHI:CombineAssaultDelayAndAssaultTime() then
        dofile(path .. "EHIAssaultTracker.lua")
    else
        if EHI:AssaultDelayTrackerIsEnabled() then
            dofile(path .. "EHIAssaultDelayTracker.lua")
        end
        if EHI:GetOption("show_assault_time_tracker") then
            dofile(path .. "EHIAssaultTimeTracker.lua")
        end
    end
end

if VoidUI then
    dofile(EHI.LuaPath .. "hud/tracker/void_ui.lua")
end