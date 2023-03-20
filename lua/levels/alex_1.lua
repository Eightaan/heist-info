local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local anim_delay = 2 + 727/30 + 2 -- 2s is function delay; 727/30 is a animation duration; 2s is zone activation delay; total 28,23333
local assault_delay = 4 + 3 + 3 + 3 + 5 + 1 + 30
local assault_delay_methlab = 20 + assault_delay
local SetTimeIfMoreThanOrCreateTracker = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101001] = { id = "CookChance", special_function = SF.RemoveTracker },

    [101970] = { time = (240 + 12) - 3, waypoint = { position_by_element = 101454 } },
    [100721] = { time = 1, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1007211 } },
    [1007211] = { chance = 5, id = "CookChance", icons = { Icon.Methlab }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },
    [100724] = { time = 25, id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.SetTimeOrCreateTracker },
    [100199] = { time = 5 + 1, id = "CookingDone", icons = { Icon.Methlab, Icon.Interact } },

    [1] = { special_function = SF.RemoveTrigger, data = { 101974, 101975, 101970 } },
    [101974] = { special_function = SF.Trigger, data = { 1019741, 1 } },
    -- There is an issue in the script. Even if the van driver says 2 minutes, he arrives in a minute
    [1019741] = { time = (60 + 30 + anim_delay) - 58, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { position_by_element = 101454 } },
    [101975] = { special_function = SF.Trigger, data = { 1019751, 1 } },
    [1019751] = { time = 30 + anim_delay, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { position_by_element = 101454 } },

    [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { Icon.Heli, "heavy", Icon.Goto }, class = TT.Warning },

    [100723] = { amount = 10, id = "CookChance", special_function = SF.IncreaseChance }
}
local achievements =
{
    halloween_1 =
    {
        elements =
        {
            [101088] = { status = "ready", class = TT.AchievementStatus },
            [101907] = { status = "defend", special_function = SF.SetAchievementStatus },
            [101917] = { special_function = SF.SetAchievementComplete },
            [101914] = { special_function = SF.SetAchievementFailed },
            [101001] = { special_function = SF.SetAchievementFailed } -- Methlab exploded
        }
    }
}
local other =
{
    [100378] = EHI:AddAssaultDelay({ time = 42 + 50 + assault_delay }),
    [100380] = EHI:AddAssaultDelay({ time = 45 + 40 + assault_delay }),
    [100707] = EHI:AddAssaultDelay({ time = assault_delay_methlab, special_function = SetTimeIfMoreThanOrCreateTracker, trigger_times = 1 }),
    [101863] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "Van", Icon.CarEscape)
if EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    EHI:ShowAchievementLootCounter({
        achievement = "halloween_2",
        max = 7,
        triggers =
        {
            [101001] = { special_function = SF.SetAchievementFailed } -- Methlab exploded
        },
        add_to_counter = true
    })
else
    EHI:ShowLootCounter({ max = 7 })
end
EHI:RegisterCustomSpecialFunction(SetTimeIfMoreThanOrCreateTracker, function(trigger, ...)
    if managers.ehi:TrackerExists(trigger.id) then
        local tracker = managers.ehi:GetTracker(trigger.id)
        if tracker then
            if tracker._time >= trigger.time then
                managers.ehi:SetTrackerTime(trigger.id, trigger.time)
            end
        else
            EHI:CheckCondition(trigger)
        end
    else
        EHI:CheckCondition(trigger)
    end
end)
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 25)
    end)
    EHI:AddLoadSyncFunction(function(self)
        if managers.environment_effects._mission_effects[101437] then
            self:AddEscapeChanceTracker(false, 105)
            EHI:UnhookElement(101863)
        else
            self:AddEscapeChanceTracker(false, 35)
            -- Disable increase when the cooks got killed by gangster in case the player dropins
            -- after Escape Chance is shown on screen and before they get killed by mission script
            self.IncreaseCivilianKilled = function(...)
            end
        end
    end)
end
EHI:AddXPBreakdown({
    objective =
    {
        rats_lab_exploded = 12000,
        rats_3_bags_cooked = 30000,
        rats_all_7_bags_cooked = 40000
    },
    no_total_xp = true
})