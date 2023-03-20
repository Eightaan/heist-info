local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [103030] = { time = 19, id = "InsideManTalk", icons = { "pd2_talk" } },

    -- C4 in the meeting room
    [EHI:GetInstanceElementID(100025, 20420)] = { time = 5, id = "C4MeetingRoom", icons = { Icon.C4 } },

    -- C4 in the vault room
    [EHI:GetInstanceElementID(100022, 11770)] = { time = 5, id = "C4VaultWall", icons = { Icon.C4 } },

    -- Chandelier swing
    [EHI:GetInstanceElementID(100137, 20420)] = { time = 10 + 1 + 52/30, id = "Swing", icons = { Icon.Wait } },

    -- Heli Extraction
    [101432] = { id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.GetElementTimerAccurate, element = 101362 },

    [EHI:GetInstanceElementID(100210, 14670)] = { time = 3 + EHI:GetKeypadResetTimer(), id = "KeypadReset", icons = { Icon.Wait }, waypoint = { position_by_unit = EHI:GetInstanceElementID(100279, 14670) } },
    [EHI:GetInstanceElementID(100176, 14670)] = { time = 30, id = "KeypadResetECMJammer", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, waypoint = { position_by_unit = EHI:GetInstanceElementID(100279, 14670) } },

    [102571] = { time = 10 + 15.25 + 0.5 + 0.2, random_time = 5, id = "WinchDrop", icons = { Icon.Heli, Icon.Winch, Icon.Goto } },

    -- Winch (the element is actually in instance "chas_heli_drop")
    [EHI:GetInstanceElementID(100097, 21420)] = { time = 150, id = "Winch", icons = { Icon.Winch }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100104, 21420)] = { id = "Winch", special_function = SF.UnpauseTracker },
    [EHI:GetInstanceElementID(100105, 21420)] = { id = "Winch", special_function = SF.PauseTracker },
    -- DON'T REMOVE THIS, because OVK's scripting skills suck
    -- They pause the timer when it reaches zero for no reason. But the timer is already stopped via Lua...
    [EHI:GetInstanceElementID(100101, 21420)] = { id = "Winch", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100096, 21420)] = { time = 5 + 15, id = "HeliRaise", icons = { Icon.Heli, Icon.Wait } },

    [102675] = { additional_time = 5 + 10 + 14, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.GetElementTimerAccurate, element = 102674 },

    [103269] = { time = 7 + 614/30, id = "BoatEscape", icons = Icon.BoatEscapeNoLoot }
}
if EHI:IsClient() then
    local wait_time = 90 -- Very Hard and below
    local pickup_wait_time = 25 -- Normal and Hard
    if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.Mayhem) then -- Very Hard to Mayhem
        pickup_wait_time = 40
    end
    if EHI:IsBetweenDifficulties(EHI.Difficulties.OVERKILL, EHI.Difficulties.Mayhem) then -- OVERKILL or Mayhem
        wait_time = 120
    elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
        wait_time = 150
        pickup_wait_time = 55
    end
    triggers[101432].time = wait_time
    triggers[101432].random_time = 30
    triggers[101432].delay_only = true
    EHI:AddSyncTrigger(101432, triggers[101432])
    triggers[102675].time = pickup_wait_time + triggers[102675].additional_time
    triggers[102675].random_time = 15
    triggers[102675].delay_only = true
    EHI:AddSyncTrigger(102675, triggers[102675])
    if ovk_and_up then -- OVK and up
        triggers[101456] = { time = 120, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate }
    end
    triggers[101366] = { time = 60, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate }
    triggers[101463] = { time = 45, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate }
    triggers[101367] = { time = 30, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate }
    triggers[101372] = { time = 15, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate }
    triggers[102678] = { time = 45, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.SetTrackerAccurate }
    triggers[102679] = { time = 15, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.SetTrackerAccurate }
    -- "pulling_timer_trigger_120sec" but the time is set to 80s...
    triggers[EHI:GetInstanceElementID(100099, 21420)] = { time = 80, id = "Winch", icons = { Icon.Winch }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100100, 21420)] = { time = 90, id = "Winch", icons = { Icon.Winch }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100060, 21420)] = { time = 20, id = "Winch", icons = { Icon.Winch }, special_function = SF.AddTrackerIfDoesNotExist }
end

if EHI:CanShowAchievement("chca_12") and ovk_and_up then
    local active_saws = 0
    local function chca_12(unit_id, unit_data, unit)
        unit:timer_gui():chca_12()
    end
    local function check(...)
        active_saws = active_saws + 1
        if active_saws > 1 then
            managers.ehi:SetAchievementFailed("chca_12")
        end
    end
    local function saw_done()
        active_saws = active_saws - 1
    end
    function TimerGui:chca_12()
        local key = self._ehi_key or tostring(self._unit:key())
        local hook_key = "EHI_saw_start_" .. key
        if self.PostStartTimer then
            EHI:HookWithID(self, "PostStartTimer", hook_key, check)
        else
            EHI:HookWithID(self, "_start", hook_key, check)
        end
    end
    local tbl =
    {
        [100122] = { f = chca_12 },
        [100011] = { f = chca_12 },
        [100079] = { f = chca_12 },
        [100080] = { f = chca_12 }
    }
    EHI:UpdateInstanceUnitsNoCheck(tbl, 15470)
    local trigger = { special_function = SF.CustomCode, f = saw_done }
    triggers[EHI:GetInstanceElementID(100082, 15470)] = trigger
    triggers[EHI:GetInstanceElementID(100083, 15470)] = trigger
    triggers[EHI:GetInstanceElementID(100084, 15470)] = trigger
    triggers[EHI:GetInstanceElementID(100085, 15470)] = trigger
