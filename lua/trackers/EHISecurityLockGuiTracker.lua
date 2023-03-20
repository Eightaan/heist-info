EHISecurityLockGuiTracker = class(EHIProgressTracker)
EHISecurityLockGuiTracker._forced_icons = { "wp_hack" }
function EHISecurityLockGuiTracker:OverridePanel()
    self._time_text = self._time_bg_box:text({
        name = "time_text",
        text = EHISecurityLockGuiTracker.super.super.Format(self),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._icon_size_scaled,
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self._time_text:set_left(self._time_bg_box:right())
end

function EHISecurityLockGuiTracker:SetHackTime(time)
    self._time = time
    local new_w = self._panel:w() * 3
    self:SetPanelW(new_w)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self:FitTheText(self._time_text)
    self._parent_class:ChangeTrackerWidth(self._id, self:GetPanelSize())
    self:SetIconX(self._time_bg_box:w() + self._gap_scaled)
end

function EHISecurityLockGuiTracker:RemoveHack()
    local new_w = self._panel:w() / 3
    self:SetPanelW(new_w)
    self._time_bg_box:set_w(self._time_bg_box:w() / 2)
    self._parent_class:ChangeTrackerWidth(self._id, self:GetPanelSize())
    self:SetIconX(self._time_bg_box:w() + self._gap_scaled)
end

function EHISecurityLockGuiTracker:GetPanelSize()
    return self._time_bg_box:w() + self._icon_gap_size_scaled
end

function EHISecurityLockGuiTracker:SetTimeNoAnim(time) -- No fit text function needed, these timers just run down
    if self._time == time then
        return
    end
    self._time = time
    self._time_text:set_text(EHISecurityLockGuiTracker.super.super.Format(self))
end

function EHISecurityLockGuiTracker:SetPowered(powered)
    self._not_powered = not powered
    self:SetTimeColor()
end

function EHISecurityLockGuiTracker:SetTimeColor()
    self._time_text:set_color(self._not_powered and Color.red or self._text_color)
end