EHIPausableWaypoint = class(EHIWaypoint)
function EHIPausableWaypoint:init(waypoint, params, parent_class)
    EHIPausableWaypoint.super.init(self, waypoint, params, parent_class)
    self._paused = params.paused
    self:SetColor()
end

function EHIPausableWaypoint:update(t, dt)
    if self._paused then
        return
    end
    EHIPausableWaypoint.super.update(self, t, dt)
end

function EHIPausableWaypoint:SetPaused(pause)
    self._paused = pause
    self:SetColor()
end

function EHIPausableWaypoint:SetColor(color)
    color = self._paused and Color.red or (color or self._default_color)
    EHIPausableWaypoint.super.SetColor(self, color)
end