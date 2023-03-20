local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local heli_delay = 22 + 1 + 1.5
local heli_icon = { Icon.Heli, Icon.Winch, Icon.Goto }
local refill_icon = { Icon.Water, Icon.Loop }
local heli_60 = { time = 60 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled }
local heli_30 = { time = 30 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled }
if EHI:GetOption("show_one_icon") then
    refill_icon = { { icon = Icon.Water, color = Color("D4F1F9") } }
end
local keycode_units =
{
    red =
    {
        unit_id = 100000,
        indexes = { 28250, 15020, 15120 }
    },
    green =
    {
        unit_ids = { 100125, 100113, 100224, 100225, 100007, 100290 },
        indexes = { 21500, 25000, 31225 }
    },
    blue =
    {
        unit_ids = { 100061, 100064 },
        index = 15370
    }
}
local DontTriggerWithC4Entry = EHI:GetFreeCustomSpecialFunctionID()
local RemoveColorsIfEnabled = EHI:GetFreeCustomSpecialFunctionID()
local preload =
{
    { id = "RefillLeft01", icons = refill_icon, hide_on_delete = true },
    { id = "RefillLeft02", icons = refill_icon, hide_on_delete = true },
    { id = "RefillRight01", icons = refill_icon, hide_on_delete = true },
    { id = "RefillRight02", icons = refill_icon, hide_on_delete = true }
}
local triggers = {
    [100282] = { id = "ColorCodes", class = TT.ColoredCodes, special_function = DontTriggerWithC4Entry },
    [100091] = { id = "ColorCodes", special_function = SF.RemoveTracker }, -- Code entered (stealth)
    [101357] = { id = "ColorCodes", special_function = RemoveColorsIfEnabled }, -- Code entered (loud)

    [EHI:GetInstanceElementID(100173, 66615)] = { time = 5 + 25, id = "ArmoryKeypadReboot", icons = { Icon.Wait }, waypoint = { position = Vector3(9823.0, -40877.0, -2987.0) + Vector3(0, 0, 0):rotate_with(Rotation()) } },

    [EHI:GetInstanceElementID(100030, 11750)] = { time = 5, id = "C4Lower", icons = { Icon.C4 } },
    [EHI:GetInstanceElementID(100030, 11850)] = { time = 5, id = "C4Top", icons = { Icon.C4 } },

    [EHI:GetInstanceElementID(100021, 29150)] = heli_60,
    [EHI:GetInstanceElementID(100042, 29150)] = heli_30,
    [EHI:GetInstanceElementID(100021, 29225)] = heli_60,
    [EHI:GetInstanceElementID(100042, 29225)] = heli_30,
    [EHI:GetInstanceElementID(100021, 15220)] = heli_60,
    [EHI:GetInstanceElementID(100042, 15220)] = heli_30,
    [EHI:GetInstanceElementID(100021, 15295)] = heli_60,
    [EHI:GetInstanceElementID(100042, 15295)] = heli_30,

    -- Toilets
    [EHI:GetInstanceElementID(100181, 13000)] = { id = "RefillLeft01", run = { time = 30 } },
    [EHI:GetInstanceElementID(100233, 13000)] = { id = "RefillRight01", run = { time = 30 } },
    [EHI:GetInstanceElementID(100299, 13000)] = { id = "RefillLeft02", run = { time = 30 } },
    [EHI:GetInstanceElementID(100300, 13000)] = { id = "RefillRight02", run = { time = 30 } },

    [100489] = { special_function = SF.RemoveTracker, data = { "WaterTimer1", "WaterTimer2" } },

    [EHI:GetInstanceElementID(100166, 37575)] = { id = "DrillDrop", icons = { Icon.Winch, Icon.Drill, Icon.Goto }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
    [EHI:GetInstanceElementID(100167, 37575)] = { id = "DrillDrop", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100166, 44535)] = { id = "DrillDrop", icons = { Icon.Winch, Icon.Drill, Icon.Goto }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
    [EHI:GetInstanceElementID(100167, 44535)] = { id = "DrillDrop", special_function = SF.PauseTracker },

    -- Water during drilling
    [EHI:GetInstanceElementID(100148, 37575)] = { id = "WaterTimer1", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60 } },
    [EHI:GetInstanceElementID(100146, 37575)] = { id = "WaterTimer1", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100149, 37575)] = { id = "WaterTimer2", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60 } },
    [EHI:GetInstanceElementID(100147, 37575)] = { id = "WaterTimer2", special_function = SF.PauseTracker },

    -- Skylight Hack
    [EHI:GetInstanceElementID(100018, 29650)] = { time = 30, id = "SkylightHack", icons = { Icon.PCHack }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100037, 29650)] = { id = "SkylightHack", special_function = SF.PauseTracker },

    [100159] = { id = "BlimpWithTheDrill", icons = { Icon.Blimp, Icon.Drill }, special_function = SF.SetTimeByPreplanning, data = { id = 101854, yes = 976/30, no = 1952/30 } },
    [100426] = { time = 1000/30, id = "BlimpLowerTheDrill", icons = { Icon.Blimp, Icon.Drill, Icon.Goto } },

    [EHI:GetInstanceElementID(100173, 66365)] = { time = 30, id = "VaultKeypadReset", icons = { Icon.Loop } }
}
if EHI:GetOption("show_mission_trackers") then
    local function hook(unit_id, color)
        for i = 0, 9, 1 do
            managers.mission:add_runned_unit_sequence_trigger(unit_id, "set_" .. color .. "_0" .. tostring(i), function(...)
                managers.ehi:CallFunction("ColorCodes", "SetCode", color, i)
            end)
        end
    end
    for color, data in pairs(keycode_units) do
        if data.unit_ids then
            for _, unit_id in ipairs(data.unit_ids) do
                if data.indexes then
                    for _, index in ipairs(data.indexes) do
                        hook(EHI:GetInstanceUnitID(unit_id, index), color)
                    end
                else
                    hook(EHI:GetInstanceUnitID(unit_id, data.index), color)
                end
            end
        else
            local unit_id = data.unit_id
            if data.indexes then
                for _, index in ipairs(data.indexes) do
                    hook(EHI:GetInstanceUnitID(unit_id, index), color)
                end
            else
                hook(EHI:GetInstanceUnitID(unit_id, data.index), color)
            end
        end
    end
