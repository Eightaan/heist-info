local lerp = math.lerp
---@param o PanelBitmap
---@param ratio number
---@param progress Color
local function anim(o, ratio, progress)
    local r = progress.red
    over(0.25, function(p, t)
        progress.red = lerp(r, ratio, p)
        o:set_color(progress)
    end)
end
---@class EHIGaugeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIGaugeBuffTracker = class(EHIBuffTracker)
EHIGaugeBuffTracker._inverted_progress = true
function EHIGaugeBuffTracker:init(panel, params)
    self._ratio = 0
    self._format = params.format or "standard"
    EHIGaugeBuffTracker.super.init(self, panel, params)
end

function EHIGaugeBuffTracker:Activate(ratio, custom_value, pos)
    self._active = true
    self:SetRatio(ratio, custom_value)
    self._panel:stop()
    self._panel:animate(self._show)
    self._pos = pos
end

function EHIGaugeBuffTracker:Deactivate()
    EHIGaugeBuffTracker.super.Deactivate(self)
    self._progress_bar.red = 0 -- No need to animate this because the panel is no longer visible
    self._progress:set_color(self._progress_bar)
end

---@param ratio number
---@param custom_value number?
function EHIGaugeBuffTracker:SetRatio(ratio, custom_value)
    if self._ratio == ratio then
        return
    end
    self._ratio = ratio
    self._text:set_text(self:Format(custom_value))
    self:FitTheText(self._text)
    self._progress:stop()
    self._progress:animate(anim, self._ratio, self._progress_bar)
end

---@param value number?
---@return string
function EHIGaugeBuffTracker:Format(value)
    value = value or self._ratio
    if self._format == "percent" then
        return tostring(value * 100) .. "%"
    elseif self._format == "multiplier" then
        return value .. "x"
    elseif self._format == "damage" then
        return tostring(value * 10)
    end
    return tostring(value)
end