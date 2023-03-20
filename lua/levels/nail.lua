local EHI = EHI
local Icon = EHI.Icons
local triggers = {
    [101505] = { time = 10, id = "TruckDoorOpens", icons = { "pd2_door" } },
    -- There are a lot of delays in the ID. Using average instead (5.2)
    [101806] = { time = 20 + 5.2, id = "ChemicalsDrop", icons = { Icon.Heli, Icon.Methlab, Icon.Goto } },

    [101936] = { time = 30 + 12, id = "Escape", icons = Icon.HeliEscapeNoLoot }
}

EHI:ParseTriggers({ mission = triggers })

local tbl =
{
    --levels/instances/unique/nail_cloaker_safe
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100014, 5020)] = { ignore = true },
    [EHI:GetInstanceUnitID(100056, 5020)] = { ignore = true },
    [EHI:GetInstanceUnitID(100226, 5020)] = { ignore = true },
    [EHI:GetInstanceUnitID(100227, 5020)] = { icons = { Icon.Vault }, remove_on_pause = true, completion = true }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        lab_rats_added_ephedrin_pill = 2000,
        lab_rats_added_correct_ingredient = 1000,
        lab_rats_bagged_meth = 500,
        lab_rats_safe_event_1 = 30000,
        lab_rats_safe_event_2 = 22500,
        lab_rats_safe_event_3 = 15000,
        escape = 5000
    },
    loot =
    {
        half_meth = 500,
    },
    no_total_xp = true
})