local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local escape_delay = 18
local CarLootDrop = { Icon.Car, Icon.LootDrop }
local triggers = {
    [102873] = { time = 36 + 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = CarLootDrop },

    [101256] = { time = 3 + 28 + 10 + 135/30 + 0.5 + 210/30, id = "CarEscape", icons = Icon.CarEscapeNoLoot },
    [101088] = { id = "CarEscape", special_function = SF.RemoveTracker },

    [101218] = { time = 60 + 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [101219] = { time = 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [101221] = { time = 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot }
}

-- Not possible to include Van location waypoint as this is selected randomly
-- See ´LootVehicleArrived´ MissionScriptElement 100658

if EHI:IsClient() then
    triggers[101307] = { time = 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101308] = { time = 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101309] = { time = 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100944] = { time = 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101008] = { time = 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101072] = { time = 30 + 38 + 7, id = "VanPickupLoot", icons = CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101073] = { time = 38 + 7, id = "VanPickupLoot", icons = CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100658] = { time = 7, id = "VanPickupLoot", icons = CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }

    triggers[103300] = { time = 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[103301] = { time = 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[103302] = { time = 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101223] = { time = escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
end

local achievements =
{
    hot_wheels =
    {
        elements =
        {
            [101137] = { status = "finish", class = TT.AchievementStatus },
            [102487] = { special_function = SF.SetAchievementFailed },
            [102470] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [101244] = EHI:AddAssaultDelay({ time = 60 + 30 }),
    [101245] = EHI:AddAssaultDelay({ time = 45 + 30 }),
    [101249] = EHI:AddAssaultDelay({ time = 50 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
local max = 8
if EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard) then
    max = 12
end
EHI:ShowLootCounter({ max = max })
EHI:AddXPBreakdown({
    objective =
    {
        heli_escape = 2000,
        all_bags_secured = 2000,
        escape = 12000
    },
    no_total_xp = true
})