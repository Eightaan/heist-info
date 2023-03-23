local EHI = EHI
local Icon = EHI.Icons

for _, unit_id in ipairs({ 100067, 100093, 100094 }) do
    for _, index in ipairs({ 4500, 5400, 5800, 6000, 6200, 6600 }) do
        local fixed_unit_id = EHI:GetInstanceUnitID(unit_id, index)
        managers.mission:add_runned_unit_sequence_trigger(fixed_unit_id, "interact", function(unit)
            managers.ehi:AddTracker({
                id = tostring(fixed_unit_id),
                time = 30,
                icons = { Icon.Glasscutter }
            })
        end)
    end
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100241] = { time = 19, id = "HeliEscape", icons = Icon.HeliEscape },
    [EHI:GetInstanceElementID(100069, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100090, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100116, 4900)] = { max = 3, id = "C4Progress", icons = { Icon.C4 }, class = TT.Progress },
    [EHI:GetInstanceElementID(100177, 4900)] = { id = "C4Progress", special_function = SF.IncreaseProgress },
    [EHI:GetInstanceElementID(100166, 4900)] = { time = 5, id = "WaitTime", icons = { Icon.Wait } },
    [EHI:GetInstanceElementID(100128, 4900)] = { time = 10, id = "PressSequence", icons = { Icon.Interact }, class = TT.Warning }
}

local achievements =
{
    live_2 =
    {
        elements =
        {
            [100693] = { class = TT.AchievementStatus },
            [102704] = { special_function = SF.SetAchievementFailed },
            [100246] = { special_function = SF.SetAchievementComplete }
        }
    },
    live_3 =
    {
        elements =
        {
            [100304] = { time = 5, class = TT.AchievementUnlock }
        }
    },
    live_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102785] = { class = TT.AchievementStatus },
            [100249] = { special_function = SF.SetAchievementComplete },
            [102694] = { special_function = SF.SetAchievementFailed },
        }
    },
    live_5 =
    {
        elements =
        {
            [EHI:GetInstanceElementID(100116, 4900)] = { class = TT.AchievementStatus },
            [102702] = { special_function = SF.SetAchievementFailed },
            [100265] = { special_function = SF.SetAchievementComplete }
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})

local DisableWaypoints =
{
    [EHI:GetInstanceElementID(100050, 4700)] = true -- PC
}
EHI:DisableWaypoints(DisableWaypoints)

local max = 6
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    max = 12
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    max = 18
end
EHI:ShowLootCounter({ max = max })
EHI:AddXPBreakdown({
    objective =
    {
        alesso_find_c4_stealth = 1000,
        pc_hack = { amount = 10000, loud = true },
        alesso_find_c4_loud = 2000,
        c4_set_up = 2000,
        alesso_pyro_set = { amount = 3000, times = 3 },
        alesso_bag_secured_stealth = 1200,
        alesso_bag_secured_loud = 1500
    },
    no_total_xp = true
})