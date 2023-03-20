local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local WinchCar = { { icon = Icon.Car, color = Color("1E90FF") } }
local ElementTimer = 102059
local ElementTimerPickup = 102075
local WeaponsPickUp = { Icon.Heli, Icon.Interact }
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
if OVKorAbove then
    ElementTimer = 102063
    ElementTimerPickup = 102076
end
local SF_FultonCatchSuccess = EHI:GetFreeCustomSpecialFunctionID()
local FultonCatchAgain = { id = "FultonCatch", icons = WeaponsPickUp, special_function = SF.AddTrackerIfDoesNotExist }
local FultonCatchSuccess = { time = 6.8, id = "FultonCatchSuccess", icons = WeaponsPickUp, special_function = SF_FultonCatchSuccess }
local FultonCatchIncreaseChance = { id = "FultonCatchChance", special_function = SF.IncreaseChanceFromElement }
local FultonRemoveCatch = { id = "FultonCatch", special_function = SF.RemoveTracker }

local sync_triggers =
{
    [EHI:GetInstanceElementID(100070, 14950)] = FultonCatchAgain,
    [EHI:GetInstanceElementID(100070, 25500)] = FultonCatchAgain,
    [EHI:GetInstanceElementID(100070, 25650)] = FultonCatchAgain,
}
local triggers = {
    [EHI:GetInstanceElementID(100083, 12500)] = { time = 230/30, id = "CarPush1", icons = WinchCar },
    [EHI:GetInstanceElementID(100084, 12500)] = { time = 230/30 + 1, id = "CarPush2", icons = WinchCar },
    [EHI:GetInstanceElementID(100087, 12500)] = { time = 250/30, id = "CarWinchUsed", icons = { { icon = Icon.Car, color = Color("1E90FF") }, Icon.Winch } },

    -- Thermite
    [EHI:GetInstanceElementID(100012, 2850)] = { time = 0.5 + 0.5 + 0.5 + 0.5 + 1, id = "ThermiteOpenGate", icons = { Icon.Fire } },
    [EHI:GetInstanceElementID(100012, 2950)] = { time = 0.5 + 0.5 + 0.5 + 0.5 + 1, id = "ThermiteOpenGate", icons = { Icon.Fire } },

    -- C4
    [EHI:GetInstanceElementID(100044, 2850)] = { time = 5, icon = "C4OpenGate", icons = { Icon.C4 } },
    [EHI:GetInstanceElementID(100044, 2950)] = { time = 5, icon = "C4OpenGate", icons = { Icon.C4 } },

    -- Fulton (Preplanning asset)
    [102053] = { additional_time = 7, id = "FultonDropCage", icons = Icon.HeliDropBag, special_function = SF.GetElementTimerAccurate, element = ElementTimer },
    [EHI:GetInstanceElementID(100053, 14950)] = FultonCatchSuccess,
    [EHI:GetInstanceElementID(100053, 25500)] = FultonCatchSuccess,
    [EHI:GetInstanceElementID(100053, 25650)] = FultonCatchSuccess,
    [102070] = { special_function = SF.Trigger, data = { 1020701, 1020702 } },
    [1020701] = { chance = 34, id = "FultonCatchChance", icons = { Icon.Heli }, class = TT.Chance },
    [1020702] = { additional_time = 6.8, id = "FultonCatch", icons = WeaponsPickUp, special_function = SF.GetElementTimerAccurate, element = ElementTimerPickup },
    [103988] = { id = "FultonCatchChance", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100055, 14950)] = FultonCatchIncreaseChance,
    [EHI:GetInstanceElementID(100055, 25500)] = FultonCatchIncreaseChance,
    [EHI:GetInstanceElementID(100055, 25650)] = FultonCatchIncreaseChance,
    [EHI:GetInstanceElementID(100056, 14950)] = FultonRemoveCatch,
    [EHI:GetInstanceElementID(100056, 25500)] = FultonRemoveCatch,
    [EHI:GetInstanceElementID(100056, 25650)] = FultonRemoveCatch
}

if EHI:IsClient() then
    triggers[102053].time = (ElementTimer == 102063 and 60 or 30) + triggers[102053].additional_time
    triggers[102053].random_time = 5
    triggers[102053].delay_only = true
    EHI:AddSyncTrigger(102053, triggers[102053])
    triggers[102070].time = (ElementTimer == 102076 and 60 or 30) + triggers[102070].additional_time
    triggers[102070].random_time = 5
    triggers[102070].delay_only = true
    EHI:AddSyncTrigger(102070, triggers[102070])
    local FultonCatchAgainClient = { time = 30, random_time = 30, id = "FultonCatch", icons = FultonCatchAgain, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100070, 14950)] = FultonCatchAgainClient
    triggers[EHI:GetInstanceElementID(100070, 25500)] = FultonCatchAgainClient
    triggers[EHI:GetInstanceElementID(100070, 25650)] = FultonCatchAgainClient
    EHI:SetSyncTriggers(sync_triggers)
else
    EHI:AddHostTriggers(sync_triggers, nil, nil, "base")
end

EHI:ParseTriggers({ mission = triggers })
local ranc_10 = { special_function = SF.IncreaseProgress }
local ranc_10_triggers =
{
    [EHI:GetInstanceElementID(100015, 28400)] = ranc_10
}
for i = 28600, 29300, 50 do
    ranc_10_triggers[EHI:GetInstanceElementID(100015, i)] = ranc_10
end
EHI:ShowAchievementLootCounter({
    achievement = "ranc_10",
    max = 5,
    triggers = ranc_10_triggers,
    load_sync = function(self)
        self:SetTrackerProgress("ranc_10", 5 - self:CountInteractionAvailable("ranc_press_pickup_horseshoe"))
    end
})
if OVKorAbove then
    EHI:ShowAchievementKillCounter("ranc_9", "ranc_9_stat", "show_achievements_vehicle") -- "Caddyshacked" achievement
    EHI:ShowAchievementKillCounter("ranc_11", "ranc_11_stat", "show_achievements_weapon") -- "Marshal Law" achievement
end
EHI:RegisterCustomSpecialFunction(SF_FultonCatchSuccess, function(trigger, ...)
    if managers.ehi:TrackerDoesNotExist("FultonCatch") then
        EHI:CheckCondition(trigger)
    end
end)