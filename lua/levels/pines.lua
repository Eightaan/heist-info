local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local very_hard_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard)
local chance = { id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance, special_function = SF.SetChanceFromElementWhenTrackerExists }
local PresentDropTimer = { "C_Vlad_H_XMas_Impossible", Icon.Wait }
local preload =
{
    { id = "HeliLootTakeOff", icons = Icon.HeliWait, class = TT.Warning, hide_on_delete = true }
}
local triggers = {
    [100109] = { time = 25, id = "EndlessAssault", icons = Icon.EndlessAssault, class = TT.Warning },
    [100021] = { time = 180, id = "EndlessAssault2", icons = Icon.EndlessAssault, class = TT.Warning },
    [103707] = { time = 1800, id = "BulldozerSpawn", icons = { "heavy" }, class = TT.Warning, condition = very_hard_and_up, special_function = SF.SetTimeOrCreateTracker },
    [103367] = { chance = 100, id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance },
    [101001] = { time = 1200, id = "PresentDropChance50", icons = PresentDropTimer, class = TT.Warning },
    [101002] = { time = 600, id = "PresentDropChance40", icons = PresentDropTimer, class = TT.Warning },
    [101003] = { time = 600, id = "PresentDropChance30", icons = PresentDropTimer, class = TT.Warning },
    [101004] = { time = 600, id = "PresentDropChance20", icons = PresentDropTimer, class = TT.Warning },
    [101045] = { time = 50, random_time = 10, id = "WaitTime", icons = { Icon.Heli, Icon.Wait } },
    [100024] = { time = 23, id = "HeliSanta", icons = { Icon.Heli, "Other_H_None_Merry" }, trigger_times = 1 },
    [105102] = { time = 30, id = "HeliLoot", icons = Icon.HeliEscape, special_function = SF.ExecuteIfElementIsEnabled },
    -- Hooked to 105072 instead of 105076 to track the take off accurately
    [105072] = { id = "HeliLootTakeOff", run = { time = 82 } },

    [101005] = chance,
    [101006] = chance,
    [101007] = chance,
    [101008] = chance
}
local achievements =
{
    uno_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101471] = { max = 40, class = TT.AchievementProgress },
            [104385] = { special_function = SF.IncreaseProgress }
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    preload = preload
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 8000
    },
    loot_all = 2000
})