local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101961] = { time = 120 },
    [101962] = { time = 90 },

    [102065] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102675 }},
    [102080] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102674 }}
}

if EHI:IsClient() then
    triggers[101965] = { time = 60, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101966] = { time = 30, special_function = SF.AddTrackerIfDoesNotExist }
end

local achievements =
{
    bullet_dodger =
    {
        elements =
        {
            [101959] = { status = "finish", class = TT.AchievementStatus },
            [101872] = { special_function = SF.SetAchievementFailed },
            [101874] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [102031] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround),
    [102030] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround),
    [101959] = EHI:AddAssaultDelay({ time = 10 + 30 })
}

EHI:ParseTriggers({ mission = triggers, achievement = achievements, other = other }, "Escape", Icon.HeliEscape)

if tweak_data.ehi.functions.IsBranchbankJobActive() then
    EHI:ShowAchievementBagValueCounter({
        achievement = "uno_1",
        value = tweak_data.achievement.complete_heist_achievements.uno_1.bag_loot_value,
        remove_after_reaching_target = false,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.ValueOfBags
        }
    })
end
EHI:AddXPBreakdown({
    objective =
    {
        escape = 3000
    }
})