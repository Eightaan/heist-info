local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local AddToCache = EHI:GetFreeCustomSpecialFunctionID()
local GetFromCache = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101145] = { time = 180, special_function = GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
    [101158] = { time = 240, special_function = GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
    [101977] = { special_function = AddToCache, data = { icon = Icon.Heli } },
    [101978] = { special_function = AddToCache, data = { icon = Icon.Heli } },
    [101979] = { special_function = AddToCache, data = { icon = Icon.Car } },

    [102110] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102120 } }, -- Heli
    [102130] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102138 } }, -- Heli
    [100953] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102141 } } -- Van
}

if EHI:IsClient() then
    triggers[101515] = { time = 175, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101532] = { time = 115, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[102089] = { time = 60, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101521] = { time = 30, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101513] = { time = 175, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101534] = { time = 115, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[102090] = { time = 60, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101571] = { time = 30, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
end

local achievements =
{
    you_shall_not_pass =
    {
        elements =
        {
            [101148] = { status = "defend", class = TT.AchievementStatus },
            [102471] = { special_function = SF.SetAchievementFailed },
            [100426] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100196] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround),
    [102007] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround),
    [102005] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround),
    [101975] = EHI:AddAssaultDelay({ time = 15 + 30, trigger_times = 1 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "Escape")
EHI:RegisterCustomSpecialFunction(AddToCache, function(trigger, ...)
    EHI._cache[trigger.id] = trigger.data
end)
EHI:RegisterCustomSpecialFunction(GetFromCache, function(trigger, ...)
    local data = EHI._cache[trigger.id]
    EHI._cache[trigger.id] = nil
    if data and data.icon then
        trigger.icons[1] = data.icon
    end
    EHI:CheckCondition(trigger)
end)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 8000
    }
})