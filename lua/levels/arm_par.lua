local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 543/30
local preload =
{
    {} -- Escape
}
local triggers = {
    [100258] = { run = { time = 120 + van_delay } },
    [100257] = { run = { time = 100 + van_delay } },
    [100209] = { run = { time = 80 + van_delay } },
    [100208] = { run = { time = 60 + van_delay } },

    [1] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist },
    [100214] = { special_function = SF.Trigger, data = { 1, 1002141 } },
    [1002141] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } },
    [100215] = { special_function = SF.Trigger, data = { 1, 1002151 } },
    [1002151] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } },
    [100216] = { special_function = SF.Trigger, data = { 1, 1002161 } },
    [1002161] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100020 } },
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(false, 15)
    end)
end

if EHI:IsClient() then
    triggers[102379] = { time = 30 + van_delay, special_function = SF.AddTrackerIfDoesNotExist }
end

EHI:ParseTriggers({ mission = triggers, preload = preload }, "Escape", Icon.CarEscape)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000
})