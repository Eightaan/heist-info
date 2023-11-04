---@class EHIProgressTracker : EHITracker
---@field super EHITracker
EHIProgressTracker = class(EHITracker)
EHIProgressTracker.update = EHIProgressTracker.update_fade
EHIProgressTracker._progress_bad = Color(255, 255, 165, 0) / 255
EHIProgressTracker._update = false
function EHIProgressTracker:pre_init(params)
    self._max = params.max or 0
    self._progress = params.progress or 0
    self._show_finish_after_reaching_target = params.show_finish_after_reaching_target or params.show_progress_on_finish
    self._set_color_bad_when_reached = params.set_color_bad_when_reached
    self._status_is_overridable = params.status_is_overridable
    self._show_progress_on_finish = params.show_progress_on_finish
end

function EHIProgressTracker:post_init(params)
    self._progress_text = self._text
end

function EHIProgressTracker:Format()
    return self._progress .. "/" .. self._max
end

function EHIProgressTracker:SetProgressMax(max)
    self._max = max
    self._progress_text:set_text(self:FormatProgress())
    self:FitTheText(self._progress_text)
    self:AnimateBG()
end

function EHIProgressTracker:IncreaseProgressMax(max)
    self:SetProgressMax(self._max + (max or 1))
end

function EHIProgressTracker:DecreaseProgressMax(max)
    self:SetProgressMax(self._max - (max or 1))
end

function EHIProgressTracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_text:set_text(self:FormatProgress())
        self:FitTheText(self._progress_text)
        self:AnimateBG()
        if self._progress == self._max then
            if self._set_color_bad_when_reached then
                self:SetBad()
            else
                self:SetCompleted()
            end
        end
    end
end

function EHIProgressTracker:IncreaseProgress(progress)
    self:SetProgress(self._progress + (progress or 1))
end

function EHIProgressTracker:DecreaseProgress(progress)
    self:SetProgress(self._progress - (progress or 1))
    self:SetTextColor(nil, self._progress_text)
    self._disable_counting = false
end

function EHIProgressTracker:SetProgressRemaining(remaining)
    self:SetProgress(self._max - remaining)
end

function EHIProgressTracker:SetCompleted(force)
    if force or not self._status then
        self._status = "completed"
        self:SetTextColor(Color.green, self._progress_text)
        if force or not self._show_finish_after_reaching_target then
            self:AddTrackerToUpdate()
        elseif not self._show_progress_on_finish then
            self:SetStatusText("finish")
        end
        self._disable_counting = true
    end
end

function EHIProgressTracker:SetBad()
    self:SetTextColor(self._progress_bad, self._progress_text)
end

function EHIProgressTracker:Finalize()
    if self._progress == self._max then
        self:SetCompleted(true)
    else
        self:SetFailed()
    end
end

function EHIProgressTracker:SetFailed()
    if self._status and not self._status_is_overridable then
        return
    end
    self:SetTextColor(Color.red, self._progress_text)
    self._status = "failed"
    self:AddTrackerToUpdate()
    self:AnimateBG()
    self._disable_counting = true
end

function EHIProgressTracker:GetProgress()
    return self._progress
end
EHIProgressTracker.FormatProgress = EHIProgressTracker.Format