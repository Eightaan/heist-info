local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 363/30
local triggers = {
    [100215] = { time = 120 + van_delay },
    [100216] = { time = 100 + van_delay },
    [100218] = { time = 80 + van_delay },
    [100219] = { time = 60 + van_delay },

    -- Heli
    [102200] = { special_function = SF.Trigger, data = { 1022001, 1022002 } },
    [1022001] = { time = 23, special_function = SF.SetTimeOrCreateTracker },
    [1022002] = { special_function = SF.ShowWaypoint, data = { icon = Icon.LootDrop, position_by_element = 102650 } },

    [100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } }
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 10)
    end)
end

local other =
{
    [101620] = { special_function = SF.Trigger, data = { 1016201 }, trigger_times = 1 },
    [1016201] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement, trigger_times = 1 },
}

EHI:ParseTriggers({ mission = triggers, other = other }, "Escape", { Icon.Escape, Icon.LootDrop })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000
})