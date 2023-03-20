local EHI = EHI
if EHI:CheckLoadHook("TimerGui") or not EHI:GetOption("show_timers") then
    return
end

local Icon = EHI.Icons

local show_waypoint = EHI:GetWaypointOption("show_waypoints_timers")
local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")
-- [index] = Vector3(x, y, z)
local MissionDoorPositions = {}
-- [index] = { w_id = "Waypoint ID", restore = "If the waypoint should be restored when the drill finishes", w_ids = "Table of waypoints and their ID", unit_id = "ID of the door" }
---- See MissionDoor class how to get Drill position
---- Indexes must match or it won't work
---- "w_ids" has a higher priority than "w_id"
local MissionDoorIndex = {}

function TimerGui.SetMissionDoorPosAndIndex(pos, index)
    MissionDoorPositions = pos
    MissionDoorIndex = index
end

local original =
{
    init = TimerGui.init,
    set_background_icons = TimerGui.set_background_icons,
    _start = TimerGui._start,
    update = TimerGui.update,
    _set_done = TimerGui._set_done,
    _set_jammed = TimerGui._set_jammed,
    _set_powered = TimerGui._set_powered,
    set_visible = TimerGui.set_visible,
    destroy = TimerGui.destroy,
    hide = TimerGui.hide
}

function TimerGui:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    local icon = unit:base().is_drill and Icon.Drill or unit:base().is_hacking_device and Icon.PCHack or unit:base().is_saw and "pd2_generic_saw" or Icon.Wait
    self._ehi_icon = { { icon = icon } }
end

function TimerGui:set_background_icons(...)
    original.set_background_icons(self, ...)
    managers.ehi:CallFunction(self._ehi_key, "SetUpgrades", self:GetUpgrades())
end

function TimerGui:GetUpgrades()
    if self._unit:base()._disable_upgrades or not (self._unit:base().is_drill or self._unit:base().is_saw) or table.size(self._original_colors or {}) == 0 then
        return nil
    end
    local upgrade_table = nil
    local skills = self._unit:base().get_skill_upgrades and self._unit:base():get_skill_upgrades()
    if skills and table.size(self._original_colors or {}) > 0 then
        upgrade_table = {
            restarter = (skills.auto_repair_level_1 or 0) + (skills.auto_repair_level_2 or 0),
            faster = (skills.speed_upgrade_level or 0),
            silent = (skills.reduced_alert and 1 or 0) + (skills.silent_drill and 1 or 0)
        }
    end
    return upgrade_table
end

function TimerGui:StartTimer()
    if managers.ehi:TrackerExists(self._ehi_key) or managers.ehi_waypoint:WaypointExists(self._ehi_key) then
        managers.ehi:SetTimerRunning(self._ehi_key)
        managers.ehi_waypoint:SetTimerWaypointRunning(self._ehi_key)
    else
        local autorepair = self._unit:base()._autorepair
        -- In case the conversion fails, fallback to "self._time_left" which is a number
        local t = tonumber(self._current_timer) or self._time_left
        if not show_waypoint_only then
            managers.ehi:AddTracker({
                id = self._ehi_key,
                time = t,
                icons = self._icons or self._ehi_icon,
                theme = self.THEME,
                class = "EHITimerTracker",
                upgrades = self:GetUpgrades(),
                autorepair = autorepair
            })
        end
        if show_waypoint then
            managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
                time = t,
                icon = self._icons or self._ehi_icon[1].icon,
                position = self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position(),
                autorepair = autorepair,
                class = "EHITimerWaypoint"
            })
        end
        self:PostStartTimer()
    end
end

function TimerGui:PostStartTimer()
    if self._unit:mission_door_device() then
        local data = self:GetMissionDoorData()
        if data then
            self._remove_vanilla_waypoint = true
            self._restore_vanilla_waypoint_on_done = data.restore
            if data.w_ids then
                for _, id in ipairs(data.w_ids) do
                    self._waypoint_id = id
                    self:HideWaypoint()
                end
                return
            else
                self._waypoint_id = data.w_id
                if data.restore and data.unit_id then
                    local restore = callback(self, self, "RestoreWaypoint")
                    local m = managers.mission
                    local add_trigger = m.add_runned_unit_sequence_trigger
                    add_trigger(m, data.unit_id, "explode_door", restore)
                    add_trigger(m, data.unit_id, "open_door_keycard", restore)
                    add_trigger(m, data.unit_id, "open_door_ecm", restore)
                    add_trigger(m, data.unit_id, "open_door", restore) -- In case the drill finishes first host side than client-side
                    -- Drill finish is covered in TimerGui:_set_done()
                end
            end
        end
    end
    self:HideWaypoint()
