---@class EHISniperCountTracker : EHICountTracker
---@field super EHICountTracker
EHISniperCountTracker = class(EHICountTracker)
EHISniperCountTracker._forced_icons = { "sniper" }
EHISniperCountTracker._text_color = EHIProgressTracker._progress_bad

---@class EHISniperChanceTracker : EHIChanceTracker, EHICountTracker
---@field super EHIChanceTracker
EHISniperChanceTracker = class(EHIChanceTracker)
EHISniperChanceTracker._forced_icons = { "sniper" }
EHISniperChanceTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperChanceTracker.DecreaseCount = EHICountTracker.DecreaseCount
function EHISniperChanceTracker:pre_init(params)
    EHISniperChanceTracker.super.pre_init(self, params)
    EHICountTracker.pre_init(self, params)
    self._additional_count = 0
end

function EHISniperChanceTracker:post_init(params)
    if params.chance_success then
        self:SniperSpawnsSuccess()
    end
end

function EHISniperChanceTracker:OverridePanel()
    local w = self._bg_box:w() / 2
    self._text:set_w(w)
    self._text:set_x(0)
    self:FitTheText()
    self._count_text = self:CreateText({
        name = "count_text",
        text = self:FormatCount(),
        w = w,
        color = EHIProgressTracker._progress_bad
    })
    self._count_text:set_left(self._text:right())
    self:FitTheText(self._count_text)
end

function EHISniperChanceTracker:FormatCount()
    return tostring(self._count + self._additional_count)
end

function EHISniperChanceTracker:SniperSpawnsSuccess()
    self:AnimateBG()
end

function EHISniperChanceTracker:SnipersKilled()
    self:SetCount(0)
    self:AnimateBG()
end

function EHISniperChanceTracker:SetCount(count)
    self._count = math.max(0, count)
    self._count_text:set_text(self:FormatCount())
    self:AnimateBG(1)
end

---@class EHISniperTimedTracker : EHITracker
---@field super EHITracker
EHISniperTimedTracker = class(EHITracker)
EHISniperTimedTracker._forced_icons = { "sniper" }
EHISniperTimedTracker._refresh_on_delete = true
EHISniperTimedTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperTimedTracker.DecreaseCount = EHICountTracker.DecreaseCount
function EHISniperTimedTracker:pre_init(params)
    self._count = params.count or 0
    self._additional_count = 0
    self._count_on_refresh = params.count_on_refresh
    self._refresh_t = params.refresh_t or 0
end

function EHISniperTimedTracker:OverridePanel()
    self._count_text = self:CreateText({
        name = "count_text",
        text = self:FormatCount(),
        color = EHIProgressTracker._progress_bad
    })
    self._text:set_w(self._bg_box:w() / 2)
end

function EHISniperTimedTracker:FormatCount()
    return tostring(self._count + self._additional_count)
end

function EHISniperTimedTracker:SetCount(count)
    self._count = math.max(0, count)
    self._count_text:set_text(self:FormatCount())
    self:AnimateBG(1)
end

function EHISniperTimedTracker:Refresh()
    self._time = self._time + self._refresh_t
end

---@class EHISniperTimedCountTracker : EHIWarningTracker, EHISniperTimedTracker
---@field super EHIWarningTracker
EHISniperTimedCountTracker = class(EHIWarningTracker)
EHISniperTimedCountTracker._forced_icons = { "sniper" }
EHISniperTimedCountTracker._refresh_on_delete = true
EHISniperTimedCountTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperTimedCountTracker.DecreaseCount = EHICountTracker.DecreaseCount
EHISniperTimedCountTracker.FormatCount = EHISniperTimedTracker.FormatCount
EHISniperTimedCountTracker.SetCount = EHISniperTimedTracker.SetCount
function EHISniperTimedCountTracker:pre_init(params)
    self._count = params.count or 0
    self._additional_count = 0
    self._count_on_refresh = params.count_on_refresh
end

function EHISniperTimedCountTracker:post_init(params)
    if params.snipers_spawned then
        self._update = false
        self:Refresh()
    end
end

function EHISniperTimedCountTracker:OverridePanel()
    self._count_text = self:CreateText({
        name = "count_text",
        text = self:FormatCount(),
        color = EHIProgressTracker._progress_bad
    })
    self._count_text:set_visible(false)
end

function EHISniperTimedCountTracker:SetRespawnTime(t)
    self._time = t
    self._check_anim_progress = t <= 10
    self._time_warning = false
    self:AddTrackerToUpdate()
    self._text:set_visible(true)
    self._count_text:set_visible(false)
end

function EHISniperTimedCountTracker:Refresh()
    self:RemoveTrackerFromUpdate()
    self:SetTextColor()
    self._count_text:set_visible(true)
    self._text:set_visible(false)
    if self._count_on_refresh then
        self:SetCount(self._count_on_refresh)
    end
end

