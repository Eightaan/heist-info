---@class EHIPausableTracker : EHITracker
---@field super EHITracker
EHIPausableTracker = class(EHITracker)
EHIPausableTracker._paused_color = EHI:GetTWColor("pause")
---@param panel Panel
---@param params EHITracker_params
function EHIPausableTracker:init(panel, params)
    EHIPausableTracker.super.init(self, panel, params)
    self._update = not params.paused
    self:_SetPause(not self._update)
end

function EHIPausableTracker:SetPause(pause)
    self:_SetPause(pause)
    if pause then
        self:RemoveTrackerFromUpdate()
    else
        self:AddTrackerToUpdate()
    end
end

function EHIPausableTracker:_SetPause(pause)
    self._paused = pause
    self:SetTextColor()
end

function EHIPausableTracker:SetTextColor(color)
    self._text:set_color(self._paused and self._paused_color or (color or self._text_color))
end