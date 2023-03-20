local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 674/30
local preload =
{
    {} -- Escape
}
local triggers = {
    [101880] = { run = { time = 120 + van_delay } },
    [101881] = { run = { time = 100 + van_delay } },
    [101882] = { run = { time = 80 + van_delay } },
    [101883] = { run = { time = 60 + van_delay } },

    [100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } },
    [100215] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } }
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 15)
    end)
end

local other =
{
    [100916] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },
}

EHI:ParseTriggers({ mission = triggers, other = other, preload = preload }, "Escape", Icon.CarEscape)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000
})