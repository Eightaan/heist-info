local EHI = EHI
---@class EHIDailyTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHIDailyTracker = class(EHIAchievementTracker)
EHIDailyTracker._popup_type = "daily"
EHIDailyTracker._show_started = EHI:GetUnlockableOption("show_daily_started_popup")
EHIDailyTracker._show_failed = EHI:GetUnlockableOption("show_daily_failed_popup")

---@class EHIDailyProgressTracker : EHIAchievementProgressTracker
---@field super EHIAchievementProgressTracker
EHIDailyProgressTracker = class(EHIAchievementProgressTracker)
EHIDailyProgressTracker._popup_type = "daily"
EHIDailyProgressTracker._show_started = EHIDailyTracker._show_started
EHIDailyProgressTracker._show_failed = EHIDailyTracker._show_failed