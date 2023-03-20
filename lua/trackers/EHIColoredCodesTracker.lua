EHIColoredCodesTracker = class(EHITracker)
EHIColoredCodesTracker._update = false
EHIColoredCodesTracker._forced_icons = { EHI.Icons.Interact }
function EHIColoredCodesTracker:OverridePanel()
    local third = self._time_bg_box:w() / 3
    self._time_bg_box:remove(self._text)
    self._text = self._time_bg_box:text({
        name = "red",
        text = "?",
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._icon_size_scaled,
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = Color.red
    })
    self._text:set_w(third)
    self._text:set_left(0)
    self._text2 = self._time_bg_box:text({
        name = "green",
        text = "?",
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._icon_size_scaled,
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = Color.green
    })
    self._text2:set_w(third)
    self._text2:set_left(self._text:right())
    self._text3 = self._time_bg_box:text({
        name = "blue",
        text = "?",
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._icon_size_scaled,
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = Color(0, 1, 1) -- Aqua
    })
    self._text3:set_w(third)
    self._text3:set_left(self._text2:right())
end

function EHIColoredCodesTracker:Format(code)
    if not code then
        return "?"
    end
    return tostring(code)
end

function EHIColoredCodesTracker:SetCode(color, code)
    local text = self._time_bg_box:child(color)
    text:set_text(self:Format(code))
    self:FitTheText(text)
    self:AnimateBG()
end