local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local delay = 17 + 30 + 450/30 -- Boat escape; Van escape is 100215 and 100216
local triggers = {
    [100259] = { time = 120 + delay },
    [100258] = { time = 100 + delay },
    [100257] = { time = 80 + delay },
    [100209] = { time = 60 + delay },

    [100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 100233 } },
    [100215] = { special_function = SF.Trigger, data = { 1002151, 1002152 } },
    [1002151] = { time = 674/30, special_function = SF.SetTimeOrCreateTracker },
    [1002152] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } },
    [100216] = { special_function = SF.Trigger, data = { 1002161, 1002162 } },
    [1002161] = { time = 543/30, special_function = SF.SetTimeOrCreateTracker },
    [1002162] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100020 } }
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 15)
    end)
end

local other =
{
    [104800] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },
}

EHI:ParseTriggers({ mission = triggers, other = other }, "Escape", { Icon.Escape, Icon.LootDrop })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000
})