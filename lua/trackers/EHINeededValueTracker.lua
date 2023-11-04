---@class EHINeededValueTracker : EHIProgressTracker
---@field super EHIProgressTracker
EHINeededValueTracker = class(EHIProgressTracker)
function EHINeededValueTracker:pre_init(params)
    EHINeededValueTracker.super.pre_init(self, params)
    if params.short_format then
        self.FormatNumber = self.FormatNumberShort
        self._cash_sign = managers.localization:text("cash_sign")
    end
    self._progress_formatted = self:FormatNumber(0)
    self._max_formatted = self:FormatNumber(self._max)
end

function EHINeededValueTracker:OverridePanel()
    self:SetBGSize()
    self._text:set_w(self._bg_box:w())
    self:FitTheText()
    self:SetIconX()
end

function EHINeededValueTracker:Format()
    return self._progress_formatted .. "/" .. self._max_formatted
end

function EHINeededValueTracker:FormatNumber(n)
    return managers.experience:cash_string(n)
end

function EHINeededValueTracker:FormatNumberShort(n)
    local divisor = 1
    local post_fix = ""
    if n >= 1000000000 then
        divisor = 1000000000
        post_fix = "B"
    elseif n >= 1000000 then
        divisor = 1000000
        post_fix = "M"
    elseif n >= 1000 then
        divisor = 1000
        post_fix = "K"
    end
    return string.format("%s%s%s", self._cash_sign, tostring(n / divisor), post_fix)
end

function EHINeededValueTracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_formatted = self:FormatNumber(progress)
        self._text:set_text(self:Format())
        self:FitTheText()
        self:AnimateBG()
        if self._progress >= self._max then
            self:SetCompleted()
        end
    end
end
EHINeededValueTracker.FormatProgress = EHINeededValueTracker.Format