local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local SF = EHI.SpecialFunctions
local triggers = {
    [102611] = { time = 1, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [102612] = { time = 3, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [102613] = { time = 5, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },

    [100750] = { time = 120 + 80, id = "Van", icons = Icon.CarEscape },
    [101568] = { time = 20, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101569] = { time = 40, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101572] = { time = 60, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101573] = { time = 80, id = "Van", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 10)
    end)
end

local achievements =
{
    uno_2 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100108] = { status = "secure", class = TT.AchievementStatus },
            [100022] = { status = "defend", special_function = SF.SetAchievementStatus }, -- Alarm has been raised, defend the hostages until the escape vehicle arrives
            [101492] = { status = "secure", special_function = SF.SetAchievementStatus }, -- Escape vehicle is here, secure the remaining bags
            [102206] = { special_function = SF.SetAchievementFailed },
            [102207] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [102622] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },
    [100107] = EHI:AddLootCounter(function()
        local SafeTriggers =
        {
            loot =
            {
                "spawn_loot_money"
            },
            no_loot =
            {
                "spawn_loot_value_c",
                "spawn_loot_value_d",
                "spawn_loot_value_e",
                "spawn_loot_crap_c"
            }
        }
        EHI:ShowLootCounterNoCheck({
            max = 18,
            max_random = 2,
            sequence_triggers =
            {
                -- units/payday2/equipment/gen_interactable_sec_safe_05x05_titan/gen_interactable_sec_safe_05x05_titan
                [101239] = SafeTriggers,
                [101541] = SafeTriggers,
                [101543] = SafeTriggers,
                [101544] = SafeTriggers
            }
        })
    end)
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 2000
    },
    loot =
    {
        money = 1000,
        diamonds = 1000
    },
    no_total_xp = true
})