---@class EHIColoredCodesTracker : EHITracker
---@field super EHITracker
EHIColoredCodesTracker = class(EHITracker)
EHIColoredCodesTracker._update = false
EHIColoredCodesTracker._forced_icons = { EHI.Icons.Interact }
function EHIColoredCodesTracker:OverridePanel()
    local third = self._bg_box:w() / 3
    self._bg_box:remove(self._text)
    self._text = self:CreateText({
        name = "red",
        text = "?",
        w = third,
        h = self._icon_size_scaled,
        color = Color.red
    })
    self._text:set_left(0)
    self._text2 = self:CreateText({
        name = "green",
        text = "?",
        w = third,
        h = self._icon_size_scaled,
        color = Color.green
    })
    self._text2:set_left(self._text:right())
    self._text3 = self:CreateText({
        name = "blue",
        text = "?",
        w = third,
        h = self._icon_size_scaled,
        color = Color(0, 1, 1) -- Aqua
    })
    self._text3:set_left(self._text2:right())
end

function EHIColoredCodesTracker:Format(code)
    if not code then
        return "?"
    end
    return tostring(code)
end

function EHIColoredCodesTracker:SetCode(color, code)
    local text = self._bg_box:child(color) --[[@as PanelText]]
    text:set_text(self:Format(code))
    self:FitTheText(text)
    self:AnimateBG()
end