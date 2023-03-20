local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100643] = { time = 30, id = "CrowdAlert", icons = { Icon.Alarm }, class = TT.Warning },
    [100645] = { id = "CrowdAlert", special_function = SF.RemoveTracker },

    [101725] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape }, -- West
    [101845] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape }, -- East

    [EHI:GetInstanceElementID(100004, 6200)] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Heli, position_by_element = EHI:GetInstanceElementID(100013, 6200) } }, -- West
    [EHI:GetInstanceElementID(100015, 6100)] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Heli, position_by_element = EHI:GetInstanceElementID(100013, 6100) } } -- East
}

if EHI:IsClient() then
    triggers[EHI:GetInstanceElementID(100030, 6100)] = { time = 113 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100033, 6100)] = { time = 107 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100034, 6100)] = { time = 47 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100035, 6100)] = { time = 17 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100030, 6200)] = { time = 113 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100033, 6200)] = { time = 107 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100034, 6200)] = { time = 47 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100035, 6200)] = { time = 17 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
end

local achievements =
{
    sah_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100107] = { time = 300, class = TT.Achievement },
            [101878] = { special_function = SF.SetAchievementComplete },
            [101400] = { special_function = SF.SetAchievementFailed, trigger_times = 1 }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 1 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local DisableWaypoints = {}
-- Hackboxes
-- 1-10
for i = 3900, 4800, 100 do
    DisableWaypoints[EHI:GetInstanceElementID(100016, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100042, i)] = true -- Fix
end
-- 11-17
for i = 16950, 17550, 100 do
    DisableWaypoints[EHI:GetInstanceElementID(100016, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100042, i)] = true -- Fix
end
-- Office
for i = 18200, 19400, 600 do
    -- Drill
    -- No defend icon, drill icon is disabled after drill unit has been placed
    DisableWaypoints[EHI:GetInstanceElementID(100320, i)] = true -- Fix
    -- Computer
    -- No defend icon, computer icon is disabled after computer unit has been interacted with
    DisableWaypoints[EHI:GetInstanceElementID(100087, i)] = true -- Fix
end
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    -- Unused Grenade case
    [400178] = { f = "IgnoreDeployable" }
}
for i = 4900, 5100, 100 do
    --levels/instances/unique/sah/sah_vault_door
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    tbl[EHI:GetInstanceUnitID(100001, i)] = { icons = { Icon.Vault } }
end
for i = 18200, 19400, 600 do
    --levels/instances/unique/sah/sah_office
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small_no_jam
    tbl[EHI:GetInstanceUnitID(100064, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100068, i) }
    --units/pd2_dlc_sah/props/sah_interactable_hack_computer/sah_interactable_hack_computer
    tbl[EHI:GetInstanceUnitID(100168, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100084, i) }
end
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        sah_vault_seen_stealth = 4000,
        sah_vault_seen_loud = 6000,
        sah_entered_vault_code_stealth = 6000,
        sah_entered_vault_code_loud = 10000,
        sah_retrieved_tablet_stealth = 4000,
        sah_retrieved_tablet_loud = 6000,
        escape =
        {
            { amount = 1000, stealth = true },
            { amount = 4000, loud = true }
        }
    },
    loot =
    {
        black_tablet = 1000,
        mus_artifact = 1000
    }
})