end
EHI:RegisterCustomSpecialFunction(DontTriggerWithC4Entry, function(trigger, ...)
    if managers.preplanning:IsAssetBought(101826) then -- Loud entry with C4
        return
    end
    EHI:AddTracker(trigger)
end)
EHI:RegisterCustomSpecialFunction(RemoveColorsIfEnabled, function(trigger, element, enabled)
    if enabled then
        managers.ehi:RemoveTracker(trigger.id)
    end
end)

local achievements =
{
    kenaz_3 =
    {
        elements =
        {
            [102807] = { class = TT.AchievementStatus },
            [102809] = { special_function = SF.SetAchievementFailed },
            [103163] = { status = "finish", special_function = SF.SetAchievementStatus }
        }
    },
    kenaz_4 =
    {
        elements =
        {
            [100282] = { time = 840, class = TT.Achievement }
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("kenaz_4", 840)
        end,
        mission_end_callback = true
    },
    kenaz_5 =
    {
        elements =
        {
            [EHI:GetInstanceElementID(100008, 12500)] = { class = TT.AchievementStatus },
            [EHI:GetInstanceElementID(100008, 12580)] = { class = TT.AchievementStatus },
            [EHI:GetInstanceElementID(100008, 12660)] = { class = TT.AchievementStatus },
            [EHI:GetInstanceElementID(100008, 18700)] = { class = TT.AchievementStatus },
            [102806] = { status = "finish", special_function = SF.SetAchievementStatus },
            [102808] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local Alarm = EHI:GetFreeCustomSpecialFunctionID()
local other =
{
    [100228] = EHI:AddAssaultDelay({ time = 35 + 1 + 30, special_function = Alarm })
}
EHI:RegisterCustomSpecialFunction(Alarm, function(trigger, ...)
    local t = 0
    if managers.preplanning:IsAssetBought(101858) then
        t = 10
    elseif managers.preplanning:IsAssetBought(101815) then
        t = 30
    end
    trigger.time = trigger.time + t
    EHI:CheckCondition(trigger)
end)

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    preload = preload
})
local bags = 5 + 2 + 5 -- Normal + Hard
if EHI:IsDifficulty(EHI.Difficulties.VeryHard) then
    bags = 8 + 3 + 8
elseif EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    bags = 10 + 4 + 10
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) then
    bags = 12 + 5 + 12
end
EHI:ShowLootCounter({
    max = 1, -- Dentist loot; mandatory
    additional_loot = bags + 1 -- Money + Painting
})

local DisableWaypoints =
{
    -- Defend
    [EHI:GetInstanceElementID(100347, 37575)] = true,
    [EHI:GetInstanceElementID(100347, 44535)] = true
}
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    --levels/instances/unique/kenaz/the_drill
    --units/pd2_dlc_casino/props/cas_prop_drill/cas_prop_drill
    [EHI:GetInstanceUnitID(100000, 37575)] = { icons = { Icon.Drill }, ignore_visibility = true },
    [EHI:GetInstanceUnitID(100000, 44535)] = { icons = { Icon.Drill }, ignore_visibility = true }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        ggc_gear_found = { amount = 1000, stealth = true },
        ggc_blueprint_found = { amount = 4000, stealth = true },
        ggc_blueprint_send = { amount = 4000, stealth = true },
        ggc_got_data = { amount = 4000, stealth = true },
        ggc_civie_drugged = { amount = 4000, stealth = true },
        ggc_gas_planted = { amount = 4000, stealth = true },
        ggc_color_code = { amount = 4000, times = 3 },
        vault_open = { amount = 4000, stealth = true },
        ggc_laser_disabled = { amount = 2000, stealth = true },
        ggc_locker_room_found = { amount = 2000, loud = true },
        ggc_c4_taken = { amount = 2000, loud = true, times = 1 },
        ggc_weak_spot_found = { amount = 4000, loud = true },
        ggc_winch_part_picked_up = { amount = 3000, loud = true, times = 1 },
        ggc_winch_set_up = { amount = 6000, loud = true },
        ggc_fireworks = { amount = 2000, loud = true },
        ggc_winch_connected_to_bfd = { amount = 1000, loud = true },
        ggc_bfd_lowered = { amount = 8000, loud = true },
        ggc_bfd_started = { amount = 6000, loud = true },
        ggc_bfd_done = { amount = 1000, loud = true }
    },
    loot =
    {
        unknown = 250
    }
})

