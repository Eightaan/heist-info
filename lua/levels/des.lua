local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [108538] = { time = 60, id = "Gas", icons = { Icon.Teargas } },

    [103025] = { id = 1030251, special_function = SF.Trigger, trigger_times = 1 },
    [1030251] = { time = 3, id = "des_11", class = TT.Achievement, trigger_times = 1 },
    [102822] = { id = "des_11", special_function = SF.SetAchievementComplete },
    [100716] = { time = 30, id = "ChemLabThermite", icons = { Icon.Fire } },

    [100423] = { time = 60 + 25 + 3, id = "EscapeHeli", icons = Icon.HeliEscape },
    -- 60s delay after flare has been placed
    -- 25s to land
    -- 3s to open the heli doors

    [102593] = { time = 30, id = "ChemSetReset", icons = { Icon.Methlab, Icon.Loop } },
    [101217] = { time = 30, id = "ChemSetInterrupted", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "ChemSetCooking" } },
    [102595] = { time = 30, id = "ChemSetCooking", icons = { Icon.Methlab } },

    [102009] = { time = 60, id = "Crane", icons = { Icon.Winch }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101702] = { id = "Crane", special_function = SF.PauseTracker },

    [100729] = { chance = 20, id = "HackChance", icons = { Icon.PCHack }, class = TT.Chance },
    [108694] = { id = "HackChance", special_function = SF.IncreaseChanceFromElement }, -- +33%
    [101485] = { id = "HackChance", special_function = SF.RemoveTracker }
}
if EHI:IsClient() then
    triggers[100564] = { time = 25 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    -- Not worth adding the 3s delay here
end

local DisableWaypoints =
{
    -- Hackboxes at the start
    [EHI:GetInstanceElementID(100007, 11000)] = true, -- Defend
    [EHI:GetInstanceElementID(100008, 11000)] = true, -- Fix
    [EHI:GetInstanceElementID(100007, 11500)] = true, -- Defend
    [EHI:GetInstanceElementID(100008, 11500)] = true, -- Fix

    -- Archaeology
    [EHI:GetInstanceElementID(100008, 21000)] = true, -- Defend
    -- Interact is disabled in CoreWorldInstanceManager.lua

    -- Turret charging computer
    [101122] = true, -- Defend
    [103191] = true, -- Fix

    -- Outside hack turret box
    [102901] = true, -- Defend
    [102902] = true, -- Fix
    [102926] = true, -- Defend
    [102927] = true -- Fix
}

-- levels/instances/unique/des/des_computer/001-004
for i = 3000, 4500, 500 do
    DisableWaypoints[EHI:GetInstanceElementID(100025, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100026, i)] = true -- Fix
end

-- levels/instances/unique/des/des_computer/012
DisableWaypoints[EHI:GetInstanceElementID(100025, 8500)] = true -- Defend
DisableWaypoints[EHI:GetInstanceElementID(100026, 8500)] = true -- Fix

-- levels/instances/unique/des/des_computer_001/001
-- levels/instances/unique/des/des_computer_002/001
for i = 6000, 6500, 500 do
    DisableWaypoints[EHI:GetInstanceElementID(100025, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100026, i)] = true -- Fix
end

-- levels/instances/unique/des/des_computer_002/002
DisableWaypoints[EHI:GetInstanceElementID(100025, 29550)] = true -- Defend
DisableWaypoints[EHI:GetInstanceElementID(100026, 29550)] = true -- Fix

local achievements =
{
    des_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { status = "push", class = TT.AchievementStatus },
            [102480] = { special_function = SF.Trigger, data = { 1024801, 1024802 } },
            [1024801] = { status = "finish", special_function = SF.SetAchievementStatus },
            [1024802] = { id = 102486, special_function = SF.RemoveTrigger },
            [102710] = { special_function = SF.SetAchievementComplete },
            [102486] = { special_function = SF.SetAchievementFailed }
        }
    },
    uno_5 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100296] = { max = 2, class = TT.AchievementProgress },
            [103391] = { special_function = SF.IncreaseProgress },
            [103395] = { special_function = SF.SetAchievementFailed },
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    --units/pd2_dlc_des/props/des_prop_inter_hack_computer/des_inter_hack_computer
    [103009] = { icons = { Icon.Power } },

    --units/pd2_dlc_dah/props/dah_prop_hack_box/dah_prop_hack_ipad_unit
    [101323] = { remove_on_power_off = true },
    [101324] = { remove_on_power_off = true },

    --levels/instances/unique/des/des_drill
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small_no_jam
    [EHI:GetInstanceUnitID(100030, 21000)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100009, 21000) }
}
EHI:UpdateUnits(tbl)
EHI:ShowLootCounter({
    max = 2,
    additional_loot = 6
})
EHI:AddXPBreakdown({
    objective =
    {
        diamond_heist_boxes_hack = 2000,
        henrys_rock_first_mission_bag_on_belt = 2000,
        ed1_hack_1 = 2000,
        random =
        {
            max = 2,
            archaelogy =
            {
                { amount = 6000, name = "henrys_rock_drilled_archaelogy_door" },
                { amount = 2000, name = "henrys_rock_archaelogy_chest_open" }
            },
            biolab =
            {
                { amount = 6000, name = "henrys_rock_made_concoction" }
            },
            weapon_lab =
            {
                { amount = 4000, name = "henrys_rock_weapon_fired", times = 2 }
            },
            computer_lab =
            {
                { amount = 2000, name = "pc_hack" },
                { amount = 2000, name = "henrys_rock_crane" }
            }
        },
        twh_disable_aa = 4000,
        escape = 6000
    },
    loot =
    {
        mus_artifact = 2000
    }
})