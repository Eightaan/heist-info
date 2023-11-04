---@class EHIMeleeChargeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIMeleeChargeBuffTracker = class(EHIBuffTracker)
EHIMeleeChargeBuffTracker._inverted_progress = true
local string_format = string.format
function EHIMeleeChargeBuffTracker:update(t, dt)
    self._time = self._time - dt
    self._hint:set_text(self:Format())
    local progress = 1 - (self._time / self._time_set)
    self._text:set_text(string_format("%.0d%%", progress * 100))
    self._progress_bar.red = progress
    self._progress:set_color(self._progress_bar)
    if self._time <= 0 then
        self:RemoveBuffFromUpdate()
        self._hint:set_text("")
    end
end

function EHIMeleeChargeBuffTracker:Activate(t, pos)
    self._text:set_text("0%")
    self._progress_bar.red = 0
    self._progress:set_color(self._progress_bar)
    EHIMeleeChargeBuffTracker.super.Activate(self, t, pos)
    self._hint:set_text(self:Format())
end