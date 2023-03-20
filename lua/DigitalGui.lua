local EHI = EHI
if EHI:CheckLoadHook("DigitalGui") or not EHI:GetOption("show_timers") then
    return
end

local Icon = EHI.Icons

local show_waypoint = EHI:GetWaypointOption("show_waypoints_timers")
local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")

local original =
{
    init = DigitalGui.init,
    _update_timer_text = DigitalGui._update_timer_text,
    timer_start_count_down = DigitalGui.timer_start_count_down,
    timer_pause = DigitalGui.timer_pause,
    timer_resume = DigitalGui.timer_resume,
    _timer_stop = DigitalGui._timer_stop,
    set_visible = DigitalGui.set_visible,
    timer_set = DigitalGui.timer_set,
    load = DigitalGui.load
}
local level_id = Global.game_settings.level_id

function DigitalGui:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._ignore_visibility = false
end

function DigitalGui:TimerStartCountDown()
    if (self._ignore or not self._visible) and not self._ignore_visibility then
        return
    end
    if managers.ehi:TrackerExists(self._ehi_key) or managers.ehi_waypoint:WaypointExists(self._ehi_key) then
        managers.ehi:SetTimerJammed(self._ehi_key, false)
        managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, false)
    else
        if not show_waypoint_only then
            managers.ehi:AddTracker({
                id = self._ehi_key,
                time = self._timer,
                icons = self._icons or { Icon.PCHack },
                warning = self._warning,
                completion = self._completion,
                class = "EHITimerTracker"
            })
        end
        if show_waypoint then
            managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
                time = self._timer,
                icon = self._icons or Icon.PCHack,
                position = self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position(),
                warning = self._warning,
                completion = self._completion,
                class = "EHITimerWaypoint"
            })
        end
        self:HideWaypoint()
    end
end

function DigitalGui:HideWaypoint()
    if self._remove_vanilla_waypoint and show_waypoint then
        managers.hud:SoftRemoveWaypoint(self._waypoint_id)
        EHI._cache.IgnoreWaypoints[self._waypoint_id] = true
        EHI:DisableElementWaypoint(self._waypoint_id)
    end
end

function DigitalGui:timer_start_count_down(...)
    original.timer_start_count_down(self, ...)
    self:TimerStartCountDown()
end

if level_id ~= "shoutout_raid" then
    if show_waypoint_only then
        function DigitalGui:_update_timer_text(...)
            managers.ehi_waypoint:SetWaypointTime(self._ehi_key, self._timer)
            original._update_timer_text(self, ...)
        end
    elseif show_waypoint then
        function DigitalGui:_update_timer_text(...)
            managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._timer)
            managers.ehi_waypoint:SetWaypointTime(self._ehi_key, self._timer)
            original._update_timer_text(self, ...)
        end
    else
        function DigitalGui:_update_timer_text(...)
            managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._timer)
            original._update_timer_text(self, ...)
        end
    end
end

if level_id == "chill" then
    original.timer_start_count_up = DigitalGui.timer_start_count_up
    function DigitalGui:timer_start_count_up(...)
        original.timer_start_count_up(self, ...)
        if managers.ehi:TrackerExists(self._ehi_key) then
            managers.ehi:CallFunction(self._ehi_key, "Reset")
        else
            managers.ehi:AddTracker({
                id = self._ehi_key,
                time = 0,
                class = "EHIStopwatchTracker"
            })
        end
    end

    function DigitalGui:timer_pause(...)
        original.timer_pause(self, ...)
        managers.ehi:CallFunction(self._ehi_key, "Stop")
    end
else
    function DigitalGui:timer_pause(...)
        original.timer_pause(self, ...)
        if self._remove_on_pause then
            self:RemoveTracker()
        else
            managers.ehi:SetTimerJammed(self._ehi_key, true)
            managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, true)
            if self._change_icon_on_pause then
                managers.ehi:SetTrackerIcon(self._ehi_key, self._icon_on_pause)
                managers.ehi_waypoint:SetWaypointIcon(self._ehi_key, self._icon_on_pause)
            end
        end
    end
end

function DigitalGui:timer_resume(...)
    original.timer_resume(self, ...)
    managers.ehi:SetTimerJammed(self._ehi_key, false)
    managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, false)
