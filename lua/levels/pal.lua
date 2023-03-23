local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local HeliLootDropWait = { Icon.Heli, Icon.LootDrop, Icon.Wait }
local element_sync_triggers =
{
    [102887] = { time = 1800/30, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop }, hook_element = 102892 }
}
local triggers = {
    --[100240] = { id = "PAL", special_function = SF.RemoveTracker },
    [102502] = { time = 60, id = "PAL", icons = { Icon.Money }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [102505] = { id = "PAL", special_function = SF.RemoveTracker },
    [102749] = { id = "PAL", special_function = SF.PauseTracker },
    [102738] = { id = "PAL", special_function = SF.PauseTracker },
    [102744] = { id = "PAL", special_function = SF.UnpauseTracker },
    [102826] = { id = "PAL", special_function = SF.RemoveTracker },

    [102301] = { time = 15, id = "Trap", icons = { Icon.C4 }, class = TT.Warning },
    [101566] = { id = "Trap", special_function = SF.RemoveTracker },

    [101230] = { time = 120, id = "Water", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101231] = { id = "Water", special_function = SF.PauseTracker }
}

for i = 4700, 4850, 50 do
    local waypoint_id = EHI:GetInstanceElementID(100019, i)
    triggers[EHI:GetInstanceElementID(100004, i)] = { special_function = SF.ShowWaypoint, data = { icon = Icon.LootDrop, position_by_element = waypoint_id } }
end

local heli = { id = "HeliCageDelay", icons = HeliLootDropWait, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning }
local sync_triggers = {
    [EHI:GetInstanceElementID(100013, 4700)] = heli,
    [EHI:GetInstanceElementID(100013, 4750)] = heli,
    [EHI:GetInstanceElementID(100013, 4800)] = heli,
    [EHI:GetInstanceElementID(100013, 4850)] = heli
}
if EHI:IsClient() then
    local ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists = EHI:GetFreeCustomSpecialFunctionID()
    triggers[102892] = { time = 1800/30 + 120, random_time = 60, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100013, 4700)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    triggers[EHI:GetInstanceElementID(100013, 4750)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    triggers[EHI:GetInstanceElementID(100013, 4800)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    triggers[EHI:GetInstanceElementID(100013, 4850)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    EHI:SetSyncTriggers(sync_triggers)
    EHI:SetSyncTriggers(element_sync_triggers)
    EHI:RegisterCustomSpecialFunction(ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, function(trigger, ...)
        managers.ehi:RemoveTracker(trigger.data.id)
        if managers.ehi:TrackerDoesNotExist(trigger.id) then
            EHI:CheckCondition(trigger)
        end
    end)
else
    EHI:AddHostTriggers(sync_triggers, nil, nil, "base")
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local achievements =
{
    pal_3 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [102301] = { class = TT.AchievementStatus },
            [101976] = { special_function = SF.SetAchievementComplete },
            [101571] = { special_function = SF.SetAchievementFailed }
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
local value_max = tweak_data.achievement.loot_cash_achievements.pal_2.secured.value
local loot_value = managers.money:get_secured_bonus_bag_value("counterfeit_money", 1)
local max = math.ceil(value_max / loot_value)
EHI:ShowAchievementLootCounter({
    achievement = "pal_2",
    max = max
})

local DisableWaypoints =
{
    -- Defend
    [100912] = true,
    [100913] = true,
    -- Fix
    [100916] = true,
    [100917] = true
}
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    -- Drill
    [102192] = { remove_vanilla_waypoint = true, waypoint_id = 100943 }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        counterfeit_found_sus_doors = 2000,
        counterfeit_first_hack_finish = 2500,
        counterfeit_defuse_c4 = 2000,
        vault_drill_done = 5000,
        vault_open = 6000,
        counterfeit_printed_money = 4000,
        escape = 3000
    },
    loot =
    {
        counterfeit_money = 1000
    },
    no_total_xp = true
})