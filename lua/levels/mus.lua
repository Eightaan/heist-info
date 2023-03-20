local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local delay = 5
local gas_delay = 0.5
local triggers = {
    [102442] = { time = 130 + delay, special_function = SF.AddTrackerIfDoesNotExist },
    [102441] = { time = 120 + delay, special_function = SF.AddTrackerIfDoesNotExist },
    [102434] = { time = 110 + delay, special_function = SF.AddTrackerIfDoesNotExist },
    [102433] = { time = 80 + delay, special_function = SF.AddTrackerIfDoesNotExist },

    [102065] = { time = 50 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102067] = { time = 65 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102068] = { time = 80 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102069] = { time = 95 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102070] = { time = 110 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102071] = { time = 125 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102072] = { time = 140 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } }
}

local DisableWaypoints = {}

for i = 300, 375, 75 do
    DisableWaypoints[EHI:GetInstanceElementID(100033, i)] = true -- Fix
    DisableWaypoints[EHI:GetInstanceElementID(100034, i)] = true -- Defend
end

local achievements =
{
    bat_4 =
    {
        elements =
        {
            [100840] = { time = 600, class = TT.Achievement },
            [102531] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("bat_4", 600)
        end
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 35 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "Escape", Icon.HeliEscape)
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowAchievementLootCounter({
    achievement = "bat_3",
    max = 10,
    remove_after_reaching_target = false,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = { "mus_artifact_paint", "mus_artifact" }
    }
})

local tbl =
{
    --levels/instances/unique/mus_chamber_controller
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100347, 3575)] = { icons = { Icon.Wait }, remove_on_pause = true, warning = true },

    --levels/instances/unique/mus_security_room
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceUnitID(100041, 6950)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100050, 6950) }
}
for i = 300, 375, 75 do
    --levels/instances/unique/mus_security_barrier
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    tbl[EHI:GetInstanceUnitID(100020, i)] = { icons = { Icon.Keycard } }
end
EHI:UpdateUnits(tbl)

local MissionDoorPositions =
{
    -- Diamond Room Hatch
    [1] = Vector3(8638, 193.001, -519)
}
local MissionDoorIndex =
{
    [1] = { w_id = 100841 }
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)
EHI:AddXPBreakdown({
    objective =
    {
        mus_powerboxes_stealth = 6000,
        mus_first_timelock_stealth = 2000,
        mus_second_timelock_stealth = 2000,
        mus_no_gas_trap_stealth = 3000,
        mus_pc_hack_loud = 8000,
        mus_first_timelock_loud = 5000,
        mus_second_timelock_loud = 5000,
        mus_no_gas_trap_loud = 4000,
        escape =
        {
            { amount = 4000, stealth = true },
            { amount = 6000, loud = true }
        }
    },
    loot_all = 1000
})