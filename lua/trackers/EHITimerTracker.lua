local EHI = EHI
local Color = Color
---@class EHITimerTracker : EHIWarningTracker
---@field super EHIWarningTracker
---@field _icon2 PanelBitmap?
---@field _icon3 PanelBitmap?
---@field _icon4 PanelBitmap?
---@field _bg_box_w number Inherited class needs to populate this field
---@field _bg_box_double number Inherited class needs to populate this field
---@field _panel_w number Inherited class needs to populate this field
---@field _panel_double number Inherited class needs to populate this field
EHITimerTracker = class(EHIWarningTracker)
EHITimerTracker._update = false
EHITimerTracker._autorepair_color = EHI:GetTWColor("drill_autorepair")
EHITimerTracker._paused_color = EHIPausableTracker._paused_color
function EHITimerTracker:pre_init(params)
    if params.icons[1].icon then
        params.icons[2] = { icon = "faster", visible = false, alpha = 0.25 }
        params.icons[3] = { icon = "silent", visible = false, alpha = 0.25 }
        params.icons[4] = { icon = "restarter", visible = false, alpha = 0.25 }
    end
end

function EHITimerTracker:post_init(params)
    self._theme = params.theme
    self:SetUpgradeable(false)
    self._paused = false
    self._jammed = false
    self._not_powered = false
    if params.upgrades then
        self:SetUpgradeable(true)
        self:SetUpgrades(params.upgrades)
    end
    self:SetAutorepair(params.autorepair)
    self._animate_warning = params.warning
    if params.completion then
        self._animate_warning = true
        self._show_completion_color = true
    end
end

function EHITimerTracker:SetTimeNoAnim(time) -- No fit text function needed, these timers just run down
    self._time = time
    self._text:set_text(self:Format())
    if time <= 10 and self._animate_warning and not self._anim_started then
        self._anim_started = true
        self:AnimateColor()
    end
end

function EHITimerTracker:SetTimeNoFormat(t, time) -- No fit text function needed, these timers just run down
    self._time = t
    self._text:set_text(time)
    if t <= 10 and self._animate_warning and not self._anim_started then
        self._anim_started = true
        self:AnimateColor()
    end
end

function EHITimerTracker:SetAnimation(completion)
    self._animate_warning = true
    if completion then
        self._show_completion_color = true
    end
    if self._time <= 10 and not self._anim_started then
        self._anim_started = true
        self:AnimateColor(true)
    end
end

function EHITimerTracker:SetUpgradeable(upgradeable)
    self._upgradeable = upgradeable
    if self._icon2 then
        self._icon2:set_visible(upgradeable)
        self._icon3:set_visible(upgradeable)
        self._icon4:set_visible(upgradeable)
    end
    if upgradeable then
        self._panel_override_w = self._panel:w()
    else
        self._panel_override_w = self._bg_box:w() + self._icon_gap_size_scaled
    end
end

function EHITimerTracker:SetUpgrades(upgrades)
    if not (self._upgradeable and upgrades) then
        return
    end
    local icon_definition =
    {
        faster = 2,
        silent = 3,
        restarter = 4
    }
    for upgrade, level in pairs(upgrades) do
        if level > 0 then
            local icon = self["_icon" .. tostring(icon_definition[upgrade])]
            if icon then
                icon:set_color(self:GetUpgradeColor(level))
                icon:set_alpha(1)
            end
        end
    end
end

function EHITimerTracker:GetUpgradeColor(level)
    if not self._theme then
        return TimerGui.upgrade_colors["upgrade_color_" .. level]
    end
    local theme = TimerGui.themes[self._theme]
    return theme and theme["upgrade_color_" .. level] or TimerGui.upgrade_colors["upgrade_color_" .. level]
end

function EHITimerTracker:SetAutorepair(state)
    self._icon1:set_color(state and self._autorepair_color or Color.white)
end

function EHITimerTracker:SetJammed(jammed)
    if self._anim_started then
        self._text:stop()
        self._anim_started = false
    end
    self._jammed = jammed
    self:SetTextColor()
end

function EHITimerTracker:SetPowered(powered)
    if self._anim_started then
        self._text:stop()
        self._anim_started = false
    end
    self._not_powered = not powered
    self:SetTextColor()
