local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local drill_delay = 30 + 2 + 1.5
local escape_delay = 3 + 27 + 1
local ShowWaypoint = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101855] = { time = 120 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101854] = { time = 90 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101853] = { time = 60 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101849] = { time = 30 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101844] = { special_function = SF.Trigger, data = { 1018441, 1018442 } },
    [1018441] = { time = drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [1018442] = { time = 25, id = "ForcedAlarm", icons = { Icon.Alarm }, class = TT.Warning, condition_function = CF.IsStealth },
    [EHI:GetInstanceElementID(100008, 2835)] = { id = EHI:GetInstanceElementID(100002, 2835), special_function = ShowWaypoint, data = { icon = Icon.Drill } },

    [102223] = { time = 90 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102188] = { time = 60 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102187] = { time = 45 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102186] = { time = 30 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102190] = { time = escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100004, 2910)] = { id = EHI:GetInstanceElementID(100009, 2910), special_function = ShowWaypoint, data = { icon = Icon.Escape } },
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 25 + 30 })
}

EHI:ParseTriggers({ mission = triggers, other = other })
EHI:RegisterCustomSpecialFunction(ShowWaypoint, function(trigger, element, enabled)
    trigger.data.distance = true
    trigger.data.state = "sneak_present"
    trigger.data.present_timer = 0
    trigger.data.no_sync = true
    local e = managers.mission:get_element_by_id(trigger.id)
    trigger.data.position = e and e._values.position or Vector3()
    managers.hud:add_waypoint(trigger.id, trigger.data)
end)
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:RemoveTracker("ForcedAlarm")
end)
EHI:ShowLootCounter({ max = 8 })

local tbl =
{
    --levels/instances/unique/hox_estate_panic_room
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    [EHI:GetInstanceUnitID(100068, 2585)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100089, 2585) },
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100090, 2585)] = { icons = { Icon.Vault }, remove_on_pause = true },

    --levels/instances/unique/hox_estate_alarmbox
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100021, 9685)] = { icons = { Icon.Alarm }, warning = true, remove_on_pause = true }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        hox3_vault_objective = 2000,
        vault_found = 4000,
        vault_open = { amount = 4000, stealth = true },
        hox3_vault_open = 8000,
        hox3_traitor_killed = 2000,
        escape = 2000
    },
    loot_all = 1000
})