end

function TimerGui:HideWaypoint()
    if self._remove_vanilla_waypoint and show_waypoint then
        self:_HideWaypoint(self._waypoint_id)
    end
end

function TimerGui:_HideWaypoint(waypoint)
    managers.hud:SoftRemoveWaypoint(waypoint)
    EHI._cache.IgnoreWaypoints[waypoint] = true
    EHI:DisableElementWaypoint(waypoint)
end

function TimerGui:GetMissionDoorData()
    -- No clue on what I can't compare the vectors directly via == and I have to do string comparison
    -- What changed that the comparison is not valid ? Constellation ? Game had a bad sleep ?
    -- This should be changed in the future...
    -- Saving grace here is that this function only runs when the drill is from MissionDoor class, which heists rarely use.
    local pos = tostring(self._unit:position())
    for i, p in ipairs(MissionDoorPositions) do
        if tostring(p) == pos then
            return MissionDoorIndex[i]
        end
    end
end

function TimerGui:_start(...)
    original._start(self, ...)
    if self._ignore then
        return
    end
    self:StartTimer()
end

if show_waypoint_only then
    function TimerGui:update(...)
        managers.ehi_waypoint:SetWaypointTime(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
elseif show_waypoint then
    function TimerGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._time_left)
        managers.ehi_waypoint:SetWaypointTime(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
else
    function TimerGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
end

function TimerGui:_set_done(...)
    self:RemoveTracker()
    original._set_done(self, ...)
    self:RestoreWaypoint()
end

function TimerGui:RestoreWaypoint()
    if self._restore_vanilla_waypoint_on_done and self._waypoint_id then
        EHI._cache.IgnoreWaypoints[self._waypoint_id] = nil
        managers.hud:RestoreWaypoint(self._waypoint_id)
        EHI:RestoreElementWaypoint(self._waypoint_id)
    end
end

function TimerGui:_set_jammed(jammed, ...)
    managers.ehi:SetTimerJammed(self._ehi_key, jammed)
    managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, jammed)
    original._set_jammed(self, jammed, ...)
end

function TimerGui:_set_powered(powered, ...)
    if powered == false and self._remove_on_power_off then
        self:RemoveTracker()
    end
    managers.ehi:SetTimerPowered(self._ehi_key, powered)
    managers.ehi_waypoint:SetTimerWaypointPowered(self._ehi_key, powered)
    original._set_powered(self, powered, ...)
end

function TimerGui:set_visible(visible, ...)
    original.set_visible(self, visible, ...)
    if self._ignore_visibility then
        return
    end
    if visible == false then
        self:RemoveTracker()
    end
end

function TimerGui:hide(...)
    self:RemoveTracker()
    original.hide(self, ...)
end

function TimerGui:destroy(...)
    self:RemoveTracker()
    original.destroy(self, ...)
end

function TimerGui:RemoveTracker()
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
end

function TimerGui:OnAlarm()
    self._ignore = true
    self:RemoveTracker()
end

function TimerGui:DisableOnSetVisible()
    self.set_visible = original.set_visible
end

function TimerGui:SetIcons(icons)
    self._icons = icons
end

function TimerGui:SetRemoveOnPowerOff(remove_on_power_off)
	self._remove_on_power_off = remove_on_power_off
end

function TimerGui:SetOnAlarm()
	EHI:AddOnAlarmCallback(callback(self, self, "OnAlarm"))
end

function TimerGui:RemoveVanillaWaypoint(waypoint_id)
    self._remove_vanilla_waypoint = true
    self._waypoint_id = waypoint_id
    if self._started then
        self:HideWaypoint()
    end
end

function TimerGui:SetIgnoreVisibility()
    self._ignore_visibility = true
end

function TimerGui:SetRestoreVanillaWaypointOnDone()
    self._restore_vanilla_waypoint_on_done = true
end

function TimerGui:Finalize()
    if self._ignore or (self._remove_on_power_off and not self._powered) then
        self:RemoveTracker()
        return
    elseif self._icons then
		managers.ehi:SetTrackerIcon(self._ehi_key, self._icons[1])
		managers.ehi_waypoint:SetWaypointIcon(self._ehi_key, self._icons[1])
	end
    if self._started and not self._done and self._unit:mission_door_device() then
        self:PostStartTimer()
    end
end