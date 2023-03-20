local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [102368] = { id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 102333 },
    [104290] = { id = "PickUpBalloonFirstTry", special_function = SF.PauseTracker },
    [103517] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [101205] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [102370] = { id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 100732 }
}
if EHI:IsClient() then
    triggers[102368].time = 120
    triggers[102368].random_time = 10
    triggers[102368].delay_only = true
    triggers[102368].class = TT.InaccuratePausable
    triggers[102368].synced = { class = TT.Pausable }
    triggers[102368].special_function = SF.AddTrackerIfDoesNotExist
    EHI:AddSyncTrigger(102368, triggers[102368])
    triggers[102371] = { time = 60, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[102366] = { time = 30, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[103039] = { time = 20, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[102370].time = 35
    triggers[102370].random_time = 10
    triggers[102370].delay_only = true
    triggers[102370].class = TT.InaccuratePausable
    triggers[102370].synced = { class = TT.Pausable }
    triggers[102370].special_function = SF.AddTrackerIfDoesNotExist
    EHI:AddSyncTrigger(102370, triggers[102370])
    triggers[103038] = { time = 20, id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
end

local achievements =
{
    glace_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101732] = { status = "find", class = TT.AchievementStatus },
            [105758] = { special_function = SF.SetAchievementFailed },
            [105756] = { status = "ok", special_function = SF.SetAchievementStatus },
            [105759] = { special_function = SF.SetAchievementComplete }
        }
    },
    glace_10 =
    {
        elements =
        {
            [101732] = { max = 6, class = TT.AchievementProgress },
            [105761] = { special_function = SF.IncreaseProgress }, -- ElementInstanceOutputEvent
            [105721] = { special_function = SF.IncreaseProgress } -- ElementEnemyDummyTrigger
        }
    },
    uno_4 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard), -- Don't hook it if the difficulty is Hard or below
        elements =
        {
            [100765] = { status = "destroy", class = TT.AchievementStatus },
            -- Very Hard or above check in the mission script
            -- Reported here: https://steamcommunity.com/app/218620/discussions/14/3386156547847005343/
            [103397] = { special_function = SF.SetAchievementComplete },
            [102323] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [101132] = EHI:AddAssaultDelay({ time = 59 + 30 }),
    [100487] = EHI:AddAssaultDelay({ time = 30, special_function = SF.SetTimeOrCreateTracker })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        green_bridge_prisoner_found = 8000,
        green_bridge_prisoner_escorted = 6000,
        green_bridge_prisoner_defended = 6000,
        escape = 4000
    },
    loot_all = 1000
})