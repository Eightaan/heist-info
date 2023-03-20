local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local anim_delay = 450/30
local boat_delay = 60 + 30 + 30 + 450/30
local boat_icon = { Icon.Boat, Icon.LootDrop }
local AddToCache = EHI:GetFreeCustomSpecialFunctionID()
local GetFromCache = EHI:GetFreeCustomSpecialFunctionID()
local uno_8 = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101560] = { time = 35 + 75 + 30 + boat_delay, id = "BoatLootFirst" },
    -- 101127 tracked in 101560
    [101117] = { time = 60 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
    [101122] = { time = 40 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
    [101119] = { time = 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },

    [100323] = { time = 50 + 23, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },

    [101129] = { time = 180 + anim_delay, special_function = AddToCache },
    [101134] = { time = 150 + anim_delay, special_function = AddToCache },
    [101144] = { time = 130 + anim_delay, special_function = AddToCache },

    [101148] = { icons = boat_icon, special_function = GetFromCache },
    [101149] = { icons = boat_icon, special_function = GetFromCache },
    [101150] = { icons = boat_icon, special_function = GetFromCache },

    [1011480] = { time = 130 + anim_delay, random_time = 50 + anim_delay, id = "BoatLootDropReturnRandom", icons = boat_icon, class = TT.Inaccurate }
}
if EHI:IsClient() then
    local SetTrackerAccurate = EHI:GetFreeCustomSpecialFunctionID()
    local boat_return = { time = 450/30, id = "BoatLootDropReturnRandom", id2 = "BoatLootDropReturn", id3 = "BoatLootFirst", special_function = SetTrackerAccurate }
    triggers[100470] = boat_return
    triggers[100472] = boat_return
    triggers[100474] = boat_return
    EHI:RegisterCustomSpecialFunction(SetTrackerAccurate, function(trigger, ...)
        if managers.ehi:TrackerExists(trigger.id) then
            managers.ehi:SetTrackerAccurate(trigger.id, trigger.time)
        elseif not (managers.ehi:TrackerExists(trigger.id2) or managers.ehi:TrackerExists(trigger.id3)) then
            EHI:CheckCondition(trigger)
        end
    end)
end

local achievements =
{
    uno_8 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100124] = { status = "defend", class = TT.AchievementStatus, special_function = uno_8 },
            [102382] = { special_function = SF.SetAchievementFailed },
            [102379] = { special_function = SF.SetAchievementComplete }
        },
        cleanup_callback = function()
            EHI:UnregisterCustomSpecialFunction(uno_8)
        end
    }
}

local other =
{
    [100124] = EHI:AddLootCounter(function()
        local bags = managers.ehi:CountLootbagsOnTheGround() - 10
        EHI:ShowLootCounterNoCheck({ max = bags })
    end)
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "BoatLootDropReturn", boat_icon)
EHI:RegisterCustomSpecialFunction(AddToCache, function(trigger, ...)
    EHI._cache[trigger.id] = trigger.time
end)
EHI:RegisterCustomSpecialFunction(GetFromCache, function(trigger, ...)
    local t = EHI._cache[trigger.id]
    EHI._cache[trigger.id] = nil
    if t then
        trigger.time = t
        EHI:CheckCondition(trigger)
        trigger.time = nil
    else
        EHI:CheckCondition(triggers[1011480])
    end
end)
EHI:RegisterCustomSpecialFunction(uno_8, function(trigger, ...)
    local bags = managers.ehi:CountLootbagsOnTheGround() - 10
    if bags == 12 then
        EHI:CheckCondition(trigger)
    end
end)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000,
        watchdogs_bonus_xp = 1500
    },
    no_total_xp = true
})