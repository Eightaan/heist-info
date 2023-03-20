local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local inspect = 30
local escape = 23 + 7
local triggers = {
    [100266] = { time = 30 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [100271] = { time = 45 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [100273] = { time = 60 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [103319] = { time = 75 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.AddTrackerIfDoesNotExist },
    [100265] = { time = 45 + 75 + inspect, id = "Inspect", icons = { Icon.Wait } },

    [103132] = { time = 210 + 90 + 30 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop }, -- Includes heli refuel (330s)
    [103130] = { time = 90 + 30 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [103133] = { time = 30 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [103630] = { time = 240, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [100372] = { time = 150, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [100371] = { time = 120, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [100363] = { time = 90, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [100355] = { time = 60, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },

    -- Heli escape
    [100898] = { time = 15 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [100902] = { time = 30 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [100904] = { time = 45 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [100905] = { time = 60 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot }
}

EHI:ParseTriggers({ mission = triggers })

local tbl =
{
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [103320] = { remove_vanilla_waypoint = true, waypoint_id = 100309 },
    [101365] = { remove_vanilla_waypoint = true, waypoint_id = 102499 },
    [101863] = { remove_vanilla_waypoint = true, waypoint_id = 102498 }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        pc_found = 3000,
        pc_hack = 6000,
        big_oil2_correct_engine = 6000,
        escape = 6000
    }
})