end

local SetTime = nil
if level_id == "shoutout_raid" then
    local old_time = 0
    local created = false
    SetTime = function(self, key, time)
        if old_time == time then
            return
        end
        old_time = time
        if managers.ehi then
            if not created then
                if not show_waypoint_only then
                    managers.ehi:AddTracker({
                        id = key,
                        class = "EHIVaultTemperatureTracker"
                    })
                end
                if show_waypoint then
                    managers.ehi_waypoint:AddWaypoint(key, {
                        time = 500,
                        icon = Icon.Vault,
                        position = self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position(),
                        class = "EHIVaultTemperatureWaypoint"
                    })
                end
                created = true
            end
            local t = EHI:RoundNumber(time, 0.1)
            managers.ehi:CallFunction(key, "CheckTime", t)
            managers.ehi_waypoint:CallFunction(key, "CheckTime", t)
        end
    end
else
    SetTime = function(self, key, time)
        if managers.ehi then
            managers.ehi:SetTrackerTimeNoAnim(key, time)
            managers.ehi_waypoint:SetWaypointTime(key, time)
        end
    end
end

function DigitalGui:timer_set(timer, ...)
    original.timer_set(self, timer, ...)
    SetTime(self, self._ehi_key, timer)
end

function DigitalGui:_timer_stop(...)
    original._timer_stop(self, ...)
    self:RemoveTracker()
end

function DigitalGui:set_visible(visible, ...)
    original.set_visible(self, visible, ...)
    if not visible then
        self:RemoveTracker()
    elseif self._timer_count_down then
        self:TimerStartCountDown()
    end
end

function DigitalGui:RemoveTracker()
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
end

function DigitalGui:load(data, ...)
    local state = data.DigitalGui
    if self:is_timer() and state.timer_count_down then
        self:TimerStartCountDown()
        if state.timer_paused then
            managers.ehi:SetTimerJammed(self._ehi_key, true)
            managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, true)
        end
    end
    original.load(self, data, ...)
end

function DigitalGui:OnAlarm()
    self._ignore = true
    self:RemoveTracker()
end

function DigitalGui:SetIcons(icons)
    self._icons = icons
end

function DigitalGui:SetIconOnPause(icon)
    if icon then
        self._icon_on_pause = icon
        self._change_icon_on_pause = true
    end
end

function DigitalGui:SetIgnore(ignore)
    self._ignore = ignore
end

function DigitalGui:SetRemoveOnPause(remove_on_pause)
    self._remove_on_pause = remove_on_pause
end

function DigitalGui:SetOnAlarm()
    EHI:AddOnAlarmCallback(callback(self, self, "OnAlarm"))
end

function DigitalGui:RemoveVanillaWaypoint(waypoint_id)
    self._remove_vanilla_waypoint = true
    self._waypoint_id = waypoint_id
    if self._timer_count_down then
        self:HideWaypoint()
    end
end

function DigitalGui:SetCustomCallback(id, operation)
    if operation == "remove" then
        EHI:AddCallback(id, callback(self, self, "OnAlarm"))
    end
end

function DigitalGui:SetWarning(warning)
    self._warning = warning
    if self._timer_count_down and warning then
        managers.ehi:CallFunction(self._ehi_key, "SetAnimateWarning")
    end
end

function DigitalGui:SetCompletion(completion)
    self._completion = completion
    if self._timer_count_down and completion then
        managers.ehi:CallFunction(self._ehi_key, "SetAnimateWarning", true)
    end
end

function DigitalGui:SetIgnoreVisibility()
    self._ignore_visibility = true
end

function DigitalGui:Finalize()
    if self._ignore or (self._remove_on_pause and self._timer_paused) then
        self:RemoveTracker()
    elseif self._change_icon_on_pause and self._timer_paused then
        managers.ehi:SetTrackerIcon(self._ehi_key, self._icon_on_pause)
        managers.ehi_waypoint:SetWaypointIcon(self._ehi_key, self._icon_on_pause)
    elseif self._icons then
        managers.ehi:SetTrackerIcon(self._ehi_key, self._icons[1])
        managers.ehi_waypoint:SetWaypointIcon(self._ehi_key, self._icons[1])
    end
end