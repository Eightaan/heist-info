local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local goat_pick_up = { Icon.Heli, Icon.Interact }
local function f_PilotComingInAgain(trigger, ...)
    managers.ehi:RemoveTracker("PilotComingIn")
    if managers.ehi:TrackerExists(trigger.id) then
        managers.ehi:SetTrackerTime(trigger.id, trigger.time)
    else
        EHI:CheckCondition(trigger)
    end
end
local PilotComingInAgain = EHI:GetFreeCustomSpecialFunctionID()
local PilotComingInAgain2 = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [EHI:GetInstanceElementID(100022, 2850)] = { time = 180 + 6.9, id = "BagsDropin", icons = Icon.HeliDropBag },
    [EHI:GetInstanceElementID(100022, 3150)] = { time = 180 + 6.9, id = "BagsDropin", icons = Icon.HeliDropBag },
    [EHI:GetInstanceElementID(100022, 3450)] = { time = 180 + 6.9, id = "BagsDropin", icons = Icon.HeliDropBag },
    [100581] = { time = 9 + 30 + 6.9, id = "BagsDropinAgain", icons = Icon.HeliDropBag, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100072, 3750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100072, 4250)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100072, 4750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100099, 3750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain },
    [EHI:GetInstanceElementID(100099, 4250)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain },
    [EHI:GetInstanceElementID(100099, 4750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain },

    [101720] = { time = 80, id = "Bridge", icons = { Icon.Wait }, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable },
    [101718] = { id = "Bridge", special_function = SF.PauseTracker },

    [EHI:GetInstanceElementID(100011, 3750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain2 },
    [EHI:GetInstanceElementID(100011, 4250)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain2 },
    [EHI:GetInstanceElementID(100011, 4750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain2 }
}

local IncreaseEnabled = false
local achievements =
{
    peta_3 =
    {
        elements =
        {
            -- Formerly 5 minutes
            [101540] = { time = 240, class = TT.Achievement },
            [101533] = { special_function = SF.SetAchievementComplete }
        }
    },
    peta_5 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100002] = { max = (EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) and 14 or 12), class = TT.AchievementProgress, remove_after_reaching_target = false },
            [102095] = { special_function = SF.CustomCode, f = function()
                IncreaseEnabled = true
            end },
            [102098] = { special_function = SF.CustomCode, f = function()
                IncreaseEnabled = false
            end },
            [100716] = { special_function = SF.CustomCode, f = function()
                if IncreaseEnabled then
                    managers.ehi:IncreaseTrackerProgress("peta_5")
                end
            end },
            [100580] = { special_function = SF.CustomCodeDelayed, t = 2, f = function()
                managers.ehi:CallFunction("peta_5", "Finalize")
            end}
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 100 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:RegisterCustomSpecialFunction(PilotComingInAgain, function(trigger, element, enabled)
    if enabled then
        f_PilotComingInAgain(trigger)
    end
end)
EHI:RegisterCustomSpecialFunction(PilotComingInAgain2, f_PilotComingInAgain)

local DisableWaypoints =
{
    -- Drill waypoint on mission door
    [101738] = true
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:AddXPBreakdown({
    objective =
    {
        gs2_plane_started = { amount = 7000, times = 1 },
        cage_assembled = 500,
        gs2_cage_grabbed = 500,
        gs2_arrived_on_bridge = 4500,
        gs2_drilled_door = 4500,
        gs2_bridge_rotated = 2000,
        gs2_peta_5 = 50000,
        escape = 3000
    },
    loot_all = 500
})