---@class EHISniperTimedChanceTracker : EHITracker, EHIChanceTracker, EHICountTracker
---@field super EHITracker
EHISniperTimedChanceTracker = class(EHITracker)
EHISniperTimedChanceTracker._forced_icons = { "sniper" }
EHISniperTimedChanceTracker._refresh_on_delete = true
EHISniperTimedChanceTracker.FormatChance = EHIChanceTracker.Format
EHISniperTimedChanceTracker.FormatCount = EHICountTracker.Format
EHISniperTimedChanceTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperTimedChanceTracker.DecreaseCount = EHICountTracker.DecreaseCount
EHISniperTimedChanceTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHISniperTimedChanceTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
function EHISniperTimedChanceTracker:pre_init(params)
    self._count = params.count or 0
    self._chance = params.chance or 0
    self._recheck_t = params.recheck_t or 0
end

function EHISniperTimedChanceTracker:post_init(params)
    if params.chance_success then
        self._update = false
        self:SniperSpawnsSuccess()
    end
end

function EHISniperTimedChanceTracker:OverridePanel()
    local w = self._bg_box:w() / 2
    self._text:set_w(w)
    self._chance_text = self:CreateText({
        name = "chance_text",
        text = self:FormatChance(),
        w = w
    })
    self._chance_text:set_x(0)
    self:FitTheText(self._chance_text)
    self._text:set_left(self._chance_text:right())
    local t = self._time
    self._time = 0.69 -- nice
    self._text:set_text(self:Format())
    self:FitTheText()
    self._time = t
    self._text:set_text(self:Format())
    self._count_text = self:CreateText({
        name = "count_text",
        text = self:FormatCount(),
        color = EHIProgressTracker._progress_bad
    })
    self._count_text:set_visible(false)
end

function EHISniperTimedChanceTracker:SniperSpawnsSuccess()
    self._count_text:set_visible(true)
    self._chance_text:set_visible(false)
    self._text:set_visible(false)
    self:RemoveTrackerFromUpdate()
    self:AnimateBG()
end

function EHISniperTimedChanceTracker:SnipersKilled(t)
    self._time = t or self._recheck_t
    self._count_text:set_visible(false)
    self._chance_text:set_visible(true)
    self._text:set_visible(true)
    self:AddTrackerToUpdate()
    self:AnimateBG()
end

function EHISniperTimedChanceTracker:Refresh()
    self._time = self._time + self._recheck_t
end

function EHISniperTimedChanceTracker:SetCount(count)
    self._count = math.max(0, count)
    self._count_text:set_text(self:FormatCount())
    self:AnimateBG(1)
end

function EHISniperTimedChanceTracker:SetChance(amount)
    self._chance = math.max(0, amount)
    self._chance_text:set_text(self:FormatChance())
    self:FitTheText(self._chance_text)
    self:AnimateBG(1)
end

---@class EHISniperLoopTracker : EHITracker, EHIChanceTracker, EHICountTracker
---@field super EHITracker
EHISniperLoopTracker = class(EHITracker)
EHISniperLoopTracker._forced_icons = { "sniper" }
EHISniperLoopTracker._refresh_on_delete = true
EHISniperLoopTracker.FormatChance = EHIChanceTracker.Format
EHISniperLoopTracker.FormatCount = EHICountTracker.Format
EHISniperLoopTracker.ResetCount = EHICountTracker.ResetCount
EHISniperLoopTracker.IncreaseCount = EHICountTracker.IncreaseCount
EHISniperLoopTracker.DecreaseCount = EHICountTracker.DecreaseCount
EHISniperLoopTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHISniperLoopTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
function EHISniperLoopTracker:pre_init(params)
    self._count = 0
    self._chance = params.chance or 0
    self._on_fail_refresh_t = params.on_fail_refresh_t or 0
    self._on_success_refresh_t = params.on_success_refresh_t or 0
end

function EHISniperLoopTracker:OverridePanel()
    self:SetBGSize(self._bg_box:w() / 2)
    local w = self._bg_box:w() / 3
    self._text:set_w(w)
    self._chance_text = self:CreateText({
        name = "chance_text",
        text = self:FormatChance(),
        w = w
    })
    self._chance_text:set_x(0)
    self:FitTheText(self._chance_text)
    self._text:set_left(self._chance_text:right())
    local t = self._time
    self._time = 0.69 -- nice
    self._text:set_text(self:Format())
    self:FitTheText()
    self._time = t
    self._text:set_text(self:Format())
    self._count_text = self:CreateText({
        name = "count_text",
        text = self:FormatCount(),
        w = w,
        color = EHIProgressTracker._progress_bad
    })
    self._count_text:set_left(self._text:right())
    self:SetIconX()
end

function EHISniperLoopTracker:SetTimeNoAnim(time)
    self._time = time
    self._text:set_text(self:Format())
end

function EHISniperLoopTracker:OnChanceFail()
    self:SetTimeNoAnim(self._on_fail_refresh_t)
