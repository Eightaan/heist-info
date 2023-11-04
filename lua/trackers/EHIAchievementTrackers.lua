local EHI = EHI
local function ShowFailedPopup(tracker)
    if tracker._failed_popup_showed or tracker._achieved_popup_showed or tracker._no_failure then
        return
    end
    tracker._failed_popup_showed = true
    if tracker._popup_type == "daily" then
        managers.hud:ShowDailyFailedPopup(tracker._id)
    elseif tracker._popup_type == "trophy" then
        managers.hud:ShowTrophyFailedPopup(tracker._id)
    else
        managers.hud:ShowAchievementFailedPopup(tracker._id, tracker._beardlib)
    end
end
local function ShowStartedPopup(tracker, delay_popup)
    if delay_popup then
        EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(tracker, tracker, "ShowStartedPopup"))
        return
    end
    if tracker._failed_on_sync then
        return
    elseif tracker._popup_type == "daily" then
        managers.hud:ShowDailyStartedPopup(tracker._id)
    elseif tracker._popup_type == "trophy" then
        managers.hud:ShowTrophyStartedPopup(tracker._id)
    else
        managers.hud:ShowAchievementStartedPopup(tracker._id, tracker._beardlib)
    end
end
local function ShowAchievementDescription(tracker, delay_popup)
    if delay_popup then
        EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(tracker, tracker, "ShowAchievementDescription"))
        return
    end
    if tracker._failed_on_sync then
        return
    end
    managers.hud:ShowAchievementDescription(tracker._id, tracker._beardlib)
end
local Color = Color

---@class EHIAchievementTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIAchievementTracker = class(EHIWarningTracker)
EHIAchievementTracker._popup_type = "achievement"
EHIAchievementTracker._show_started = EHI:GetUnlockableOption("show_achievement_started_popup")
EHIAchievementTracker._show_failed = EHI:GetUnlockableOption("show_achievement_failed_popup")
EHIAchievementTracker._show_desc = EHI:GetUnlockableOption("show_achievement_description")
function EHIAchievementTracker:post_init(params)
    self._beardlib = params.beardlib
    if self._show_started then
        ShowStartedPopup(self)
    end
    if self._show_desc then
        ShowAchievementDescription(self)
    end
end

function EHIAchievementTracker:SetCompleted()
    self._text:stop()
    self.update = self.update_fade
    self._achieved_popup_showed = true
    self:SetTextColor(Color.green)
    self:AnimateBG()
end

function EHIAchievementTracker:SetFailed()
    self._text:stop()
    self.update = self.update_fade
    self:SetTextColor(Color.red)
    self:AnimateBG()
    if self._show_failed then
        ShowFailedPopup(self)
    end
end

function EHIAchievementTracker:delete()
    if self._show_failed then
        ShowFailedPopup(self)
    end
    EHIAchievementTracker.super.delete(self)
end

function EHIAchievementTracker:ShowStartedPopup(delay_popup)
    ShowStartedPopup(self, delay_popup)
end

function EHIAchievementTracker:ShowFailedPopup()
    ShowFailedPopup(self)
end

function EHIAchievementTracker:ShowAchievementDescription(delay_popup)
    ShowAchievementDescription(self, delay_popup)
end

---@class EHIAchievementProgressTracker : EHIProgressTracker
---@field super EHIProgressTracker
EHIAchievementProgressTracker = class(EHIProgressTracker)
EHIAchievementProgressTracker._popup_type = "achievement"
EHIAchievementProgressTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementProgressTracker._show_failed = EHIAchievementTracker._show_failed
EHIAchievementProgressTracker._show_desc = EHIAchievementTracker._show_desc
EHIAchievementProgressTracker.ShowStartedPopup = EHIAchievementTracker.ShowStartedPopup
EHIAchievementProgressTracker.ShowAchievementDescription = EHIAchievementTracker.ShowAchievementDescription
---@param panel Panel
---@param params EHITracker_params
function EHIAchievementProgressTracker:init(panel, params)
    self._no_failure = params.no_failure
    self._beardlib = params.beardlib
    EHIAchievementProgressTracker.super.init(self, panel, params)
    if self._show_started then
        ShowStartedPopup(self, params.delay_popup)
    end
    if self._show_desc then
        ShowAchievementDescription(self, params.delay_popup)
    end
end

function EHIAchievementProgressTracker:SetCompleted(force)
    self._achieved_popup_showed = true
    EHIAchievementProgressTracker.super.SetCompleted(self, force)
