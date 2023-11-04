local EHI = EHI
if EHI:CheckLoadHook("SecurityLockGui") or not EHI:GetOption("show_timers") then
    return
end

local HackIcon = EHI.Icons.PCHack
local TimerClass = EHI.Trackers.Timer

local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_timers")

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
    if not show_waypoint_only then
        EHI:OptionAndLoadTracker("show_timers")
    end
end

function SecurityLockGui:_start(...)
    original._start(self, ...)
    if not show_waypoint_only then
        if self._bars > 1 then
            if managers.ehi_tracker:TrackerExists(self._ehi_key) then
                managers.ehi_tracker:SetTrackerProgress(self._ehi_key, self._current_bar)
            else
                managers.ehi_tracker:AddTracker({
                    id = self._ehi_key,
                    progress = self._current_bar,
                    max = self._bars,
                    show_progress_on_finish = true,
                    icons = { HackIcon },
                    class = TimerClass.Progress
                })
            end
            managers.ehi_tracker:CallFunction(self._ehi_key, "StartTimer", self._current_timer)
        else
            managers.ehi_tracker:AddTracker({
                id = self._ehi_key,
                time = self._current_timer,
                icons = { HackIcon },
                class = TimerClass.Base
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
        managers.ehi_manager:UpdateTimer(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
else
    function SecurityLockGui:update(...)
        managers.ehi_tracker:SetTrackerTimeNoAnim(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
end

function SecurityLockGui:_set_powered(powered, ...)
    original._set_powered(self, powered, ...)
    managers.ehi_manager:SetTimerPowered(self._ehi_key, powered)
end

function SecurityLockGui:_set_done(...)
    original._set_done(self, ...)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    if self._started then
        managers.ehi_tracker:RemoveTracker(self._ehi_key)
    else
        managers.ehi_tracker:CallFunction(self._ehi_key, "StopTimer")
    end
end

function SecurityLockGui:destroy(...)
    managers.ehi_manager:Remove(self._ehi_key)
    original.destroy(self, ...)
end