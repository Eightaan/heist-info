local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100247] = { time = 180 },
    [100248] = { time = 120 },

    [100154] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100318 } },
    [100157] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100314 } },
    [100156] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100367 } }
}

local achievements =
{
    frappucino_to_go_please =
    {
        elements =
        {
            [100287] = { time = 30, class = TT.Achievement },
            [101379] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100968] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround),
    [100969] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround),
    [100970] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround)
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "Escape", Icon.CarEscape)

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
        escape = 6000
    }
})