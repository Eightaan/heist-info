local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local zone_delay = 12
local LootDropWaypoint = { icon = Icon.LootDrop, position_by_element = 104215, class = EHI.Waypoints.Warning }
--104215 Vector3(1400, 3125, 125) pd2_lootdrop
local triggers = {
    [1] = { special_function = SF.CustomCode, f = function()
        if not EHI:GetOption("show_waypoints") then
            return
        end
        managers.hud:SoftRemoveWaypoint(104215)
        EHI:DisableElementWaypoint(104215)
    end},
    [104176] = { time = 25 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 }, waypoint = deep_clone(LootDropWaypoint) },
    [104178] = { time = 35 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 }, waypoint = deep_clone(LootDropWaypoint) },

    [103172] = { time = 2 + 830/30, id = "Van", icons = Icon.CarEscape },
    [103183] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103194 } },
    [103182] = { special_function = SF.Trigger, data = { 1031821, 1031822 } },
    [1031821] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031822] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103193 } },
    [103181] = { special_function = SF.Trigger, data = { 1031811, 1031812 } },
    [1031811] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031812] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103192 } },
    [101770] = { special_function = SF.Trigger, data = { 1017701, 1017702 } },
    [1017701] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1017702] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101776 } }
}
if EHI:GetOption("show_escape_chance") then
    local start_chance = 30 -- Normal
    if EHI:IsDifficulty(EHI.Difficulties.Hard) then
        start_chance = 33
    elseif EHI:IsDifficulty(EHI.Difficulties.VeryHard) then
        start_chance = 35
    elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
        start_chance = 37
    end
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, start_chance)
    end)
end

local ExecuteAchievementIfInteractionExists = EHI:GetFreeCustomSpecialFunctionID()
local achievements =
{
    lets_do_this =
    {
        elements =
        {
            [100073] = { time = 36, class = TT.Achievement },
            [101784] = { special_function = SF.SetAchievementComplete },
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("lets_do_this", 36)
        end
    },
    cac_12 =
    {
        elements =
        {
            [100074] = { status = "alarm", class = TT.AchievementStatus, special_function = ExecuteAchievementIfInteractionExists },
            [104406] = { status = "finish", special_function = SF.SetAchievementStatus },
            [104408] = { special_function = SF.SetAchievementComplete },
            [104409] = { special_function = SF.SetAchievementFailed },
            [103116] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [101614] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:RegisterCustomSpecialFunction(ExecuteAchievementIfInteractionExists, function(trigger, ...)
    if managers.ehi:InteractionExists("circuit_breaker_off") then
        EHI:CheckCondition(trigger)
    end
end)
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 4000, timer = 120, stealth = true },
            { amount = 10000, loud = true }
        }
    }
})