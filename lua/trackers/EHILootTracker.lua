local format = EHI:GetOption("variable_random_loot_format")
---@class EHILootTracker : EHIProgressTracker
---@field super EHIProgressTracker
EHILootTracker = class(EHIProgressTracker)
EHILootTracker._forced_icons = { EHI.Icons.Loot }
EHILootTracker._show_popup = EHI:GetOption("show_all_loot_secured_popup")
---@param panel Panel
---@param params EHITracker_params
function EHILootTracker:init(panel, params)
    self._mission_loot = 0
    self._offset = params.offset or 0
    self._max_random = params.max_random or 0
    self._stay_on_screen = self._max_random > 0
    EHILootTracker.super.init(self, panel, params)
    self._show_finish_after_reaching_target = self._stay_on_screen
    self._loot_id = {}
end

if format == 1 then
    function EHILootTracker:Format()
        if self._max_random > 0 then
            local max = self._max + self._max_random
            return self._progress .. "/" .. self._max .. "-" .. max .. "?"
        end
        return EHILootTracker.super.Format(self)
    end
elseif format == 2 then
    function EHILootTracker:Format()
        if self._max_random > 0 then
            local max = self._max + self._max_random
            return self._progress .. "/" .. max .. "?"
        end
        return EHILootTracker.super.Format(self)
    end
else
    function EHILootTracker:Format()
        if self._max_random > 0 then
            return self._progress .. "/" .. self._max .. "+" .. self._max_random .. "?"
        end
        return EHILootTracker.super.Format(self)
    end
end

function EHILootTracker:SetProgress(progress)
    local fixed_progress = progress + self._mission_loot - self._offset
    EHILootTracker.super.SetProgress(self, fixed_progress)
end

function EHILootTracker:Finalize()
    local progress = self._progress
    self._progress = self._progress - self._offset
    EHILootTracker.super.Finalize(self)
    self._progress = progress
end

function EHILootTracker:SetCompleted(force)
    EHILootTracker.super.SetCompleted(self, force)
    if self._stay_on_screen and self._status then
        self._text:set_text(self:Format())
        self:FitTheText()
        self._status = nil
    elseif self._show_popup then
        managers.hud:custom_ingame_popup_text("LOOT COUNTER", managers.localization:text("ehi_popup_all_loot_secured"), "EHI_Loot")
    end
end

function EHILootTracker:SetProgressMax(max)
    EHILootTracker.super.SetProgressMax(self, max)
    self:SetTextColor(Color.white)
    self._disable_counting = nil
    self:VerifyStatus()
end

function EHILootTracker:VerifyStatus()
    self._stay_on_screen = self._max_random > 0
    self._show_finish_after_reaching_target = self._stay_on_screen
    if self._progress == self._max then
        self:SetCompleted()
    end
end

function EHILootTracker:RandomLootSpawned(random)
    if self._max_random <= 0 then
        return
    end
    local n = random or 1
    self._max_random = self._max_random - n
    self:IncreaseProgressMax(n)
end

function EHILootTracker:RandomLootDeclined(random)
    if self._max_random <= 0 then
        return
    end
    self._max_random = self._max_random - (random or 1)
    self:SetProgressMax(self._max)
end

function EHILootTracker:SetMaxRandom(max)
    self._max_random = max or 0
    self:SetProgressMax(self._max)
end

function EHILootTracker:IncreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random + (progress or 1))
end

function EHILootTracker:DecreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random - (progress or 1))
end

function EHILootTracker:RandomLootSpawned2(id, force)
    if self._loot_id[id] then
        if force then -- This is here to combat desync, use it if element does not have "fail" state
            self:IncreaseProgressMax()
        end
        return
    end
    self._loot_id[id] = true
    self:RandomLootSpawned()
end

function EHILootTracker:RandomLootDeclined2(id)
    if self._loot_id[id] then
        return
    end
    self:RandomLootDeclined()
end

function EHILootTracker:BlockRandomLoot(id)
    self._loot_id[id] = true
