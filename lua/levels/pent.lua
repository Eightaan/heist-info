local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local very_hard_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard)
local heli_element_timer = 102292
local heli_delay = 60 -- Normal -> Very Hard
-- Bugged because of braindead use of ElementTimerTrigger...
--[[if EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    heli_element_timer = 102293
    heli_delay = 80
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) then
    heli_element_timer = 102294
    heli_delay = 100
end]]
local triggers = {
    -- Loud Heli Escape
    [101539] = { time = 5, id = "EndlessAssault", icons = Icon.EndlessAssault, class = TT.Warning },
    [102295] = { additional_time = 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = heli_element_timer },
    [102296] = { id = "HeliEscape", special_function = SF.PauseTracker },
    [102297] = { id = "HeliEscape", special_function = SF.UnpauseTracker },

    -- Window Cleaning Platform
    [EHI:GetInstanceElementID(100047, 9280)] = { time = 20, id = "PlatformLoweringDown", icons = { Icon.Wait } },

    -- Elevator
    [101277] = { time = 12, id = "ElevatorDown", icons = { Icon.Wait } },
    [102061] = { time = 900/30, id = "ElevatorUp", icons = { Icon.Wait } },

    -- Elevator Generator
    [EHI:GetInstanceElementID(100066, 13930)] = { chance = 0, id = "GeneratorStartChance", icons = { Icon.Power }, class = TT.Chance },
    [EHI:GetInstanceElementID(100018, 13930)] = { id = "GeneratorStartChance", special_function = SF.IncreaseChanceFromElement }, -- +33%
    [EHI:GetInstanceElementID(100016, 13930)] = { id = "GeneratorStartChance", special_function = SF.RemoveTracker },

    -- Thermite
    [EHI:GetInstanceElementID(100035, 9930)] = { time = 22.5 * 3, id = "Thermite", icons = { Icon.Fire } },

    -- Car Platform
    [EHI:GetInstanceElementID(100133, 7830)] = { time = 1200/30, id = "CarRotate", icons = { Icon.Car, Icon.Wait} },
    [EHI:GetInstanceElementID(100002, 7830)] = { time = 300/30, id = "CarLiftUp", icons = { Icon.Car, Icon.Wait } },
    [EHI:GetInstanceElementID(100002, 7830)] = { time = 5, id = "CarSpeedUp", icons = { Icon.Car, Icon.Wait } },

    -- Lobby PCs
    [EHI:GetInstanceElementID(100014, 8230)] = { time = 10 + 3, id = "PCHack1", icons = { Icon.PCHack } },
    [EHI:GetInstanceElementID(100014, 13330)] = { time = 10 + 3, id = "PCHack2", icons = { Icon.PCHack } },
    [EHI:GetInstanceElementID(100014, 14430)] = { time = 10 + 3, id = "PCHack3", icons = { Icon.PCHack } },
    [EHI:GetInstanceElementID(100014, 17830)] = { time = 10 + 3, id = "PCHack4", icons = { Icon.PCHack } }
}
if EHI:IsClient() then
    -- FOR THE LOVE OF GOD
    -- OVERKILL
    -- STOP. USING. F... RANDOM DELAY, it's not funny
    triggers[102295].time = heli_delay + triggers[102295].additional_time
    triggers[102295].random_time = 20
    triggers[102295].class = TT.InaccuratePausable
    triggers[102295].synced = { class = TT.Pausable }
    triggers[102295].delay_only = true
    EHI:AddSyncTrigger(102295, triggers[102295])
    triggers[102303] = { time = 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    if EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL) then
        triggers[103584] = { time = 70 + 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    else
        triggers[103585] = { time = 90 + 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    end

    -- Thermite
    triggers[EHI:GetInstanceElementID(100036, 9930)] = { time = 22.5 * 2, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist }
    -- 100037 has 0s delay for some reason...
    triggers[EHI:GetInstanceElementID(100038, 9930)] = { time = 22.5, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist }
end

local DisableWaypoints = {}

-- pent_editing_room
for i = 11680, 12680, 500 do
    DisableWaypoints[EHI:GetInstanceElementID(100016, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100093, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100044, i)] = true -- Fix
    DisableWaypoints[EHI:GetInstanceElementID(100107, i)] = true -- Fix
end

-- pent_security_box
for _, index in ipairs({ 17930, 18330, 18830, 19230, 19630, 20030, 20430 }) do
    DisableWaypoints[EHI:GetInstanceElementID(100081, index)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100082, index)] = true -- Fix
end

EHI:ParseTriggers({ mission = triggers })
EHI:DisableWaypoints(DisableWaypoints)
local loot_triggers = {}
if very_hard_and_up then
    EHI:AddOnAlarmCallback(function()
        EHI:ShowAchievementLootCounter({
            achievement = "pent_12",
            max = 1,
            remove_after_reaching_target = false,
            counter =
            {
                check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                loot_type = "gnome"
            }
        })
    end)
    loot_triggers[103616] = { special_function = SF.IncreaseProgressMax }
    loot_triggers[103617] = { special_function = SF.IncreaseProgressMax }
end

local max = 8
EHI:ShowLootCounter({
    max = max,
    triggers = loot_triggers
})

function DigitalGui:pent_10()
    local key = self._ehi_key or tostring(self._unit:key())
    local hook_key = "EHI_pent_10_" .. key
    if EHI:GetUnlockableOption("show_achievement_started_popup") then
        local function AchievementStarted(...)
            managers.hud:ShowAchievementStartedPopup("pent_10")
        end
        if self.TimerStartCountDown then
            EHI:HookWithID(self, "TimerStartCountDown", hook_key .. "_start", AchievementStarted)
        else
            EHI:HookWithID(self, "timer_start_count_down", hook_key .. "_start", AchievementStarted)
        end
    end
    if EHI:GetUnlockableOption("show_achievement_failed_popup") then
        EHI:HookWithID(self, "_timer_stop", hook_key .. "_end", function(...)
            managers.hud:ShowAchievementFailedPopup("pent_10")
        end)
    end
end

local tbl =
{
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [102452] = { f = function(unit_id, unit_data, unit)
        unit:digital_gui():SetRemoveOnPause(true)
        unit:digital_gui():SetWarning(true)
        if EHI:CanShowAchievement("pent_10") then
            unit:digital_gui():SetIcons(EHI:GetAchievementIcon("pent_10"))
            unit:digital_gui():pent_10()
        end
    end },
    [103872] = { ignore = true }
}
EHI:UpdateUnits(tbl)