end

local DisableWaypoints =
{
    -- chca_spa
    -- chca_spa_1
    [EHI:GetInstanceElementID(100125, 11970)] = true, -- Defend
    [EHI:GetInstanceElementID(100126, 11970)] = true, -- Fix
    -- chca_spa_2
    [EHI:GetInstanceElementID(100128, 12470)] = true, -- Defend
    [EHI:GetInstanceElementID(100129, 12470)] = true, -- Fix
    -- chca_casino_hack
    -- chca_casino_hack/001
    [EHI:GetInstanceElementID(100034, 20620)] = true, -- Defend
    [EHI:GetInstanceElementID(100060, 20620)] = true, -- Fix
    -- chca_casino_hack/002
    [EHI:GetInstanceElementID(100034, 20820)] = true, -- Defend
    [EHI:GetInstanceElementID(100060, 20820)] = true -- Fix
}

local function chca_9_fail()
    managers.ehi:SetAchievementFailed("chca_9")
    EHI:Unhook("chca_9_killed")
    EHI:Unhook("chca_9_killed_by_anyone")
end
local achievements =
{
    chca_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            -- Players spawned
            [100264] = { special_function = SF.Trigger, data = { 1, 2 } }, -- Guest Rooms (civilian mode)
            [102955] = { special_function = SF.Trigger, data = { 1, 2 } }, -- Crew Deck
            [1] = { status = "ok", class = TT.AchievementStatus },
            [2] = { special_function = SF.CustomCode, f = function()
                local function check(self, data)
                    if data.variant ~= "melee" then
                        chca_9_fail()
                    end
                end
                EHI:HookWithID(StatisticsManager, "killed", "EHI_chca_9_killed", check)
                EHI:HookWithID(StatisticsManager, "killed_by_anyone", "EHI_chca_9_killed_by_anyone", check)
            end }
        },
        alarm_callback = chca_9_fail
    },
    chca_10 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem),
        elements =
        {
            [100264] = { max = 8, class = TT.AchievementProgress, remove_after_reaching_target = false }, -- Guest Rooms (civilian mode)
            [102955] = { max = 8, class = TT.AchievementProgress, remove_after_reaching_target = false }, -- Crew Deck
            [102944] = { special_function = SF.IncreaseProgress }, -- Bodybag thrown
            [103371] = { special_function = SF.SetAchievementFailed } -- Civie killed
        },
        failed_on_alarm = true
    },
    chca_12 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [EHI:GetInstanceElementID(100041, 11770)] = { special_function = SF.ShowAchievementFromStart, class = TT.AchievementStatus },
            [103584] = { status = "finish", special_function = SF.SetAchievementStatus }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 45 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:DisableWaypoints(DisableWaypoints)
--[[local LootLeft = EHI:GetFreeCustomSpecialFunctionID()
EHI:ShowLootCounter({
    max = 16,
    additional_loot = 2, -- Teaset and Money bundle
    triggers =
    {
        [103761] = { max = 16, special_function = SF.DecreaseProgressMax }, -- C4 Plan
        [EHI:GetInstanceElementID(100014, 15470)] = { special_function = LootLeft }, -- Ink (Stealth)
        [EHI:GetInstanceElementID(100063, 15470)] = { special_function = LootLeft } -- Burn (Loud)
    }
})
local units = {}
for i = 100017, 100020, 1 do
    units[EHI:GetInstanceElementID(i, 15470)] = true
end
for i = 100028, 100030, 1 do
    units[EHI:GetInstanceElementID(i, 15470)] = true
end
for i = 100034, 100041, 1 do
    units[EHI:GetInstanceElementID(i, 15470)] = true
end
EHI:RegisterCustomSpecialFunction(LootLeft, function(...)
    local left_to_burn = 16
    for unit_id, _ in pairs(units) do
        local unit = managers.worlddefinition:get_unit(unit_id)
        -- If the unit has "body" table, then players bagged it
        if unit and unit:damage()._state and unit:damage()._state.body then
            left_to_burn = left_to_burn - 1
        end
    end
    managers.ehi:DecreaseTrackerProgressMax("LootCounter", left_to_burn)
end)
EHI:AddLoadSyncFunction(function(self)
    if managers.game_play_central:GetMissionDisabledUnit(200942) then -- AI Vision Blocker; "editor_only" continent
        self:DecreaseTrackerProgressMax("LootCounter", 16)
    end
end)]]