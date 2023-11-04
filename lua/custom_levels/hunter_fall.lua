local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
---@type ParseAchievementTable
local achievements = {
    hunter_fall =
    {
        elements =
        {
            [100077] = { time = 62, class = TT.Achievement.Base, special_function = SF.ShowAchievementFromStart }
        }
    }
}
EHI:PreparseBeardlibAchievements(achievements, "hunter_all")

EHI:ParseTriggers({
    achievement = achievements
})