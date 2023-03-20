EHIPausableTracker = class(EHITracker)
function EHIPausableTracker:init(panel, params)
    EHIPausableTracker.super.init(self, panel, params)
    self._paused = params.paused
    self:SetTextColor()
end

function EHIPausableTracker:update(t, dt)
    if self._paused then
        return
    end
    EHIPausableTracker.super.update(self, t, dt)
end

function EHIPausableTracker:SetPause(pause)
    self._paused = pause
    self:SetTextColor()
end

function EHIPausableTracker:SetTextColor(color)
    self._text:set_color(self._paused and Color.red or (color or self._text_color))
end