local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101335] = { time = 7, id = "C4BasementWall", icons = { Icon.C4 } },
    [101968] = { time = 10, id = "LureDelay", icons = { Icon.Wait } }
}
local safe_reset_time = EHI:GetKeypadResetTimer({ normal = 10 })
for _, index in ipairs({ 13350, 14450, 14950, 15450, 15950, 16450, 16950, 17450 }) do
    local unit_id = EHI:GetInstanceElementID(100279, index)
    triggers[EHI:GetInstanceElementID(100210, index)] = { time = 5 + safe_reset_time, id = "KeypadReset", icons = { Icon.Wait }, waypoint = { position_by_unit = unit_id }  }
    triggers[EHI:GetInstanceElementID(100176, index)] = { time = 30, id = "KeypadRebootECM", icons = { Icon.Loop }, special_function = SF.SetTimeOrCreateTracker, waypoint = { position_by_unit = unit_id } }
end

local achievements =
{
    tag_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100107] = { class = TT.AchievementStatus },
            [100609] = { special_function = SF.SetAchievementComplete },
            [100617] = { special_function = SF.SetAchievementFailed }
        }
    },
    tag_10 =
    {
        elements =
        {
            [100107] = { status = "mark", class = TT.AchievementStatus },
        }
    }
}
for _, index in ipairs({ 4550, 5450 }) do
    achievements.tag_10.elements[EHI:GetInstanceElementID(100319, index)] = { special_function = SF.SetAchievementFailed }
    achievements.tag_10.elements[EHI:GetInstanceElementID(100321, index)] = { status = "ok", special_function = SF.SetAchievementStatus }
    achievements.tag_10.elements[EHI:GetInstanceElementID(100282, index)] = { special_function = SF.SetAchievementComplete }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:AddXPBreakdown({
    objective =
    {
        correct_pc_hack = { amount = 2000, times = 1 },
        breakin_feds_found_garret_office = 2000,
        breakin_feds_lure = 4000,
        breakin_feds_entered_office = { amount = 1000, times = 1 },
        breakin_feds_safe_found = 1000
    },
    loot_all = 1000
})