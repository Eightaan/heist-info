local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local pc_hack = { time = 20, id = "PCHack", icons = { Icon.PCHack } }
local triggers = {
    [105842] = { time = 16.7 * 18, id = "Thermite", icons = { Icon.Fire } },

    [105197] = { time = 45, id = "PickUpAPhone", icons = { Icon.Phone, Icon.Interact }, class = TT.Warning },
    [105219] = { id = "PickUpAPhone", special_function = SF.RemoveTracker },

    [103050] = { time = 60, id = "PickUpManagersPhone", icons = { Icon.Phone, Icon.Interact }, class = TT.Warning },
    [105248] = { id = "PickUpManagersPhone", special_function = SF.RemoveTracker },

    [101377] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
    [104532] = pc_hack,
    [103179] = pc_hack,
    [103259] = pc_hack,
    [103590] = pc_hack,
    [103620] = pc_hack,
    [103671] = pc_hack,
    [103734] = pc_hack,
    [103776] = pc_hack,
    [103815] = pc_hack,
    [103903] = pc_hack,
    [103920] = pc_hack,
    [103936] = pc_hack,
    [103956] = pc_hack,
    [103974] = pc_hack,
    [103988] = pc_hack,
    [104014] = pc_hack,
    [104029] = pc_hack,
    [104051] = pc_hack,

    -- Heli escape
    [104126] = { time = 23 + 1, id = "HeliEscape", icons = Icon.HeliEscape },

    [104091] = { time = 200/30, id = "CraneLiftUp", icons = { "piggy" } },
    [104261] = { time = 1000/30, id = "CraneMoveLeft", icons = { "piggy" } },
    [104069] = { time = 1000/30, id = "CraneMoveRight", icons = { "piggy" } },

    [105623] = { time = 8, id = "Bus", icons = { Icon.Wait } }
}
if EHI:IsClient() then
    triggers[101605] = { time = 16.7 * 17, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist }
    local doesnotexists = {
        [101817] = true,
        [101819] = true,
        [101825] = true,
        [101826] = true,
        [101828] = true,
        [101829] = true
    }
    local multiplier = 16
    for i = 101812, 101833, 1 do
        if not doesnotexists[i] then
            triggers[i] = { time = 16.7 * multiplier, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist }
            multiplier = multiplier - 1
        end
    end
end

local bigbank_4 = { special_function = SF.Trigger, data = { 1, 2 } }
local achievements =
{
    bigbank_4 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard),
        elements =
        {
            [1] = { time = 720, id = "bigbank_4", class = TT.Achievement },
            [2] = { special_function = SF.RemoveTrigger, data = { 100107, 106140, 106150 } },
            [100107] = bigbank_4,
            [106140] = bigbank_4,
            [106150] = bigbank_4,
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("bigbank_4", 720)
        end
    },
    cac_22 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [106250] = { special_function = SF.SetAchievementFailed },
            [106247] = { special_function = SF.SetAchievementComplete }
        },
        alarm_callback = function(dropin)
            if dropin or not managers.preplanning:IsAssetBought(106594) then -- C4 Escape
                return
            end
            managers.ehi:AddAchievementStatusTracker("cac_22")
        end
    }
}

local other =
{
    -- "Silent Alarm 30s delay" does not delay first assault
    -- Reported in:
    -- https://steamcommunity.com/app/218620/discussions/14/3487502671137130788/
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30, trigger_times = 1 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowAchievementLootCounter({
    achievement = "bigbank_3",
    max = 16,
    remove_after_reaching_target = false
})

local tbl =
{
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    [101457] = { icons = { Icon.Wait } },
    [104671] = { icons = { Icon.Wait } },

    --units/payday2/equipment/gen_interactable_lance_huge/gen_interactable_lance_huge
    [105318] = { remove_vanilla_waypoint = true, waypoint_id = 103700 },
    [105319] = { remove_vanilla_waypoint = true, waypoint_id = 103702 },
    [105320] = { remove_vanilla_waypoint = true, waypoint_id = 103704 },
    [105321] = { remove_vanilla_waypoint = true, waypoint_id = 103705 },

    --units/payday2/props/gen_prop_construction_crane/gen_prop_construction_crane_arm
    [105111] = { f = function(id, unit_data, unit)
        if not EHI:GetOption("show_waypoints") then
            return
        end
        local t = { unit = unit }
        EHI:AddWaypointToTrigger(104091, t)
        EHI:AddWaypointToTrigger(104261, t)
        EHI:AddWaypointToTrigger(104069, t)
        unit:unit_data():add_destroy_listener("EHIDestroy", function(...)
            managers.ehi_waypoint:RemoveWaypoint("CraneLiftUp")
            managers.ehi_waypoint:RemoveWaypoint("CraneMoveLeft")
            managers.ehi_waypoint:RemoveWaypoint("CraneMoveRight")
        end)
    end }
}
EHI:UpdateUnits(tbl)

local MissionDoorPositions =
{
    -- Server Room
    [1] = Vector3(733.114, 1096.92, -907.557),
    [2] = Vector3(1419.89, -1897.92, -907.557),
    [3] = Vector3(402.08, -1266.89, -507.56),

    -- Roof
    [4] = Vector3(503.08, 1067.11, 327.432),
    [5] = Vector3(503.08, -1232.89, 327.432),
    [6] = Vector3(3446.92, -1167.11, 327.432),
    [7] = Vector3(3466.11, 1296.92, 327.432)
}
local MissionDoorIndex =
{
    [1] = { w_id = 103457, restore = true, unit_id = 104582 },
    [2] = { w_id = 103461, restore = true, unit_id = 104584 },
    [3] = { w_id = 103465, restore = true, unit_id = 104585 },
    [4] = { w_id = 101306, restore = true, unit_id = 100311 },
    [5] = { w_id = 106362, restore = true, unit_id = 103322 },
    [6] = { w_id = 106372, restore = true, unit_id = 105317 },
    [7] = { w_id = 106382, restore = true, unit_id = 106336 },
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)
EHI:AddXPBreakdown({
    objective =
    {
        correct_pc_hack = 8000,
        timelock_done = 4000,
        escape_is_enabled = 10000,
        escape = 8000
    },
    loot_all = 1000
})