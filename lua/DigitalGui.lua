local EHI = EHI
if EHI:CheckLoadHook("DigitalGui") or not EHI:GetOption("show_timers") then
    return
end

---@class DigitalGui
---@field _unit UnitDigitalTimer
---@field _visible boolean
---@field _timer number
---@field _timer_count_down boolean
---@field _timer_paused boolean
---@field is_timer fun(): boolean

local Icon = EHI.Icons

local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_timers")

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

---@param unit UnitDigitalTimer
function DigitalGui:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._ignore_visibility = false
    if not show_waypoint_only then
        EHI:OptionAndLoadTracker("show_timers")
    end
end

function DigitalGui:TimerStartCountDown()
    if (self._ignore or not self._visible) and not self._ignore_visibility then
        return
    end
    if managers.ehi_manager:Exists(self._ehi_key) then
        managers.ehi_manager:SetTimerJammed(self._ehi_key, false)
    else
        if not show_waypoint_only then
            managers.ehi_tracker:AddTracker({
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
                position = self._unit:position(),
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
        managers.hud:SoftRemoveWaypoint(self._remove_vanilla_waypoint)
        EHI._cache.IgnoreWaypoints[self._remove_vanilla_waypoint] = true
        EHI:DisableElementWaypoint(self._remove_vanilla_waypoint)
    end
end

function DigitalGui:timer_start_count_down(...)
    original.timer_start_count_down(self, ...)
    self:TimerStartCountDown()
end

if level_id == "shoutout_raid" then
    local old_time = 0
    local created = false
    ---@param timer number
    function DigitalGui:timer_set(timer, ...)
        original.timer_set(self, timer, ...)
        if old_time == timer then
            return
        end
        old_time = timer
        if not created then
            if not show_waypoint_only then
                managers.ehi_tracker:AddTracker({
                    id = self._ehi_key,
                    class = "EHIVaultTemperatureTracker"
                })
            end
            if show_waypoint then
                managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
                    time = 500,
                    icon = Icon.Vault,
                    position = self._unit:position(),
                    class = "EHIVaultTemperatureWaypoint"
                })
            end
            created = true
        end
        local t = EHI:RoundNumber(timer, 0.1)
        managers.ehi_manager:Call(self._ehi_key, "CheckTime", t)
    end
else
    if show_waypoint_only then
        function DigitalGui:_update_timer_text(...)
            managers.ehi_waypoint:SetWaypointTime(self._ehi_key, self._timer)
            original._update_timer_text(self, ...)
        end
    elseif show_waypoint then
        function DigitalGui:_update_timer_text(...)
            managers.ehi_manager:UpdateTimer(self._ehi_key, self._timer)
            original._update_timer_text(self, ...)
        end
    else
        function DigitalGui:_update_timer_text(...)
            managers.ehi_tracker:SetTrackerTimeNoAnim(self._ehi_key, self._timer)
            original._update_timer_text(self, ...)
        end
    end
    ---@param timer number
    function DigitalGui:timer_set(timer, ...)
        original.timer_set(self, timer, ...)
        managers.ehi_tracker:SetTrackerTimeNoAnim(self._ehi_key, timer)
        managers.ehi_waypoint:SetWaypointTime(self._ehi_key, timer)
    end
end

if level_id == "chill" then
    original.timer_start_count_up = DigitalGui.timer_start_count_up
    function DigitalGui:timer_start_count_up(...)
        original.timer_start_count_up(self, ...)
        if managers.ehi_tracker:TrackerExists(self._ehi_key) then
            managers.ehi_tracker:CallFunction(self._ehi_key, "Reset")
        else
            managers.ehi_tracker:AddTracker({
                id = self._ehi_key,
                time = 0,
                class = "EHIStopwatchTracker"
            })
        end
    end

    function DigitalGui:timer_pause(...)
        original.timer_pause(self, ...)
        managers.ehi_tracker:CallFunction(self._ehi_key, "Stop")
    end
else
    function DigitalGui:timer_pause(...)
        original.timer_pause(self, ...)
        if self._remove_on_pause then
            self:RemoveTracker()
        else
            managers.ehi_manager:SetTimerJammed(self._ehi_key, true)
            if self._change_icon_on_pause then
                managers.ehi_manager:SetIcon(self._ehi_key, self._icon_on_pause)
            end
        end
    end
end

function DigitalGui:timer_resume(...)
    original.timer_resume(self, ...)
    managers.ehi_manager:SetTimerJammed(self._ehi_key, false)
end

function DigitalGui:_timer_stop(...)
    original._timer_stop(self, ...)
    self:RemoveTracker()
end

---@param visible boolean
function DigitalGui:set_visible(visible, ...)
    original.set_visible(self, visible, ...)
    if not visible then
        self:RemoveTracker()
    elseif self._timer_count_down then
        self:TimerStartCountDown()
    end
end

function DigitalGui:RemoveTracker()
    managers.ehi_manager:Remove(self._ehi_key)
end

---@param data table
function DigitalGui:load(data, ...)
    local state = data.DigitalGui
    if self:is_timer() and state.timer_count_down then
        self:TimerStartCountDown()
        if state.timer_paused then
            managers.ehi_manager:SetTimerJammed(self._ehi_key, true)
        end
    end
    original.load(self, data, ...)
end

function DigitalGui:OnAlarm()
    self._ignore = true
    self:RemoveTracker()
end

---@param icons table
function DigitalGui:SetIcons(icons)
    self._icons = icons
end

---@param icon string
function DigitalGui:SetIconOnPause(icon)
    if icon then
        self._icon_on_pause = icon
        self._change_icon_on_pause = true
    end
end

---@param ignore boolean
function DigitalGui:SetIgnore(ignore)
    self._ignore = ignore
end

---@param remove_on_pause boolean
function DigitalGui:SetRemoveOnPause(remove_on_pause)
    self._remove_on_pause = remove_on_pause
end

function DigitalGui:SetOnAlarm()
    EHI:AddOnAlarmCallback(callback(self, self, "OnAlarm"))
end

---@param waypoint_id number
function DigitalGui:RemoveVanillaWaypoint(waypoint_id)
    self._remove_vanilla_waypoint = waypoint_id
    if self._timer_count_down then
        self:HideWaypoint()
    end
end

---@param id number|string
---@param operation string
function DigitalGui:SetCustomCallback(id, operation)
    if operation == "remove" then
        EHI:AddCallback(id, callback(self, self, "OnAlarm"))
    end
end

---@param warning boolean
function DigitalGui:SetWarning(warning)
    self._warning = warning
    if self._timer_count_down and warning then
        managers.ehi_tracker:CallFunction(self._ehi_key, "SetAnimation")
    end
end

---@param completion boolean
function DigitalGui:SetCompletion(completion)
    self._completion = completion
    if self._timer_count_down and completion then
        managers.ehi_tracker:CallFunction(self._ehi_key, "SetAnimation", true)
    end
end

function DigitalGui:SetIgnoreVisibility()
    self._ignore_visibility = true
end

function DigitalGui:Finalize()
    if self._ignore or (self._remove_on_pause and self._timer_paused) then
        self:RemoveTracker()
    elseif self._change_icon_on_pause and self._timer_paused then
        managers.ehi_manager:SetIcon(self._ehi_key, self._icon_on_pause)
    elseif self._icons then
        managers.ehi_manager:SetIcon(self._ehi_key, self._icons[1])
    end
end