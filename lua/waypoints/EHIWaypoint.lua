EHIWaypoint = class()
EHIWaypoint._update = true
EHIWaypoint._default_color = Color.white
function EHIWaypoint:init(waypoint, params, parent_class)
    self._id = params.id
    self._time = params.time
    self._timer = waypoint.timer_gui
    self._bitmap = waypoint.bitmap
    self._arrow = waypoint.arrow
    self._bitmap_world = waypoint.bitmap_world -- VR
    self._parent_class = parent_class
end

if EHI:GetOption("time_format") == 1 then
    EHIWaypoint.Format = tweak_data.ehi.functions.FormatSecondsOnly
else
    EHIWaypoint.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
end

function EHIWaypoint:update(t, dt)
    self._time = self._time - dt
    self._timer:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

function EHIWaypoint:SetTime(t)
    self._time = t
    self._timer:set_text(self:Format())
end

function EHIWaypoint:SetColor(color)
    self._timer:set_color(color)
    self._bitmap:set_color(color)
    self._arrow:set_color(color)
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
end

if _G.IS_VR then
    EHIWaypointVR = EHIWaypoint
    EHIWaypointVR.old_SetColor = EHIWaypoint.SetColor
    function EHIWaypointVR:SetColor(color)
        self:old_SetColor(color)
        self._bitmap_world:set_color(color)
    end
end