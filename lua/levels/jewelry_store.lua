local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [101541] = { time = 2, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [101558] = { time = 5, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [101601] = { time = 7, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },

    [103172] = { time = 45 + 830/30, id = "Van", icons = Icon.CarEscape },
    [103183] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103194 } },
    [103182] = { special_function = SF.Trigger, data = { 1031821, 1031822 } },
    [1031821] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031822] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103193 } },
    [103181] = { special_function = SF.Trigger, data = { 1031811, 1031812 } },
    [1031811] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031812] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103192 } },
    [101770] = { special_function = SF.Trigger, data = { 1017701, 1017702 } },
    [1017701] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1017702] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101776 } },

    [101433] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}
if EHI:GetOption("show_escape_chance") then
    local start_chance = 25 -- Normal
    if EHI:IsDifficulty(EHI.Difficulties.Hard) then
        start_chance = 27
    elseif EHI:IsDifficulty(EHI.Difficulties.VeryHard) then
        start_chance = 32
    elseif ovk_and_up then
        start_chance = 36
    end
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, start_chance)
    end)
end

local achievements =
{
    ameno_7 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100073] = { status = "loud", class = TT.AchievementStatus },
            [100624] = { special_function = SF.SetAchievementFailed },
            [100634] = { special_function = SF.SetAchievementComplete },
            [100149] = { status = "defend", special_function = SF.SetAchievementStatus }
        }
    }
}
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 2000, timer = 120, stealth = true },
            { amount = 6000, stealth = true },
            { amount = 8000, loud = true }
        }
    }
})