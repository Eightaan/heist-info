local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local element_sync_triggers =
{
    -- Time before the tear gas is removed
    [102074] = { time = 3 + 2, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist, hook_element = 102073 }
}
local triggers = {
    [102949] = { time = 17, id = "HeliDropWait", icons = { Icon.Wait } },
    [100246] = { time = 31, id = "TearGasOffice", icons = { Icon.Teargas }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "TearGasOfficeChance" } },
    [101580] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, condition = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard), class = TT.Chance },
    -- Disabled in the mission script
    --[101394] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists }, -- It will not run on Hard and below
    [101377] = { amount = 20, id = "TearGasOfficeChance", special_function = SF.IncreaseChance },
    [101393] = { id = "TearGasOfficeChance", special_function = SF.RemoveTracker },
    [102544] = { time = 8.3, id = "HumveeWestWingCrash", icons = { Icon.Car, Icon.Fire }, class = TT.Warning },

    [102335] = { time = 60, id = "Thermite", icons = { Icon.Fire } }, -- units/pd2_dlc_vit/props/security_shutter/vit_prop_branch_security_shutter
    [102104] = { time = 30 + 26, id = "LockeHeliEscape", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element = 101914 } } -- 30s delay + 26s escape zone delay
}
if EHI:IsClient() then
    triggers[102073] = { time = 30 + 3 + 2, random_time = 10, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[103500] = { time = 26, id = "LockeHeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { icon = Icon.Escape, position_by_element = 101914 } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30 })
}

EHI:ParseTriggers({ mission = triggers, other = other })

local DisableWaypoints =
{
    -- levels/instances/unique/vit/vit_targeting_computer/001
    [EHI:GetInstanceElementID(100002, 10500)] = true, -- Defend
    [EHI:GetInstanceElementID(100003, 10500)] = true -- Fix
}
-- levels/instances/unique/vit/vit_wire_box
-- All 4 colors
for i = 4150, 4450, 100 do
    DisableWaypoints[EHI:GetInstanceElementID(100074, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100050, i)] = true -- Fix
end
for i = 30000, 31500, 300 do
    DisableWaypoints[EHI:GetInstanceElementID(100059, i)] = true -- Fix
end
EHI:DisableWaypoints(DisableWaypoints)

--[[local tbl =
{
    [EHI:GetInstanceUnitID(100239, 12900)] = { f = function(unit_id, unit_data, unit)
        EHI:HookWithID(unit:timer_gui(), "set_jammed", "EHI_100239_12900_unjammed", function(self, jammed, ...)
            if jammed == false then
                self:_HideWaypoint(unit_data.waypoint_id)
            end
        end)
        unit:timer_gui():RemoveVanillaWaypoint(unit_data.waypoint_id)
    end, waypoint_id = EHI:GetInstanceElementID(100255, 12900) }
}
for i = 30000, 31500, 300 do
    tbl[EHI:GetInstanceUnitID(100045, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100058, i) }
end
EHI:UpdateUnits(tbl)]]
EHI:AddXPBreakdown({
    objective =
    {
        twh_entered = 1000,
        twh_wireboxes_hacked = { amount = 4000, loud = true },
        twh_wireboxes_cut = { amount = 2000, stealth = true },
        twh_enter_west_wing = 2000,
        twh_found_thermite = { amount = 2000, loud = true },
        twh_use_thermite = { amount = 1000, loud = true },
        twh_enter_oval_office = 2000,
        twh_safe_open = 8000,
        twh_access_peoc = 4000,
        twh_mainframe_hacked = 8000,
        twh_pardons_stolen = 2000,
        twh_left_peoc = 2000,
        twh_disable_aa = { amount = 4000, loud = true },
        heli_arrival = 2000
    }
})