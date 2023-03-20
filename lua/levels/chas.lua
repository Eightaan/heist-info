local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers = {
    [100209] = { time = 5, id = "LoudEscape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, client_on_executed = true, hook_element = 100602, remove_trigger_when_executed = true },
    [100883] = { time = 12.5, id = "HeliArrivesWithDrill", icons = Icon.HeliDropDrill, hook_element = 102453, remove_trigger_when_executed = true }
}
local triggers = {
    [102863] = { time = 41.5, id = "TramArrivesWithDrill", icons = { Icon.Train, Icon.Drill, Icon.Goto } },

    [101660] = { time = 120, id = "Gas", icons = { Icon.Teargas } },
    [EHI:GetInstanceElementID(100017, 11325)] = { id = "Gas", special_function = SF.RemoveTracker },
}
if EHI:IsClient() then
    triggers[100602] = { time = 90 + 5, random_time = 20, id = "LoudEscape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[102453] = { time = 60 + 12.5, random_time = 20, id = "HeliArrivesWithDrill", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end
local DisableWaypoints =
{
    -- chas_store_computer
    [EHI:GetInstanceElementID(100018, 10675)] = true, -- Defend
    -- Fix is in CoreWorldInstanceManager.lua
    -- chas_vault_door
    [EHI:GetInstanceElementID(100029, 5950)] = true, -- Defend
    [EHI:GetInstanceElementID(100030, 5950)] = true, -- Fix
    -- chas_auction_room_door_hack
    [EHI:GetInstanceElementID(100031, 5550)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 5550)] = true, -- Fix
    [EHI:GetInstanceElementID(100031, 11900)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 11900)] = true -- Fix
}

local achievements =
{
    chas_9 =
    {
        elements =
        {
            [100781] = { status = "defend", class = TT.AchievementStatus },
            [100907] = { special_function = SF.SetAchievementFailed },
            [100906] = { special_function = SF.SetAchievementComplete }
        }
    },
    chas_10 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [1] = { max = 15, class = TT.AchievementProgress, remove_after_reaching_target = false },
            [2] = { special_function = SF.CustomCode, f = function()
                EHI:AddAchievementToCounter({
                    achievement = "chas_10"
                })
            end },
            [100107] = { special_function = SF.Trigger, data = { 1, 2 } }
        },
        load_sync = function(self)
            if EHI.ConditionFunctions.IsStealth() then
                EHI:ShowAchievementLootCounter({
                    achievement = "chas_10",
                    max = 15,
                    remove_after_reaching_target = false
                })
                self:SetTrackerProgress("chas_10", managers.loot:GetSecuredBagsAmount())
            end
        end,
        failed_on_alarm = true
    },
    chas_11 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { time = 360, class = TT.Achievement }
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("chas_11", 360)
        end
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 60 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowLootCounter({ max = 15 })

local tbl =
{
    --levels/instances/unique/chas/chas_store_computer
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceUnitID(100037, 10675)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100017, 10675) },

    --levels/instances/unique/chas/chas_vault_door
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100065, 5950)] = { icons = { Icon.Vault }, remove_on_pause = true }
}
EHI:UpdateUnits(tbl)