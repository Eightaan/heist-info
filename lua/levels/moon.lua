local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101176] = { time = 67 + 400/30, id = "WinchInteract", icons = { Icon.Heli, Icon.Winch } },
    [106390] = { time = 6 + 30 + 25 + 15 + 2.5, id = "C4", icons = Icon.HeliDropC4 },
    -- 6s delay before Bile speaks
    -- 30s delay before random logic
    -- 25s delay to execute random logic
    -- Random logic has defined 2 heli fly ins
    -- First is shorter (6.5 + 76/30) 76/30 => 2.533333 (rounded to 2.5 in Mission Script)
    -- Second is longer (15 + 76/30)
    -- Second animation is counted in this trigger, the first is in trigger 100578.
    -- If the first fly-in is selected, the tracker is updated to reflect that

    [100647] = { time = 10, id = "SantaTalk", icons = { "pd2_talk" }, special_function = SF.ExecuteIfElementIsEnabled },
    [100159] = { time = 5 + 7 + 7.3, id = "Escape", icons = { Icon.Escape }, special_function = SF.ExecuteIfElementIsEnabled },

    [100578] = { time = 9, id = "C4", icons = { Icon.Heli, Icon.C4, Icon.Goto }, special_function = SF.SetTimeOrCreateTracker }
}

local DisableWaypoints =
{
    -- Drill WP in the tech store
    [100241] = true,

    -- Fix Jewelry Store PC hack WP
    [100828] = true,

    -- Drill WP in the cage (shoe objective)
    [100664] = true
}

local achievements =
{
    moon_4 =
    {
        elements =
        {
            [100107] = { max = 2, class = TT.AchievementProgress, trigger_times = 1 },
            [104219] = { special_function = SF.IncreaseProgress }, -- Chains
            [104220] = { special_function = SF.IncreaseProgress } -- Dallas
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 45 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:DisableWaypoints(DisableWaypoints)
if EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    EHI:ShowAchievementLootCounter({
        achievement = "moon_5",
        max = 9,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = { "money", "diamonds" }
        }
    })
end
EHI:ShowLootCounter({ max = 12 })

local tbl =
{
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    --Jewelry Store
    [105874] = { remove_vanilla_waypoint = true, waypoint_id = 100776 }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        random =
        {
            max = 3,
            shoe_storage =
            {
                { amount = 1000, name = "shoe_storage_enter" },
                { amount = 500, name = "shoe_collected" }
            },
            shoe_backroom =
            {
                { amount = 4000, name = "shoe_backroom_enter" },
                { amount = 500, name = "shoe_collected" }
            },
            jewelry =
            {
                { amount = 1500, name = "pc_hack" },
                { amount = 500, name = "necklace_collected" }
            },
            toy =
            {
                { amount = 4000, name = "toy_found" },
                { amount = 800, name = "toy_collected" }
            },
            vr =
            {
                { amount = 6000, name = "vault_drill_done" },
                { amount = 500, name = "vr_collected" }
            },
            wine =
            {
                { amount = 800, name = "wine_collected" }
            }
        },
        flare = 500,
        c4_drop = 1000,
        c4_set_up = 1000,
        heli_arrival = 1000,
        wires_attached = 500
    },
    loot =
    {
        money = 1000,
        diamonds = 1000
    }
})