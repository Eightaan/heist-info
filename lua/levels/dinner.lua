local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local c4 = { time = 5, id = "C4", icons = { Icon.C4 } }
local triggers = {
    [100915] = { time = 4640/30, id = "CraneMoveGas", icons = { Icon.Winch, Icon.Fire, Icon.Goto }, waypoint = { position_by_element = 100836 } },
    [100967] = { time = 3660/30, id = "CraneMoveGold", icons = { Icon.Escape } },
    -- C4 (Doors)
    [100985] = c4,
    -- C4 (GenSec Truck)
    [100830] = c4,
    [100961] = c4
}

local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local achievements =
{
    farm_2 =
    {
        elements =
        {
            [100484] = { time = 300, class = TT.AchievementUnlock },
            [100319] = { special_function = SF.SetAchievementFailed }
        }
    },
    farm_3 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101553] = { class = TT.AchievementStatus },
            [103394] = { special_function = SF.SetAchievementFailed },
            [102880] = { special_function = SF.SetAchievementComplete }
        }
    },
    farm_4 =
    {
        elements =
        {
            [100485] = { time = 30, class = TT.Achievement },
            [102841] = { special_function = SF.SetAchievementComplete }
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})

local pig = 0
if ovk_and_up then
    pig = 1
    EHI:ShowAchievementLootCounter({
        achievement = "farm_6",
        max = 1,
        remove_after_reaching_target = false,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = "din_pig"
        }
    })
    if EHI:CanShowAchievement("farm_1") then
        local farm_1 = EHI:GetAchievementIcon("farm_1")
        EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
            if mode == "phalanx" then
                managers.ehi:AddTracker({
                    id = "farm_1",
                    status = "finish",
                    icons = farm_1,
                    class = EHI.Trackers.AchievementStatus,
                })
            else
                managers.ehi:SetAchievementFailed("farm_1")
            end
        end)
        EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
            if success then
                managers.ehi:SetAchievementComplete("farm_1")
            end
        end)
    end
end

EHI:ShowLootCounter({ max = 10, additional_loot = pig })

local tbl =
{
    -- Drills
    [100035] = { remove_vanilla_waypoint = true, waypoint_id = 103175 },
    [100949] = { remove_vanilla_waypoint = true, waypoint_id = 103174 }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        slaughterhouse_entered = 4000,
        vault_drill_done = 6000,
        slaughterhouse_tires_burn = 6000,
        slaughterhouse_trap_lifted = 6000,
        slaughterhouse_gold_lifted = 6000,
        escape = 6000
    },
    loot =
    {
        gold = ovk_and_up and 800 or 1000
    }
})