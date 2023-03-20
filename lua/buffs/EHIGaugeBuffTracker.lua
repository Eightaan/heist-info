local Color = Color
local lerp = math.lerp
local function anim(o, ratio)
    local r = o:color().red
    over(0.25, function(p, t)
        local l = lerp(r, ratio, p)
        o:set_color(Color(1, l, 1, 1))
    end)
end
EHIGaugeBuffTracker = class(EHIBuffTracker)
EHIGaugeBuffTracker._inverted_progress = true
function EHIGaugeBuffTracker:init(panel, params)
    self._ratio = 0
    self._format = params.format or "standard"
    EHIGaugeBuffTracker.super.init(self, panel, params)
end

function EHIGaugeBuffTracker:Activate(ratio, pos)
    self._active = true
    self:SetRatio(ratio)
    self._panel:stop()
    self._panel:animate(self._show)
    self._pos = pos
end

function EHIGaugeBuffTracker:Activate2(ratio, custom_value, pos)
    self._active = true
    self:SetRatio2(ratio, custom_value)
    self._panel:stop()
    self._panel:animate(self._show)
    self._pos = pos
end

function EHIGaugeBuffTracker:Deactivate()
    EHIGaugeBuffTracker.super.Deactivate(self)
    self._progress:set_color(Color(1, 0, 1, 1)) -- No need to animate this because the panel is no longer visible
end

function EHIGaugeBuffTracker:SetRatio(ratio)
    self._ratio = ratio
    self._text:set_text(self:Format())
    self:FitTheText()
    self._progress:stop()
    self._progress:animate(anim, self._ratio)
end

function EHIGaugeBuffTracker:SetRatio2(ratio, custom_value)
    self._ratio = ratio
    self._text:set_text(self:FormatCustom(custom_value))
    self:FitTheText()
    self._progress:stop()
    self._progress:animate(anim, self._ratio)
end

function EHIGaugeBuffTracker:FitTheText()
    local w = select(3, self._text:text_rect())
    if w > self._text:w() then
        self._text:set_font_size(self._text:font_size() * (self._text:w() / w))
    end
end

function EHIGaugeBuffTracker:Format()
    if self._format == "percent" then
        return tostring(self._ratio * 100) .. "%"
    elseif self._format == "multiplier" then
        return self._ratio .. "x"
    end
    return tostring(self._ratio)
end

function EHIGaugeBuffTracker:FormatCustom(value)
    if self._format == "percent" then
        return tostring(value * 100) .. "%"
    elseif self._format == "multiplier" then
        return value .. "x"
    end
    return tostring(value)
end