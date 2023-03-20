local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local WT = EHI.Waypoints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local LootDrop = { Icon.Escape, Icon.LootDrop }
local TimedLootDrop = { Icon.Escape, Icon.LootDrop, Icon.Wait }
local FireTrapIndexes = { 0, 120, 240, 360, 480 }
local triggers = {
    [100647] = { time = 240 + 60, id = "Chimney", icons = LootDrop },
    [EHI:GetInstanceElementID(100078, 10700)] = { time = 60, id = "Chimney", icons = LootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100078, 11000)] = { time = 60, id = "Chimney", icons = LootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100011, 10700)] = { time = 207 + 3, id = "ChimneyClose", icons = TimedLootDrop, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } },
    [EHI:GetInstanceElementID(100011, 11000)] = { time = 207 + 3, id = "ChimneyClose", icons = TimedLootDrop, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } },
    [EHI:GetInstanceElementID(100135, 11300)] = { time = 12, id = "SafeEvent", icons = { Icon.Heli, Icon.Goto } }
}
local fire_recharge = { time = 180, id = "FireRecharge", icons = { Icon.Fire, Icon.Loop } }
local fire_t = { time = 60, id = "Fire", icons = { Icon.Fire }, class = TT.Warning }
for _, index in ipairs(FireTrapIndexes) do
    local recharge = deep_clone(fire_recharge)
    recharge.id = recharge.id .. index
    triggers[EHI:GetInstanceElementID(100024, index)] = recharge
    local fire = deep_clone(fire_t)
    fire.id = fire.id .. index
    triggers[EHI:GetInstanceElementID(100022, index)] = fire
end

local function cane_5()
    EHI:HookWithID(PlayerManager, "set_synced_deployable_equipment", "EHI_cane_5_fail_trigger", function(self, ...)
        if self._peer_used_deployable then
            managers.ehi:SetAchievementFailed("cane_5")
            EHI:Unhook("cane_5_fail_trigger")
        end
    end)
    EHI:ShowAchievementLootCounter({
        achievement = "cane_5",
        max = 10,
        counter =
        {
            loot_type = "present"
        }
    })
end
local achievements =
{
    cane_2 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101167] = { time = 1800, class = TT.AchievementUnlock },
            [101176] = { special_function = SF.SetAchievementFailed },
        }
    },
    cane_5 =
    {
        elements =
        {
            [100544] = { special_function = SF.CustomCode, f = function()
                if #managers.assets:get_unlocked_asset_ids(true) ~= 0 then
                    if EHI:GetUnlockableOption("show_achievement_failed_popup") then
                        managers.hud:ShowAchievementFailedPopup("cane_5")
                    end
                    return
                end
                cane_5()
            end },
        },
        load_sync = function(self)
            if #managers.assets:get_unlocked_asset_ids(true) ~= 0 or managers.player:has_deployable_been_used() then
                return
            end
            if managers.loot:GetSecuredBagsTypeAmount("present") >= 10 then
                return
            end
            cane_5()
        end
    }
}

if EHI:MissionTrackersAndWaypointEnabled() then
    local DisableWaypoints =
    {
        [EHI:GetInstanceElementID(100016, 10700)] = true,
        [EHI:GetInstanceElementID(100016, 11000)] = true
    }
    EHI:DisableWaypoints(DisableWaypoints)
    triggers[EHI:GetInstanceElementID(100011, 10700)].waypoint = { icon = Icon.LootDrop, position_by_element = EHI:GetInstanceElementID(100016, 10700), class = WT.Warning }
    triggers[EHI:GetInstanceElementID(100011, 11000)].waypoint = { icon = Icon.LootDrop, position_by_element = EHI:GetInstanceElementID(100016, 11000), class = WT.Warning }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
if ovk_and_up then
    EHI:ShowAchievementLootCounter({
        achievement = "cane_3",
        max = 100,
        remove_after_reaching_target = false
    })
end

local tbl =
{
    --cane_santa_event
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100014, 11300)] = { ignore = true },
    [EHI:GetInstanceUnitID(100056, 11300)] = { ignore = true },
    [EHI:GetInstanceUnitID(100226, 11300)] = { ignore = true },
    [EHI:GetInstanceUnitID(100227, 11300)] = { icons = { Icon.Vault }, remove_on_pause = true, completion = true }
}
for _, index in ipairs(FireTrapIndexes) do
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    -- OVK decided to use one timer for fire and fire recharge
	-- This ignores them and that timer is implemented in the for loop above
    tbl[EHI:GetInstanceUnitID(100002, index)] = { ignore = true }
end
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        safe_event_done = 4000,
        present_finished = 1000,
        escape = 4000
    },
    loot_all = 1000
})