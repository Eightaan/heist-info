---@class EHIWaypoint
---@field new fun(waypoint: WaypointDataTable, params: table, parent_class: EHIWaypointManager): self
---@field _parent_class EHIWaypointManager
---@field _timer PanelText
---@field _bitmap PanelBitmap
---@field _arrow PanelBitmap
---@field _bitmap_world PanelBitmap
EHIWaypoint = class()
EHIWaypoint._update = true
EHIWaypoint._fade_time = 5
EHIWaypoint._default_color = Color.white
function EHIWaypoint:init(waypoint, params, parent_class)
    self:pre_init(params)
    self._id = params.id
    self._time = params.time or 0
    self._timer = waypoint.timer_gui
    self._bitmap = waypoint.bitmap
    self._arrow = waypoint.arrow
    self._bitmap_world = waypoint.bitmap_world -- VR
    self._parent_class = parent_class
    self:post_init(params)
end

function EHIWaypoint:pre_init(params)
end

function EHIWaypoint:post_init(params)
end

function EHIWaypoint:UpdateID(new_id)
    self._id = new_id
end

if EHI:GetOption("time_format") == 1 then
    EHIWaypoint.Format = tweak_data.ehi.functions.FormatSecondsOnly
else
    EHIWaypoint.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
end

function EHIWaypoint:ForceFormat()
    self._timer:set_text(self:Format())
end

function EHIWaypoint:WaypointToRestore(id)
    self._vanilla_waypoint = id
end

function EHIWaypoint:update(t, dt)
    self._time = self._time - dt
    self._timer:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

function EHIWaypoint:update_fade(t, dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

function EHIWaypoint:SetTime(t)
    self._time = t
    self._timer:set_text(self:Format())
end

function EHIWaypoint:SetColor(color)
    local c = color or self._default_color
    self._timer:set_color(c)
    self._bitmap:set_color(c)
    self._arrow:set_color(c)
end

function EHIWaypoint:AddWaypointToUpdate()
    self._parent_class:AddWaypointToUpdate(self._id, self)
end

function EHIWaypoint:RemoveWaypointFromUpdate()
    self._parent_class:RemoveWaypointFromUpdate(self._id)
end

function EHIWaypoint:delete()
    self._parent_class:RemoveWaypoint(self._id)
end

function EHIWaypoint:destroy()
    if self._vanilla_waypoint then
        self._parent_class:RestoreVanillaWaypoint(self._vanilla_waypoint)
    end
end

if EHI:IsVR() then
    EHIWaypointVR = EHIWaypoint
    EHIWaypointVR.old_SetColor = EHIWaypoint.SetColor
    function EHIWaypointVR:SetColor(color)
        self:old_SetColor(color)
        self._bitmap_world:set_color(color or self._default_color)
    end
end