local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local van_delay = 47 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0), 31s before the timer gets activated; 10s before the timer is started; total 47s; Mayhem difficulty and above
local van_delay_ovk = 6 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0); OVERKILL difficulty and below
local heli_delay = 19
local anim_delay = 743/30 -- 743/30 is a animation duration; 3s is zone activation delay (never used when van is coming back)
local heli_delay_full = 13 + 19 -- 13 = Base Delay; 19 = anim delay
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local VanPos = 1 -- 1 - Left; 2 - Center
local element_sync_triggers =
{
    [100494] = { id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop }, hook_element = 100724, set_time_when_tracker_exists = true }
}
local preload =
{
    { id = "Van", icons = Icon.CarEscape, hide_on_delete = true },
    { id = "VanStayDelay", icons = Icon.CarWait, class = TT.Warning, hide_on_delete = true },
    { id = "HeliMeth", icons = { Icon.Heli, Icon.Methlab, Icon.Goto }, hide_on_delete = true },
    { id = "CookingDone", icons = { Icon.Methlab, Icon.Interact }, hide_on_delete = true },
    { id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, hide_on_delete = true }
}
local triggers = {
    [102318] = { id = "Van", run = { time = 60 + 60 + 30 + 15 + anim_delay } },
    [102319] = { id = "Van", run = { time = 60 + 60 + 60 + 30 + 15 + anim_delay } },
    [101001] = { special_function = SF.Trigger, data = { 1010011, 1010012 } },
    [1010011] = { special_function = SF.RemoveTracker, data = { "CookChance", "VanStayDelay", "HeliMeth" } },
    [1010012] = { special_function = SF.RemoveTrigger, data = { 102220, 102219, 102229, 102235, 102236, 102237, 102238, 102197 } },

    [102383] = { id = "CookDelay", run = { time = 2 + 5 } },
    [100721] = { id = "CookDelay", run = { time = 1 }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1007211 } },
    [1007211] = { chance = 7, id = "CookChance", icons = { Icon.Methlab }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },

    [100199] = { id = "CookingDone", run = { time = 5 + 1 } },

    [102167] = { id = "HeliMeth", run = { time = 60 + heli_delay } },
    [102168] = { id = "HeliMeth", run = { time = 90 + heli_delay } },

    [102220] = { id = "VanStayDelay", run = { time = 60 + van_delay_ovk } },
    [102219] = { id = "VanStayDelay", run = { time = 45 + van_delay } },
    [102229] = { id = "VanStayDelay", run = { time = 90 + van_delay_ovk } },
    [102235] = { id = "VanStayDelay", run = { time = 100 + van_delay_ovk } },
    [102236] = { id = "VanStayDelay", run = { time = 50 + van_delay } },
    [102237] = { id = "VanStayDelay", run = { time = 60 + van_delay_ovk } },
    [102238] = { id = "VanStayDelay", run = { time = 70 + van_delay_ovk } },

    [1] = { special_function = SF.RemoveTrigger, data = { 101972, 101973, 101974, 101975 } },
    [101972] = { run = { time = 60 + 60 + 60 + 30 + 15 + anim_delay }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [101973] = { run = { time = 60 + 60 + 30 + 15 + anim_delay }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [101974] = { run = { time = 60 + 30 + 15 + anim_delay }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [101975] = { run = { time = 30 + 15 + anim_delay }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },

    [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { Icon.Heli, "heavy", Icon.Goto }, class = TT.Warning },

    [101982] = { special_function = SF.Trigger, data = { 1019821, 1019822 } },
    [1019821] = { id = "Van", special_function = SF.SetTimeOrCreateTracker, run = { time = 589/30 } },
    [1019822] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101281 } },

    [101128] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101454 } },

    [100723] = { id = "CookChance", special_function = SF.IncreaseChanceFromElement }
}
if EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) then
    triggers[102197] = { id = "HeliMeth", run = { time = 180 + heli_delay_full } }
    if EHI:MissionTrackersAndWaypointEnabled() then
        triggers[101001].data[#triggers[101001].data + 1] = 1010013
        local function ResetWaypoint()
            managers.hud:RestoreWaypoint(VanPos == 1 and 101454 or 101449)
            VanPos = 1 -- Reset to default position
        end
        triggers[1010013] = { special_function = SF.CustomCode, f = ResetWaypoint }
        triggers[102320] = { special_function = SF.CustomCode, f = ResetWaypoint }
        triggers[101258] = { special_function = SF.CustomCode, f = ResetWaypoint }
        triggers[101982].data[#triggers[101982].data + 1] = 1019823
        triggers[1019823] = { special_function = SF.CustomCode, f = function()
            VanPos = 2
        end }
        local function DisableWaypoint()
            local id = VanPos == 1 and 101454 or 101449
            managers.hud:SoftRemoveWaypoint(id)
            EHI._cache.IgnoreWaypoints[id] = true
            EHI:DisableElementWaypoint(id)
        end
        triggers[100763] = { special_function = SF.CustomCode, f = DisableWaypoint }
        triggers[101453] = { special_function = SF.CustomCode, f = DisableWaypoint }
        local function ShowWaypoint(trigger)
            local t = trigger.run and trigger.run.time or trigger.time
            local pos = VanPos == 1 and Vector3(-1374, -2388, 1135) or Vector3(-1283, 1470, 1285)
            managers.ehi_waypoint:AddWaypoint(trigger.id, {
                time = t,
                icon = Icon.LootDrop,
                position = pos,
                class = EHI.Waypoints.Warning
            })
        end
        triggers[102219].waypoint_f = ShowWaypoint
        triggers[102236].waypoint_f = ShowWaypoint
    end
elseif EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
    triggers[102197] = { id = "HeliMeth", run = { time = 120 + heli_delay_full } }
end
if EHI:IsClient() then
    local SetTimeNoAnimOrCreateTrackerClient = EHI:GetFreeCustomSpecialFunctionID()
    triggers[100724] = { time = 20, random_time = 5, id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop }, special_function = SetTimeNoAnimOrCreateTrackerClient, delay_only = true }
    EHI:SetSyncTriggers(element_sync_triggers)
    EHI:RegisterCustomSpecialFunction(SetTimeNoAnimOrCreateTrackerClient, function(trigger, ...)
        local key = trigger.id
        local value = managers.ehi:ReturnValue(key, "GetTrackerType")
        if value ~= "accurate" then
            if managers.ehi:TrackerExists(key) then
                managers.ehi:SetTrackerTimeNoAnim(key, EHI:GetTime(trigger))
            else
                EHI:CheckCondition(trigger)
            end
        end
    end)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local achievements =
{
    halloween_1 =
    {
        elements =
        {
            [101088] = { status = "ready", class = TT.AchievementStatus },
            [101907] = { status = "defend", special_function = SF.SetAchievementStatus },
            [101917] = { special_function = SF.SetAchievementComplete },
            [101914] = { special_function = SF.SetAchievementFailed },
            [101001] = { special_function = SF.SetAchievementFailed } -- Methlab exploded
        }
    },
    voff_5 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101780] = { max = 25, class = TT.AchievementProgress },
            [101001] = { special_function = SF.SetAchievementFailed }, -- Methlab exploded
            [102611] = { special_function = SF.IncreaseProgress }
        }
    }
}

local other =
{
    [102383] = EHI:AddAssaultDelay({ time = 2 + 20 + 4 + 3 + 3 + 3 + 5 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    preload = preload
}, "Van", Icon.CarEscape)
if ovk_and_up then
    EHI:ShowAchievementLootCounter({
        achievement = "halloween_2",
        max = 7
    })
end
EHI:AddXPBreakdown({
    loot_all = 8000
})