end

function EHILootTracker:SecuredMissionLoot()
    local progress = self._progress - self._mission_loot + self._offset
    self._mission_loot = self._mission_loot + 1
    self:SetProgress(progress)
end
EHILootTracker.FormatProgress = EHILootTracker.Format

---@class EHIAchievementLootCounterTracker : EHILootTracker, EHIAchievementTracker
---@field super EHILootTracker
EHIAchievementLootCounterTracker = class(EHILootTracker)
EHIAchievementLootCounterTracker._popup_type = "achievement"
EHIAchievementLootCounterTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementLootCounterTracker._show_failed = EHIAchievementTracker._show_failed
EHIAchievementLootCounterTracker._show_desc = EHIAchievementTracker._show_desc
EHIAchievementLootCounterTracker.ShowStartedPopup = EHIAchievementTracker.ShowStartedPopup
EHIAchievementLootCounterTracker.ShowFailedPopup = EHIAchievementTracker.ShowFailedPopup
EHIAchievementLootCounterTracker.ShowAchievementDescription = EHIAchievementTracker.ShowAchievementDescription
---@param panel Panel
---@param params EHITracker_params
function EHIAchievementLootCounterTracker:init(panel, params)
    self._no_failure = params.no_failure
    self._beardlib = params.beardlib
    self._loot_counter_on_fail = params.loot_counter_on_fail
    self._forced_icons[1] = params.icons[1]
    self._forced_icons[2] = "pd2_loot"
    EHIAchievementLootCounterTracker.super.init(self, panel, params)
    self:ChangeTrackerWidth()
    if params.start_silent then
        self._silent_start = true
        self._icon2:set_visible(true)
        self._icon1:set_visible(false)
        if not self._manually_created_icon2 then
            self._icon2:set_x(self._icon1:x())
        end
    else
        if self._show_started then
            self:ShowStartedPopup(params.delay_popup)
        end
        if self._show_desc then
            self:ShowAchievementDescription(params.delay_popup)
        end
    end
end

function EHIAchievementLootCounterTracker:OverridePanel()
    if self._icon2 then
        return
    end
    local texture, text_rect = self:GetIcon("pd2_loot")
    self._icon2 = self._panel:bitmap({
        name = "icon2",
        texture = texture,
        texture_rect = text_rect,
        alpha = 1,
        visible = false,
        x = self._icon1:x(),
        w = self._icon_size_scaled,
        h = self._icon_size_scaled
    })
    self._manually_created_icon2 = true
end

function EHIAchievementLootCounterTracker:SetCompleted(force)
    self._achieved_popup_showed = true
    EHIAchievementLootCounterTracker.super.SetCompleted(self, force)
end

function EHIAchievementLootCounterTracker:SetFailed()
    if self._loot_counter_on_fail then
        self:AnimateBG()
        self._icon2:set_visible(true)
        self._icon1:set_visible(false)
        if not self._manually_created_icon2 then
            self._icon2:set_x(self._icon1:x())
        end
    else
        EHIAchievementLootCounterTracker.super.SetFailed(self)
    end
    if self._status_is_overridable then
        self._achieved_popup_showed = nil
    end
    if self._show_failed then
        self:ShowFailedPopup()
    end
end

function EHIAchievementLootCounterTracker:SetFailed2()
    if self._failed_allowed then
        self:SetFailed()
    end
end

function EHIAchievementLootCounterTracker:SetFailedSilent()
    self._failed_on_sync = true
    self._show_failed = nil
    self._show_finish_after_reaching_target = nil
    self:SetFailed()
end

function EHIAchievementLootCounterTracker:SetStarted()
    if self._show_started then
        self._failed_allowed = self._silent_start
        self:ShowStartedPopup()
        self._icon1:set_visible(true)
        if self._manually_created_icon2 then
            self._icon2:set_visible(false)
        else
            self:SetIconX(self._icon1, self._icon2)
        end
    end
    if self._show_desc then
        self:ShowAchievementDescription()
    end
end