end

function EHISniperLoopTracker:OnChanceSuccess()
    self:SetTimeNoAnim(self._on_success_refresh_t)
end

function EHISniperLoopTracker:SetCount(count)
    self._count = math.max(0, count)
    self._count_text:set_text(self:FormatCount())
    self:AnimateBG(1)
end

function EHISniperLoopTracker:SetCountRemovalCheck(count)
    self._count = math.max(0, count)
    self._count_text:set_text(self:FormatCount())
    if self._count == 0 then
        self:ForceDelete()
    else
        self:AnimateBG(1)
    end
end

function EHISniperLoopTracker:SetChance(amount)
    self._chance = math.max(0, amount)
    self._chance_text:set_text(self:FormatChance())
    self:FitTheText(self._chance_text)
    self:AnimateBG(1)
end

function EHISniperLoopTracker:DisableChanceUpdate(amount)
end

function EHISniperLoopTracker:RequestRemoval()
    if self._count == 0 then
        self:ForceDelete()
        return
    end
    self.SetCount = self.SetCountRemovalCheck
    self.SetChance = self.DisableChanceUpdate
    self._chance_text:set_visible(false)
    self._text:set_visible(false)
    self:RemoveTrackerFromUpdate()
    self._count_text:set_w(self._bg_box:w())
    self._count_text:set_x(0)
    self:FitTheText(self._count_text)
end

---@class EHISniperTimedChanceOnceTracker : EHISniperTimedChanceTracker
---@field super EHISniperTimedChanceTracker
EHISniperTimedChanceOnceTracker = class(EHISniperTimedChanceTracker)
function EHISniperTimedChanceOnceTracker:SniperSpawnsSuccess(count)
    EHISniperTimedChanceOnceTracker.super.SniperSpawnsSuccess(self)
    if count then
        self:SetCount(count)
    end
end

function EHISniperTimedChanceOnceTracker:SetCount(count)
    EHISniperTimedChanceOnceTracker.super.SetCount(self, count)
    if self._count == 0 then
        self:ForceDelete()
    else
        self:AnimateBG(1)
    end
end

---@class EHISniperHeliTracker : EHITracker
---@field super EHITracker
EHISniperHeliTracker = class(EHITracker)
EHISniperHeliTracker._forced_icons = EHI:GetOption("show_one_icon") and { { icon = EHI.Icons.Heli, color = Color.red } } or { EHI.Icons.Heli, "sniper" }
EHISniperHeliTracker._refresh_on_delete = true
function EHISniperHeliTracker:pre_init(params)
    self._refresh_t = params.refresh_t or 0
end

function EHISniperHeliTracker:OverridePanel()
    self._count_text = self:CreateText({
        name = "count_text",
        text = "1",
        color = EHIProgressTracker._progress_bad
    })
    self._count_text:set_visible(false)
end

function EHISniperHeliTracker:SniperRespawn()
    self._time = self._refresh_t
    self._text:set_visible(true)
    self._count_text:set_visible(false)
    self:AddTrackerToUpdate()
    self:AnimateBG()
end

function EHISniperHeliTracker:SniperKilledUpdateCount()
    self._count_text:set_text("0")
    self:AnimateBG()
end

function EHISniperHeliTracker:Refresh()
    self._count_text:set_text("1")
    self._count_text:set_visible(true)
    self._text:set_visible(false)
    self:RemoveTrackerFromUpdate()
    self:AnimateBG()
end

---@class EHISniperHeliTimedChanceTracker : EHISniperTimedChanceTracker
---@field super EHISniperTimedChanceTracker
EHISniperHeliTimedChanceTracker = class(EHISniperTimedChanceTracker)
EHISniperHeliTimedChanceTracker._forced_icons = EHISniperHeliTracker._forced_icons
function EHISniperHeliTimedChanceTracker:OverridePanel()
    EHISniperHeliTimedChanceTracker.super.OverridePanel(self)
    self._text_font_size = self._text:font_size()
end

function EHISniperHeliTimedChanceTracker:SniperSpawnsSuccess(t)
    self._time = t
    self._sniper_incoming = true
    self._chance_text:set_visible(false)
    self._text:set_w(self._bg_box:w())
    self._text:set_x(0)
    self:FitTheText()
end

function EHISniperHeliTimedChanceTracker:SnipersKilled(t)
    self._text:set_w(self._chance_text:w())
    self._text:set_left(self._chance_text:right())
    self._text:set_font_size(self._text_font_size)
    EHISniperHeliTimedChanceTracker.super.SnipersKilled(self, t)
end

function EHISniperHeliTimedChanceTracker:Refresh()
    if self._sniper_incoming then
        self._sniper_incoming = false
        EHISniperHeliTimedChanceTracker.super.SniperSpawnsSuccess(self)
    else
        self._time = self._time + self._recheck_t
    end
end