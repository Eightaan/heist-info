EHIorange5Tracker = class(EHIAchievementProgressTracker)
function EHIorange5Tracker:Finalize()
    if self._progress < self._max then
        self:SetFailed()
    end
end

local EHI = EHI
EHI.AchievementTrackers.EHIorange5Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local mayhem_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem)
local triggers = {
    [101725] = { time = 25 + 0.25 + 2 + 2.35, id = "C4", icons = Icon.HeliDropC4 },

    [100866] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } }
}
for _, index in ipairs({ 2300, 5400, 10700 }) do
    local waypoint_id = EHI:GetInstanceElementID(100021, index)
    triggers[EHI:GetInstanceElementID(100004, index)] = { special_function = SF.ShowWaypoint, data = { icon = Icon.C4, position_by_element = waypoint_id } }
end

local DisableWaypoints = {}
for _, index in ipairs({ 900, 1200, 1500, 4800, 13200 }) do
    DisableWaypoints[EHI:GetInstanceElementID(100093, index)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100212, index)] = true -- Fix
end
local achievements =
{
    orange_4 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [EHI:GetInstanceElementID(100459, 21700)] = { time = 284, class = TT.Achievement },
            [EHI:GetInstanceElementID(100461, 21700)] = { special_function = SF.SetAchievementComplete },
        }
    },
    orange_5 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [100279] = { max = 15, class = "EHIorange5Tracker", status_is_overridable = true, remove_after_reaching_target = false },
            [EHI:GetInstanceElementID(100471, 21700)] = { special_function = SF.SetAchievementFailed },
            [EHI:GetInstanceElementID(100474, 21700)] = { special_function = SF.IncreaseProgress },
            [EHI:GetInstanceElementID(100005, 12200)] = { special_function = SF.FinalizeAchievement }
        }
    }
}
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:DisableWaypoints(DisableWaypoints)
local LotteryWheel = { icons = { Icon.Wait }, icon_on_pause = { Icon.Loop } }

local tbl =
{
    --units/pd2_dlc_chill/props/chl_prop_timer_large/chl_prop_timer_large
    [400003] = { ignore = true },

    --levels/instances/unique/help/door_switch
    --units/pd2_dlc_help/props/hlp_interactable_controlswitch/hlp_interactable_controlswitch
    [EHI:GetInstanceUnitID(100072, 12400)] = { icons = { Icon.Wait }, warning = true },

    --levels/instances/unique/help/lottery_wheel (6 + 8)
    --units/pd2_dlc_help/props/hlp_interactable_wheel_timer/hlp_interactable_wheel_timer
    [EHI:GetInstanceUnitID(100033, 4800)] = LotteryWheel,
    [EHI:GetInstanceUnitID(100033, 13200)] = LotteryWheel
}
for i = 900, 1500, 300 do
    --levels/instances/unique/help/lottery_wheel (1, 4 + 5)
    --units/pd2_dlc_help/props/hlp_interactable_wheel_timer/hlp_interactable_wheel_timer
    tbl[EHI:GetInstanceUnitID(100033, i)] = LotteryWheel
end
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        prison_entered = 6000,
        escape = 8000
    },
    loot_all = 850
})