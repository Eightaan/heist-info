EHIMeleeChargeBuffTracker = class(EHIBuffTracker)
EHIMeleeChargeBuffTracker._inverted_progress = true
local string_format = string.format
local Color = Color
function EHIMeleeChargeBuffTracker:update(t, dt)
    self._time = self._time - dt
    self._hint:set_text(self:Format())
    local progress = 1 - (self._time / self._time_set)
    self._text:set_text(string_format("%.0d%%", progress * 100))
    self._progress:set_color(Color(1, progress, 1, 1))
    if self._time <= 0 then
        self._parent_class:RemoveBuffFromUpdate(self._id)
        self._hint:set_text("")
    end
end

function EHIMeleeChargeBuffTracker:Activate(t, pos)
    self._text:set_text("0%")
    self._progress:set_color(Color(1, 0, 1, 1))
    EHIMeleeChargeBuffTracker.super.Activate(self, t, pos)
    self._hint:set_text(self:Format())
end