local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100109] = { max = (ovk_and_up and 40 or 30), id = "EnemyDeathShowers", icons = { "pd2_kill" }, flash_times = 1, class = TT.Progress },
    [101433] = { id = "EnemyDeathShowers", special_function = SF.RemoveTracker },

    [101815] = { time = 10, id = "MoveWalkway", icons = { Icon.Wait } },

    [101221] = { time = 11, id = "Thermite1", icons = { Icon.Fire } },
    [101714] = { time = 11, id = "Thermite2", icons = { Icon.Fire } },
    [101715] = { time = 11, id = "Thermite3", icons = { Icon.Fire } },
    [101716] = { time = 11, id = "Thermite4", icons = { Icon.Fire } },

    [101137] = { max = 10, id = "EnemyDeathOutside", icons = { "pd2_kill" }, flash_times = 1, class = TT.Progress },
    [101405] = { id = "EnemyDeathOutside", special_function = SF.RemoveTracker },

    [101339] = { id = "EnemyDeathShowers", special_function = SF.IncreaseProgress },
    [101412] = { id = "EnemyDeathOutside", special_function = SF.IncreaseProgress }
}

local achievements =
{
    bph_10 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101742] = { max = 3, class = TT.AchievementProgress, trigger_times = 1 },
            [101885] = { special_function = SF.SetAchievementFailed },
            [102171] = { special_function = SF.IncreaseProgress }
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:AddXPBreakdown({
    objective =
    {
        bph_found_control_room = 2000,
        bph_opening_correct_cell = 3000,
        bph_follow_bain = 5000,
        bph_met_on_rooftop = 1000,
        bph_extended_bridge = 3000,
        bph_helipad_is_accessible = ovk_and_up and 4000 or 3000
    }
})