end

function EHITimerTracker:SetTextColor()
    if self._jammed or self._not_powered then
        self._text:set_color(self._paused_color)
    else
        self._text:set_color(Color.white)
        if self._time <= 10 and self._animate_warning and not self._anim_started then
            self._anim_started = true
            self:AnimateColor(true)
        end
    end
end

function EHITimerTracker:StartTimer(t)
    self:SetTimeNoAnim(t)
    self:AnimatePanelW(self._panel_double)
    self:ChangeTrackerWidth(self._bg_box_double + self._icon_gap_size_scaled)
    self:AnimIconX(self._bg_box_double + self._gap_scaled)
    self._bg_box:set_w(self._bg_box_double)
end

function EHITimerTracker:StopTimer()
    self:AnimatePanelW(self._panel_w)
    self:ChangeTrackerWidth(self._bg_box_w + self._icon_gap_size_scaled)
    self:AnimIconX(self._bg_box_w + self._gap_scaled)
    self._bg_box:set_w(self._bg_box_w)
end

---@class EHIProgressTimerTracker : EHITimerTracker, EHIProgressTracker
---@field super EHITimerTracker
EHIProgressTimerTracker = class(EHITimerTracker)
EHIProgressTimerTracker.pre_init = EHIProgressTracker.pre_init
EHIProgressTimerTracker.update = EHIProgressTimerTracker.update_fade
EHIProgressTimerTracker.FormatProgress = EHIProgressTracker.FormatProgress
EHIProgressTimerTracker.IncreaseProgressMax = EHIProgressTracker.IncreaseProgressMax
EHIProgressTimerTracker.DecreaseProgressMax = EHIProgressTracker.DecreaseProgressMax
EHIProgressTimerTracker.SetProgressMax = EHIProgressTracker.SetProgressMax
EHIProgressTimerTracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIProgressTimerTracker.DecreaseProgress = EHIProgressTracker.DecreaseProgress
EHIProgressTimerTracker.SetProgress = EHIProgressTracker.SetProgress
EHIProgressTimerTracker.SetProgressRemaining = EHIProgressTracker.SetProgressRemaining
function EHIProgressTimerTracker:post_init(params)
    self._panel_w = self._panel:w()
    self._bg_box_w = self._bg_box:w()
    self._panel_double = self._panel_w * 2
    self._bg_box_double = self._bg_box_w * 2
    self._progress_text = self:CreateText({
        name = "progress_text",
        text = self:FormatProgress()
    })
    self._text:set_left(self._progress_text:right())
end

function EHIProgressTimerTracker:SetCompleted(force)
    if not self._status or force then
        self._status = "completed"
        EHIProgressTimerTracker.super.super.super:SetTextColor(Color.green, self._progress_text)
        if force or not self._show_finish_after_reaching_target then
            self:AddTrackerToUpdate()
        elseif not self._show_progress_on_finish then
            self:SetStatusText("finish", self._progress_text)
        end
        self._disable_counting = true
    end
end

function EHIProgressTimerTracker:SetBad()
    EHIProgressTimerTracker.super.super.super:SetTextColor(EHIProgressTracker._progress_bad, self._progress_text)
end

---@class EHIChanceTimerTracker : EHITimerTracker, EHIChanceTracker
---@field super EHIChanceTracker
EHIChanceTimerTracker = class(EHITimerTracker)
EHIChanceTimerTracker.pre_init = EHIChanceTracker.pre_init
EHIChanceTimerTracker.FormatChance = EHIChanceTracker.Format
EHIChanceTimerTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHIChanceTimerTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
function EHIChanceTimerTracker:post_init(params)
    self._panel_w = self._panel:w()
    self._bg_box_w = self._bg_box:w()
    self._panel_double = self._panel_w * 2
    self._bg_box_double = self._bg_box_w * 2
    self._chance_text = self:CreateText({
        name = "chance_text",
        text = self:FormatChance()
    })
    self._text:set_left(self._chance_text:right())
end

function EHIChanceTimerTracker:SetChance(amount)
    self._chance = math.max(0, amount)
    self._chance_text:set_text(self:FormatChance())
    self:AnimateBG()
end