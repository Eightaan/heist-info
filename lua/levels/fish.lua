local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local achievements = {
    -- "fish_4" achievement is not in the Mission Script
    fish_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100244] = { time = 360, id = "fish_4", class = TT.Achievement },
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("fish_4", 360)
        end,
        mission_end_callback = true
    },
    fish_5 =
    {
        elements =
        {
            [100244] = { class = TT.AchievementStatus },
            [100395] = { special_function = SF.SetAchievementFailed },
            [100842] = { special_function = SF.SetAchievementComplete }
        }
    },
    fish_6 =
    {
        elements =
        {
            -- 100244 is ´Players_spawned´
            [100244] = { special_function = SF.Trigger, data = { 1, 2 } },
            [1] = { id = "fish_6", class = TT.AchievementProgress, remove_after_reaching_target = false }, -- Maximum is set in the next trigger; difficulty dependant
            [2] = { special_function = SF.CustomCode, f = function()
                managers.ehi:SetTrackerProgressMax("fish_6", managers.enemy:GetNumberOfEnemies())
                CopDamage.register_listener("EHI_fish_6_listener", { "on_damage" }, function(damage_info)
                    if damage_info.result.type == "death" then
                        managers.ehi:IncreaseTrackerProgress("fish_6")
                    end
                end)
            end},
        }
    }
}

EHI:ParseTriggers({
    achievement = achievements
})
EHI:ShowLootCounter({
    max = 8, -- Mission bags
    additional_loot = 7 -- Artifacts
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 4000
    },
    loot =
    {
        money = 1000,
        mus_artifact = 500
    },
    no_total_xp = true
})