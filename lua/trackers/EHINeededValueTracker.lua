EHINeededValueTracker = class(EHIProgressTracker)
EHINeededValueTracker._update = false
function EHINeededValueTracker:init(panel, params)
    self._secured = 0
    self._secured_formatted = "0"
    self._to_secure = params.to_secure or 0
    self._to_secure_formatted = self:FormatNumber(self._to_secure)
    EHINeededValueTracker.super.init(self, panel, params)
end

function EHINeededValueTracker:OverridePanel()
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._text:set_w(self._time_bg_box:w())
    self:FitTheText()
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHINeededValueTracker:Format()
    return "$" .. self._secured_formatted .. "/$" .. self._to_secure_formatted
end

function EHINeededValueTracker:FormatNumber(n)
    local divisor = 1
    local post_fix = ""
    if n >= 1000000 then
        divisor = 1000000
        post_fix = "M"
    elseif n >= 1000 then
        divisor = 1000
        post_fix = "K"
    end
    return tostring(n / divisor) .. post_fix
end

function EHINeededValueTracker:SetProgress(progress)
    if self._secured ~= progress and not self._disable_counting then
        self._secured = progress
        self._secured_formatted = self:FormatNumber(progress)
        self._text:set_text(self:Format())
        self:FitTheText()
        if self._flash then
            self:AnimateBG(self._flash_times)
        end
        if self._secured >= self._to_secure then
            self:SetCompleted()
        end
    end
end

function EHINeededValueTracker:IncreaseProgress(progress)
    self:SetProgress(self._secured + (progress or 1))
end

function EHINeededValueTracker:SetCompleted(force)
    if force or not self._status then
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

function EHINeededValueTracker:SetFailed()
    if self._status and not self._status_is_overridable then
        return
    end
    self:SetTextColor(Color.red)
    self._status = "failed"
    self:AddTrackerToUpdate()
    self:AnimateBG()
    self._disable_counting = true
end