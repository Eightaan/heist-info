local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [103419] = { id = "SniperDeath", special_function = SF.IncreaseProgress },

    [100681] = { time = 60, id = "CharonPickLock", icons = { "pd2_door" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101430] = { id = "CharonPickLock", special_function = SF.PauseTracker },

    [102266] = { max = 6, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = TT.Progress },
    [100833] = { id = "SniperDeath", special_function = SF.RemoveTracker },

    [100549] = { time = 20, id = "ObjectiveWait", icons = { Icon.Wait } },
    [101202] = { time = 15, id = "Escape", icons = Icon.CarEscape },
    [101313] = { time = 75, id = "Escape", icons = Icon.CarEscape }
}

local achievements =
{
    spa_5 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            -- It was 7 minutes before the change
            [101989] = { time = 360, class = TT.Achievement },
            [101997] = { special_function = SF.SetAchievementComplete },
        }
    },
    spa_6 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101989] = { max = 8, class = TT.AchievementProgress, remove_after_reaching_target = false },
            [101999] = { special_function = SF.IncreaseProgress },
            [102002] = { special_function = SF.FinalizeAchievement },
        }
    }
}

--[[local other =
{
    -- First Assault Delay
    [EHI:GetInstanceElementID(100003, 7950)] = EHI:AddAssaultDelay({ time = 3 + 12 + 12 + 4 + 20 + 30, trigger_times = 1 }),
    [EHI:GetInstanceElementID(100024, 7950)] = EHI:AddAssaultDelay({ time = 12 + 12 + 4 + 20 + 30, special_function = SF.AddTrackerIfDoesNotExist }),
    [EHI:GetInstanceElementID(100053, 7950)] = EHI:AddAssaultDelay({ time = 12 + 4 + 20 + 30, special_function = SF.AddTrackerIfDoesNotExist }),
    [EHI:GetInstanceElementID(100026, 7950)] = EHI:AddAssaultDelay({ time = 4 + 20 + 30, special_function = SF.AddTrackerIfDoesNotExist }),
    [EHI:GetInstanceElementID(100179, 7950)] = EHI:AddAssaultDelay({ time = 20 + 30, special_function = SF.AddTrackerIfDoesNotExist })
}]]

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowLootCounter({ max = 4 })

local tbl =
{
    --levels/instances/unique/spa/spa_storage (6-10)
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small
    [EHI:GetInstanceUnitID(100063, 7800)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100061, 7800) },
    [EHI:GetInstanceUnitID(100063, 2850)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100061, 2850) },
    [EHI:GetInstanceUnitID(100063, 3000)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100061, 3000) },
    [EHI:GetInstanceUnitID(100063, 3750)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100061, 3750) },
    [EHI:GetInstanceUnitID(100063, 4050)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100061, 4050) }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        brooklyn_1010_opened_door_to_roof = 8000,
        brooklyn_1010_secured_briefcase = 6000,
        brooklyn_1010_used_zipline = 6000,
        escape = 8000
    },
    loot_all = 1000
})