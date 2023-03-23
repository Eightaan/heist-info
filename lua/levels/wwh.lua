local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100322] = { time = 120, id = "Fuel", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [100323] = { id = "Fuel", special_function = SF.PauseTracker }
}

if EHI:IsClient() then
    triggers[100047] = { time = 60, id = "Fuel", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100049] = { time = 30, id = "Fuel", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.AddTrackerIfDoesNotExist }
end

local DisableWaypoints = {}

for i = 6850, 7525, 225 do
    DisableWaypoints[EHI:GetInstanceElementID(100021, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100022, i)] = true -- Fix
end

local achievements =
{
    wwh_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100012] = { status = "defend", class = TT.AchievementStatus },
            [101250] = { special_function = SF.SetAchievementFailed },
            [100082] = { special_function = SF.SetAchievementComplete },
        }
    },
    wwh_10 =
    {
        elements =
        {
            [100946] = { max = 4, class = TT.AchievementProgress },
            [101226] = { special_function = SF.IncreaseProgress }
        }
    }
}

local other =
{
    [100946] = EHI:AddAssaultDelay({ time = 10 + 5 + 3 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowLootCounter({ max = 8 })
EHI._cache.diff = 1
EHI:AddXPBreakdown({
    objective =
    {
        alaskan_deal_crew_saved = 2000,
        alaskan_deal_captain_reached_boat = 5000,
        alaskan_deal_boat_fueled = 6000,
        escape = 1000
    },
    loot =
    {
        money = 400,
        weapon = 600
    },
    no_total_xp = true
    --[[total_xp_override =
    {
        loot =
        {
            money = { times = 4 },
            weapon = { times = 4 }
        }
    }]]
})