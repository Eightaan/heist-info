EHIProgressTracker = class(EHITracker)
EHIProgressTracker.update = EHIProgressTracker.update_fade
EHIProgressTracker._update = false
function EHIProgressTracker:init(panel, params)
    self._max = params.max or 0
    self._progress = params.progress or 0
    self._flash = not params.dont_flash
    self._flash_max = not params.dont_flash_max
    self._remove_after_reaching_counter_target = params.remove_after_reaching_target ~= false
    self._set_color_bad_when_reached = params.set_color_bad_when_reached
    self._flash_times = params.flash_times or 3
    self._status_is_overridable = params.status_is_overridable
    EHIProgressTracker.super.init(self, panel, params)
end

function EHIProgressTracker:Format()
    return self._progress .. "/" .. self._max
end

function EHIProgressTracker:SetProgressMax(max)
    self._max = max
    self._text:set_text(self:Format())
    self:FitTheText()
    if self._flash_max then
        self:AnimateBG(self._flash_times)
    end
end

function EHIProgressTracker:IncreaseProgressMax(progress)
    self:SetProgressMax(self._max + (progress or 1))
end

function EHIProgressTracker:DecreaseProgressMax(progress)
    self:SetProgressMax(self._max - (progress or 1))
end

function EHIProgressTracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._text:set_text(self:Format())
        self:FitTheText()
        if self._flash then
            self:AnimateBG(self._flash_times)
        end
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
    self:SetTextColor()
    self._disable_counting = false
end

function EHIProgressTracker:SetProgressRemaining(remaining)
    self:SetProgress(self._max - remaining)
end

function EHIProgressTracker:SetCompleted(force)
    if not self._status or force then
        self._status = "completed"
        self:SetTextColor(Color.green)
        if self._remove_after_reaching_counter_target or force then
            self:AddTrackerToUpdate()
        else
            self:SetStatusText("finish")
        end
        self._disable_counting = true
    end
end

function EHIProgressTracker:SetBad()
    self:SetTextColor(tweak_data.ehi.color.Inaccurate)
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
    self:SetTextColor(Color.red)
    self._status = "failed"
    self:AddTrackerToUpdate()
    self:AnimateBG()
    self._disable_counting = true
end

function EHIProgressTracker:GetProgress()
    return self._progress
end