local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local SF = EHI.SpecialFunctions
local truck_delay = 524/30
local boat_delay = 450/30
local triggers = {
    [104082] = { time = 30 + 24 + 3, id = "HeliThermalDrill", icons = Icon.HeliDropDrill },

    -- Boat
    [103273] = { time = boat_delay, id = "BoatSecureTurret", icons = { Icon.Boat, Icon.LootDrop } },
    [103041] = { time = 30 + boat_delay, id = "BoatSecureAmmo", icons = { Icon.Boat, Icon.LootDrop } },

    -- Truck
    [105055] = { time = 15 + truck_delay, id = "TruckSecureTurret", icons = { Icon.Car, Icon.LootDrop } },
    [105183] = { time = 30 + 524/30, id = "TruckSecureAmmo", icons = { Icon.Car, Icon.LootDrop } }
}
local achievements =
{
    armored_6 =
    {
        elements =
        {
            -- Achievement bugged, can be earned in stealth
            -- Reported in: https://steamcommunity.com/app/218620/discussions/14/3048357185566603324/
            [104716] = { id = "armored_6", class = TT.AchievementStatus },
            [103311] = { id = "armored_6", special_function = SF.SetAchievementFailed }
        },
        load_sync = function(self)
            if EHI.ConditionFunctions.IsStealth() then
                self:AddAchievementStatusTracker("armored_6")
            end
        end
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowAchievementLootCounter({
    achievement = "armored_1",
    max = 20,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = "ammo"
    }
})
EHI:ShowLootCounter({ max = 23 })

local tbl = {}
for i = 0, 500, 100 do
    --levels/instances/unique/train_cam_computer
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    tbl[EHI:GetInstanceUnitID(100022, i)] = { icons = { Icon.Vault }, remove_on_alarm = true }
end
EHI:UpdateUnits(tbl)

local MissionDoorPositions =
{
    -- Vaults
    [1] = Vector3(-150, -1100, 685),
    [2] = Vector3(-1750, -1200, 685),
    [3] = Vector3(750, -1200, 685),
    [4] = Vector3(2350, -1100, 685),
    [5] = Vector3(-2650, -1100, 685),
    [6] = Vector3(3250, -1200, 685)
}
local MissionDoorIndex =
{
    [1] = { w_id = 100835 },
    [2] = { w_id = 100253 },
    [3] = { w_id = 100838 },
    [4] = { w_id = 100840 },
    [5] = { w_id = 102288 },
    [6] = { w_id = 102593 }
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)
EHI:AddXPBreakdown({
    objective =
    {
        vault_open = { amount = 3000, times = 3 },
        turret_secured = 7000,
        escape = 4000
    },
    loot =
    {
        ammo = { amount = 800, times = 20 }
    }
})