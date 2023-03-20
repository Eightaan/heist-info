local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local pink_car = { { icon = Icon.Car, color = Color("D983D1") }, Icon.Goto }
local ExecuteIfEnabled = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [100727] = { time = 6 + 18 + 8.5 + 30 + 25 + 375/30, id = "Escape", icons = Icon.CarEscape },
    [100207] = { time = 260/30, id = "Escape", icons = Icon.CarEscape, special_function = ExecuteIfEnabled },
    [100209] = { time = 250/30, id = "Escape", icons = Icon.CarEscape, special_function = ExecuteIfEnabled },

    --310/30 anim_crash_04; Waypoint ID 100490
    [100169] = { time = 17 + 1 + 310/30, id = "PinkArrival", icons = pink_car },
    --260/30 anim_crash_02; Waypoint ID 101196
    [101114] = { time = 260/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },
    --201/30 anim_crash_05; Waypoint ID 101201
    [101127] = { time = 201/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },
    --284/30 anim_crash_03; Waypoint ID 101138
    [101108] = { time = 284/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },

    [101105] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100490 } },
    [101104] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101196 } },
    [101106] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101201 } },
    [101102] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101138 } }
}
if EHI:IsClient() then
    triggers[100731] = { time = 18 + 8.5 + 30 + 25 + 375/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100716] = { time = 8.5 + 30 + 25 + 375/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100286] = { time = 30 + 25 + 375/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101065] = { time = 25 + 375/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
end

local achievements =
{
    rvd_9 =
    {
        elements =
        {
            [100107] = { status = "defend", class = TT.AchievementStatus },
            [100839] = { special_function = SF.SetAchievementFailed },
            [100869] = { special_function = SF.SetAchievementComplete },
        }
    },
    rvd_10 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [100057] = { time = 60, class = TT.Achievement, special_function = SF.ShowAchievementFromStart },
            [100247] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100179] = EHI:AddAssaultDelay({ time = 1 + 9.5 + 11 + 1 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:RegisterCustomSpecialFunction(ExecuteIfEnabled, function(trigger, element, enabled)
    if enabled then
        if managers.ehi:TrackerExists(trigger.id) then
            managers.ehi:SetTrackerTime(trigger.id, trigger.time)
        else
            EHI:CheckCondition(trigger)
        end
    end
end)
EHI:AddXPBreakdown({
    objective =
    {
        rvd1_defended_warehouse = 4000,
        rvd1_escorted_pink = 4000,
        saw_done = 1500
    },
    loot_all = 1000
})