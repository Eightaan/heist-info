local EHI = EHI
EHITrophyTracker = class(EHIAchievementTracker)
EHITrophyTracker._popup_type = "trophy"
EHITrophyTracker._show_started = EHI:GetUnlockableOption("show_trophy_started_popup")
EHITrophyTracker._show_failed = EHI:GetUnlockableOption("show_trophy_failed_popup")