end

function EHIAchievementProgressTracker:SetFailed()
    EHIAchievementProgressTracker.super.SetFailed(self)
    if self._status_is_overridable then
        self._achieved_popup_showed = nil
    end
    if self._show_failed then
        ShowFailedPopup(self)
    end
end

---@class EHIAchievementUnlockTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIAchievementUnlockTracker = class(EHIWarningTracker)
EHIAchievementUnlockTracker._popup_type = "achievement"
EHIAchievementUnlockTracker._show_completion_color = true
EHIAchievementUnlockTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementUnlockTracker._show_failed = EHIAchievementTracker._show_failed
EHIAchievementUnlockTracker._show_desc = EHIAchievementTracker._show_desc
EHIAchievementUnlockTracker.SetFailed = EHIAchievementTracker.SetFailed
function EHIAchievementUnlockTracker:post_init(params)
    self._beardlib = params.beardlib
    if self._show_started then
        ShowStartedPopup(self)
    end
    if self._show_desc then
        ShowAchievementDescription(self)
    end
end

---@class EHIAchievementBagValueTracker : EHINeededValueTracker
---@field super EHINeededValueTracker
EHIAchievementBagValueTracker = class(EHINeededValueTracker)
EHIAchievementBagValueTracker._popup_type = "achievement"
EHIAchievementBagValueTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementBagValueTracker._show_failed = EHIAchievementTracker._show_failed
EHIAchievementBagValueTracker._show_desc = EHIAchievementTracker._show_desc
EHIAchievementBagValueTracker.ShowStartedPopup = EHIAchievementTracker.ShowStartedPopup
EHIAchievementBagValueTracker.ShowAchievementDescription = EHIAchievementTracker.ShowAchievementDescription
function EHIAchievementBagValueTracker:post_init(params)
    self._beardlib = params.beardlib
    if self._show_started then
        ShowStartedPopup(self, params.delay_popup)
    end
    if self._show_desc then
        ShowAchievementDescription(self, params.delay_popup)
    end
end

function EHIAchievementBagValueTracker:SetCompleted(force)
    EHIAchievementBagValueTracker.super.SetCompleted(self, force)
    self._achieved_popup_showed = true
end

function EHIAchievementBagValueTracker:SetFailed()
    EHIAchievementBagValueTracker.super.SetFailed(self)
    if self._show_failed then
        ShowFailedPopup(self)
    end
end

---@class EHIAchievementStatusTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHIAchievementStatusTracker = class(EHIAchievementTracker)
EHIAchievementStatusTracker.update = EHIAchievementStatusTracker.update_fade
EHIAchievementStatusTracker._update = false
---@param panel Panel
---@param params EHITracker_params
function EHIAchievementStatusTracker:init(panel, params)
    self._status = params.status or "ok"
    EHIAchievementStatusTracker.super.init(self, panel, params)
    self:SetTextColor()
end

function EHIAchievementStatusTracker:Format()
    local status = "ehi_achievement_" .. self._status
    if LocalizationManager._custom_localizations[status] then
        return managers.localization:text(status)
    else
        return string.upper(self._status)
    end
end

function EHIAchievementStatusTracker:SetStatus(status)
    if self._dont_override_status or self._status == status then
        return
    end
    self._status = status
    self:SetStatusText(status)
    self:SetTextColor()
    self:AnimateBG()
end

function EHIAchievementStatusTracker:SetCompleted()
    self:SetStatus("done")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    self._achieved_popup_showed = true
end

function EHIAchievementStatusTracker:SetFailed()
    self:SetStatus("fail")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    if self._show_failed then
        ShowFailedPopup(self)
    end
end

local green_status =
{
    ok = true,
    done = true,
    pass = true,
    finish = true,
    destroy = true,
    defend = true,
    no_down = true,
    secure = true
}
local yellow_status =
{
    alarm = true,
    ready = true,
    loud = true,
    push = true,
    hack = true,
    land = true,
    find = true,
    bring = true,
    mark = true,
    objective = true
}
function EHIAchievementStatusTracker:SetTextColor(color)
    local c
    if color then
        c = color
    elseif green_status[self._status] then
        c = Color.green
    elseif yellow_status[self._status] then
        c = Color.yellow
    else
        c = Color.red
    end
    EHIAchievementStatusTracker.super.SetTextColor(self, c)
end