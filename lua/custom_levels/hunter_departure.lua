local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local repair = { time = 90, id = "RepairWait", icons = { EHI.Icons.Fix } }
local triggers = {
    [100030] = repair,
    [100065] = repair,
    [100080] = repair,
    [100123] = repair
}

local achievements =
{
    hunter_loot =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100132] = { special_function = SF.Trigger, data = { 1001321, 1001322 } },
            [1001321] = { max = 21, class = TT.AchievementProgress, special_function = SF.ShowAchievementFromStart },
            [1001322] = { special_function = SF.CustomCode, f = function()
                EHI:ShowLootCounter({ max = 21 })
                EHI:UnhookElement(100416)
            end },
            [100416] = { special_function = SF.IncreaseProgress }
        }
    }
}
EHI:PreparseBeardlibAchievements(achievements, "hunter_all")

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:AddLoadSyncFunction(function(self)
    EHI:ShowLootCounter({ max = 21 })
    EHI:UnhookElement(100416)
    self:SyncSecuredLoot()
end)