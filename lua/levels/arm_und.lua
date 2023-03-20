local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 674/30
local preload =
{
    {} -- Escape
}
local triggers = {
    [101235] = { run = { time = 120 + van_delay } },
    [100257] = { run = { time = 100 + van_delay } },
    [100209] = { run = { time = 80 + van_delay } },
    [100208] = { run = { time = 60 + van_delay } },

    [1] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist },
    [100214] = { special_function = SF.Trigger, data = { 1, 1002141 } },
    [1002141] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } },
    [100215] = { special_function = SF.Trigger, data = { 1, 1002151 } },
    [1002151] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101268 } },
    [100216] = { special_function = SF.Trigger, data = { 1, 1002161 } },
    [1002161] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } }
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 10)
    end)
end

local other =
{
    [100677] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },
}

EHI:ParseTriggers({ mission = triggers, other = other, preload = preload }, "Escape", Icon.CarEscape)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000
})