if EHI:IsHost() then
    keycode_units = nil
    return
end
local bg = Idstring("g_top_opened"):key()
local codes = {}
for _, color in ipairs({ "red", "green", "blue" }) do
    codes[color] = {}
    local _c = codes[color]
    for i = 0, 9, 1 do
        local str = "g_number_" .. color .. "_0" .. tostring(i)
        _c[i] = Idstring(str):key()
    end
end
local function CheckIfCodeIsVisible(unit, color)
    if not unit then
        return nil
    end
    local color_codes = codes[color]
    local object = unit:damage() and unit:damage()._state and unit:damage()._state.object
    if object and object[bg] then
        for i = 0, 9, 1 do
            if object[color_codes[i]] then
                return i
            end
        end
    end
    return nil -- Has not been interacted yet
end
local function Cleanup()
    keycode_units = nil
    codes = nil
    bg = nil
end
EHI:AddLoadSyncFunction(function(self)
    if managers.preplanning:IsAssetBought(101826) then -- Loud entry with C4
        return Cleanup()
    end
    if EHI.ConditionFunctions.IsStealth() and self:IsMissionElementDisabled(100270) then -- If it is disabled, the vault has been opened; exit
        return Cleanup()
    elseif managers.game_play_central:GetMissionEnabledUnit(EHI:GetInstanceUnitID(100184, 66615)) then -- If it is enabled, the armory has been opened; exit
        return Cleanup()
    end
    self:AddTracker({
        id = "ColorCodes",
        class = TT.ColoredCodes
    })
    local wd = managers.worlddefinition
    for color, data in pairs(keycode_units) do
        if data.unit_ids then
            for _, unit_id in ipairs(data.unit_ids) do
                if data.indexes then
                    for _, index in ipairs(data.indexes) do
                        local unit = wd:get_unit(EHI:GetInstanceUnitID(unit_id, index))
                        local code = CheckIfCodeIsVisible(unit, color)
                        if code then
                            managers.ehi:CallFunction("ColorCodes", "SetCode", color, code)
                            break
                        end
                    end
                else
                    local unit = wd:get_unit(EHI:GetInstanceUnitID(unit_id, data.index))
                    local code = CheckIfCodeIsVisible(unit, color)
                    if code then
                        managers.ehi:CallFunction("ColorCodes", "SetCode", color, code)
                        break
                    end
                end
            end
        else
            local unit_id = data.unit_id
            if data.indexes then
                for _, index in ipairs(data.indexes) do
                    local unit = wd:get_unit(EHI:GetInstanceUnitID(unit_id, index))
                    local code = CheckIfCodeIsVisible(unit, color)
                    if code then
                        managers.ehi:CallFunction("ColorCodes", "SetCode", color, code)
                        break
                    end
                end
            else
                local unit = wd:get_unit(EHI:GetInstanceUnitID(unit_id, data.index))
                local code = CheckIfCodeIsVisible(unit, color)
                if code then
                    managers.ehi:CallFunction("ColorCodes", "SetCode", color, code)
                    break
                end
            end
        end
    end
    Cleanup()
end)