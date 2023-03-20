local EHI = EHI
if EHI:CheckLoadHook("SecurityLockGui") or not EHI:GetOption("show_timers") then
    return
end

local HackIcon = EHI.Icons.PCHack

local show_waypoint = EHI:GetWaypointOption("show_waypoints_timers")
local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")

local original =
{
    init = SecurityLockGui.init,
    _start = SecurityLockGui._start,
    update = SecurityLockGui.update,
    _set_powered = SecurityLockGui._set_powered,
    _set_done = SecurityLockGui._set_done,
    destroy = SecurityLockGui.destroy
}

function SecurityLockGui:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
end

function SecurityLockGui:_start(...)
    original._start(self, ...)
    if self._bars > 1 then
        if managers.ehi:TrackerExists(self._ehi_key) then
            managers.ehi:SetTrackerProgress(self._ehi_key, self._current_bar)
        else
            managers.ehi:AddTracker({
                id = self._ehi_key,
                class = "EHISecurityLockGuiTracker",
                remove_after_reaching_target = false,
                progress = self._current_bar,
                max = self._bars
            })
        end
        managers.ehi:CallFunction(self._ehi_key, "SetHackTime", self._current_timer)
    else
        if not show_waypoint_only then
            managers.ehi:AddTracker({
                id = self._ehi_key,
                time = self._current_timer,
                icons = { HackIcon },
                class = "EHITimerTracker"
            })
        end
    end
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
            time = self._current_timer,
            icon = HackIcon,
            position = self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position(),
            class = "EHITimerWaypoint"
        })
    end
end

if show_waypoint_only then
    function SecurityLockGui:update(...)
        managers.ehi_waypoint:SetWaypointTime(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
elseif show_waypoint then
    function SecurityLockGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._current_timer)
        managers.ehi_waypoint:SetWaypointTime(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
else
    function SecurityLockGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
end

function SecurityLockGui:_set_powered(powered, ...)
    original._set_powered(self, powered, ...)
    managers.ehi:SetTimerPowered(self._ehi_key, powered)
    managers.ehi_waypoint:SetTimerWaypointPowered(self._ehi_key, powered)
end

function SecurityLockGui:_set_done(...)
    original._set_done(self, ...)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    if self._started then
        managers.ehi:RemoveTracker(self._ehi_key)
    else
        managers.ehi:CallFunction(self._ehi_key, "RemoveHack")
    end
end

function SecurityLockGui:destroy(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    original.destroy(self, ...)
end