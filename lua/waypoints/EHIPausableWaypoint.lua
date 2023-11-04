---@class EHIPausableWaypoint: EHIWaypoint
---@field super EHIWaypoint
EHIPausableWaypoint = class(EHIWaypoint)
EHIPausableWaypoint._paused_color = EHI:GetTWColor("pause")
function EHIPausableWaypoint:post_init(params)
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
    color = self._paused and self._paused_color or (color or self._default_color)
    EHIPausableWaypoint.super.SetColor(self, color)
end