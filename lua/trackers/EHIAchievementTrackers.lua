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
local function ShowStartedPopup(tracker)
    if tracker._delay_popup then
        EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(tracker, tracker, "ShowStartedPopup"))
        return
    end
    if tracker._popup_type == "daily" then
        managers.hud:ShowDailyStartedPopup(tracker._id)
    elseif tracker._popup_type == "trophy" then
        managers.hud:ShowTrophyStartedPopup(tracker._id)
    else
        managers.hud:ShowAchievementStartedPopup(tracker._id, tracker._beardlib)
    end
end
local Color = Color

EHIAchievementTracker = class(EHIWarningTracker)
EHIAchievementTracker._popup_type = "achievement"
EHIAchievementTracker._show_started = EHI:GetUnlockableOption("show_achievement_started_popup")
EHIAchievementTracker._show_failed = EHI:GetUnlockableOption("show_achievement_failed_popup")
function EHIAchievementTracker:init(panel, params)
    EHIAchievementTracker.super.init(self, panel, params)
    self._beardlib = params.beardlib
    if self._show_started then
        ShowStartedPopup(self)
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

EHIAchievementProgressTracker = class(EHIProgressTracker)
EHIAchievementProgressTracker._popup_type = "achievement"
EHIAchievementProgressTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementProgressTracker._show_failed = EHIAchievementTracker._show_failed
function EHIAchievementProgressTracker:init(panel, params)
    self._no_failure = params.no_failure
    self._delay_popup = params.delay_popup
    self._beardlib = params.beardlib
    EHIAchievementProgressTracker.super.init(self, panel, params)
    if self._show_started then
        ShowStartedPopup(self)
    end
end

function EHIAchievementProgressTracker:SetCompleted(force)
    self._achieved_popup_showed = true
    EHIAchievementProgressTracker.super.SetCompleted(self, force)
end

function EHIAchievementProgressTracker:SetFailed()
    EHIAchievementProgressTracker.super.SetFailed(self)
    if self._show_failed then
        ShowFailedPopup(self)
    end
end

function EHIAchievementProgressTracker:ShowStartedPopup()
    self._delay_popup = false
    ShowStartedPopup(self)
end

EHIAchievementUnlockTracker = class(EHIWarningTracker)
EHIAchievementUnlockTracker.AnimateWarning = EHITimerTracker.AnimateCompletion
EHIAchievementUnlockTracker._popup_type = "achievement"
EHIAchievementUnlockTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementUnlockTracker._show_failed = EHIAchievementTracker._show_failed
function EHIAchievementUnlockTracker:init(panel, params)
    EHIAchievementUnlockTracker.super.init(self, panel, params)
    self._beardlib = params.beardlib
    if self._show_started then
        ShowStartedPopup(self)
    end
end

function EHIAchievementUnlockTracker:SetFailed()
    self._text:stop()
    self.update = self.update_fade
    self:SetTextColor(Color.red)
    self:AnimateBG()
    if self._show_failed then
        ShowFailedPopup(self)
    end
end

EHIAchievementBagValueTracker = class(EHINeededValueTracker)
EHIAchievementBagValueTracker._popup_type = "achievement"
EHIAchievementBagValueTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementBagValueTracker._show_failed = EHIAchievementTracker._show_failed
function EHIAchievementBagValueTracker:init(panel, params)
    EHIAchievementBagValueTracker.super.init(self, panel, params)
    self._delay_popup = params.delay_popup
    self._beardlib = params.beardlib
    if self._show_started then
        ShowStartedPopup(self)
    end
end

function EHIAchievementBagValueTracker:ShowStartedPopup()
    self._delay_popup = false
    ShowStartedPopup(self)
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

local show_status_changed_popup = false
EHIAchievementStatusTracker = class(EHIAchievementTracker)
EHIAchievementStatusTracker.update = EHIAchievementStatusTracker.update_fade
EHIAchievementStatusTracker._update = false
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
    if show_status_changed_popup and status ~= "done" and status ~= "fail" then
        managers.hud:custom_ingame_popup_text("")
    end
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
if show_status_changed_popup then
    for status, _ in pairs(green_status) do
        EHI:SetNotificationAlert("ACHIEVEMENT STATUS", "ehi_achievement_" .. status, Color.green)
    end
    for status, _ in pairs(yellow_status) do
        EHI:SetNotificationAlert("ACHIEVEMENT STATUS", "ehi_achievement_" .. status, Color.yellow)
    end
end