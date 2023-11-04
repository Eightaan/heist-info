---@class EHIProgressWaypoint : EHIWaypoint, EHIProgressTracker
---@field super EHIWaypoint
EHIProgressWaypoint = class(EHIWaypoint)
EHIProgressWaypoint._update = false
EHIProgressWaypoint.Format = EHIProgressTracker.Format
EHIProgressWaypoint.FormatProgress = EHIProgressTracker.FormatProgress
EHIProgressWaypoint.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIProgressWaypoint.IncreaseProgressMax = EHIProgressTracker.IncreaseProgressMax
EHIProgressWaypoint.DecreaseProgressMax = EHIProgressTracker.DecreaseProgressMax
function EHIProgressWaypoint:pre_init(params)
    self._max = params.max or 0
    self._progress = params.progress or 0
end

function EHIProgressWaypoint:post_init(params)
    self:ForceFormat()
end

function EHIProgressTracker:DecreaseProgress(progress)
    self:SetProgress(self._progress - (progress or 1))
    self._disable_counting = false
end

function EHIProgressWaypoint:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._timer:set_text(self:Format())
        if self._progress == self._max then
            self:SetCompleted()
        end
    end
end

function EHIProgressWaypoint:SetCompleted()
    self:SetColor(Color.green)
    self.update = self.update_fade
    self:AddWaypointToUpdate()
end