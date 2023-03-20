local EHI = EHI
local lerp = math.lerp
local sin = math.sin
local min = math.min
local floor = math.floor
local Color = Color
local function anim_completion(o, start_t)
    while true do
        local t = start_t
        while t > 0 do
            t = t - coroutine.yield()
            local n = sin(t * 180)
            local g = lerp(1, 0, n)
            o:set_color(Color(g, 1, g))
        end
        start_t = 1
    end
end
EHITimerTracker = class(EHITracker)
EHITimerTracker.AnimateWarning = EHIWarningTracker.AnimateWarning
EHITimerTracker._update = false
function EHITimerTracker:init(panel, params)
    if params.icons[1].icon then
        params.icons[2] = { icon = "faster", visible = false, alpha = 0.25 }
        params.icons[3] = { icon = "silent", visible = false, alpha = 0.25 }
        params.icons[4] = { icon = "restarter", visible = false, alpha = 0.25 }
    end
    EHITimerTracker.super.init(self, panel, params)
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
        self.AnimateWarning = self.AnimateCompletion
    end
end

function EHITimerTracker:SetTimeNoAnim(time) -- No fit text function needed, these timers just run down
    self._time = time
    self._text:set_text(self:Format())
    if time <= 10 and self._animate_warning and not self._warning_started then
        self._warning_started = true
        self:AnimateWarning()
    end
end

function EHITimerTracker:AnimateCompletion(check_progress)
    if self._text and alive(self._text) then
        local start_t = check_progress and (1 - min(EHI:RoundNumber(self._time, 0.1) - floor(self._time), 0.99)) or 1
        self._text:animate(anim_completion, start_t)
    end
end

function EHITimerTracker:SetAnimateWarning(completion)
    self._animate_warning = true
    if completion then
        self.AnimateWarning = self.AnimateCompletion
    end
    if self._time <= 10 and not self._warning_started then
        self._warning_started = true
        self:AnimateWarning(true)
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
        self._panel_override_w = self._time_bg_box:w() + self._icon_gap_size_scaled
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
    self._icon1:set_color(state and tweak_data.ehi.color.DrillAutorepair or Color.white)
end

function EHITimerTracker:SetJammed(jammed)
    if self._warning_started then
        self._text:stop()
        self._warning_started = false
    end
    self._jammed = jammed
    self:SetTextColor()
end

function EHITimerTracker:SetPowered(powered)
    if self._warning_started then
        self._text:stop()
        self._warning_started = false
    end
    self._not_powered = not powered
    self:SetTextColor()
end

function EHITimerTracker:SetRunning()
    self:SetJammed(false)
    self:SetPowered(true)
end

function EHITimerTracker:SetTextColor()
    if self._jammed or self._not_powered then
        self._text:set_color(Color.red)
    else
        self._text:set_color(Color.white)
        if self._time <= 10 and self._animate_warning and not self._warning_started then
            self._warning_started = true
            self:AnimateWarning(true)
        end
    end
end

function EHITimerTracker:delete()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHITimerTracker.super.delete(self)
end