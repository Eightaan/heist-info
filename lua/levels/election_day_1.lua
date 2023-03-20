local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local achievements =
{
    bob_8 =
    {
        elements =
        {
            [100012] = { class = TT.AchievementStatus },
            [101248] = { special_function = SF.SetAchievementComplete },
            [100469] = { special_function = SF.SetAchievementFailed }
        }
    },
    slakt_1 =
    {
        elements =
        {
            [100003] = { time = 60, class = TT.Achievement }
        }
    }
}

EHI:ParseTriggers({
    achievement = achievements
})

local tbl =
{
    --units/payday2/props/off_prop_eday_shipping_computer/off_prop_eday_shipping_computer
    [101210] = { remove_vanilla_waypoint = true, waypoint_id = 101887, ignore_visibility = true, restore_waypoint_on_done = true },
    [101289] = { remove_vanilla_waypoint = true, waypoint_id = 101910, ignore_visibility = true, restore_waypoint_on_done = true },
    [101316] = { remove_vanilla_waypoint = true, waypoint_id = 101913, ignore_visibility = true, restore_waypoint_on_done = true },
    [101317] = { remove_vanilla_waypoint = true, waypoint_id = 101914, ignore_visibility = true, restore_waypoint_on_done = true },
    [101318] = { remove_vanilla_waypoint = true, waypoint_id = 101922, ignore_visibility = true, restore_waypoint_on_done = true },
    [101320] = { remove_vanilla_waypoint = true, waypoint_id = 101923, ignore_visibility = true, restore_waypoint_on_done = true }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        ed1_tag_right_truck = { amount = 2000, stealth = true },
        ed1_hack_1 = { amount = 12000, loud = true },
        ed1_hack_2 = { amount = 12000, loud = true },
        stealth_escape = 6000
    },
    no_total_xp = true
})