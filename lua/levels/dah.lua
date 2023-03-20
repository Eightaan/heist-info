local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local heli_delay = 26 + 6
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local dah_laptop_codes = { [1900] = "red", [2100] = "green", [2300] = "blue" }
local element_sync_triggers =
{
    [103569] = { time = 25, id = "CFOFall", icons = { "hostage", Icon.Goto }, hook_element = 100438 }
}
local triggers = {
    [100276] = { time = 25 + 3 + 11, id = "CFOInChopper", icons = { Icon.Heli, Icon.Goto } },

    [101343] = { time = 30, id = "KeypadReset", icons = { Icon.Loop }, waypoint = { position_by_element = EHI:GetInstanceElementID(100179, 9100) } },

    [104875] = { time = 45 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element = 100475 } },
    [103159] = { time = 30 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element = 103163 } },

    [103969] = { id = "ColorCodes", class = TT.ColoredCodes },
    [102338] = { id = "ColorCodes", special_function = SF.RemoveTracker }
}
if EHI:GetOption("show_mission_trackers") then
    for index, color in pairs(dah_laptop_codes) do
        local unit_id = EHI:GetInstanceUnitID(100052, index)
        for i = 0, 9, 1 do
            managers.mission:add_runned_unit_sequence_trigger(unit_id, "set_" .. color .. "_0" .. tostring(i), function(...)
                managers.ehi:CallFunction("ColorCodes", "SetCode", color, i)
            end)
        end
    end
end
if EHI:IsClient() then
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local other =
{
    [100479] = EHI:AddAssaultDelay({ time = 30 + 2 + 30 })
}

local function dah_8()
    EHI:ShowAchievementLootCounter({
        achievement = "dah_8",
        max = 12,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = "diamondheist_big_diamond"
        }
    })
end
local achievements =
{
    dah_8 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [103969] = { special_function = SF.CustomCode, f = dah_8 },
            [102259] = { special_function = SF.SetAchievementComplete },
            [102261] = { special_function = SF.IncreaseProgress }
        },
        failed_on_alarm = true,
        load_sync = function(self)
            if EHI.ConditionFunctions.IsStealth() then
                dah_8()
                self:SetTrackerProgress("dah_8", managers.loot:GetSecuredBagsTypeAmount("diamondheist_big_diamond"))
            end
        end
    }
}

if OVKorAbove then
    EHI:AddLoadSyncFunction(function(self)
        if managers.game_play_central:GetMissionDisabledUnit(100950) then -- Red Diamond
            self:IncreaseTrackerProgressMax("LootCounter", 1)
        end
        self:SyncSecuredLoot()
    end)
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local DisableWaypoints =
{
    [101368] = true -- Drill waypoint for vault with red diamond
}
if EHI:MissionTrackersAndWaypointEnabled() then
    DisableWaypoints[104882] = true -- Defend during loud escape
    DisableWaypoints[103163] = true -- Exclamation mark during loud escape
end
for i = 2500, 2700, 200 do
    DisableWaypoints[EHI:GetInstanceElementID(100011, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100036, i)] = true -- Fix
end
EHI:DisableWaypoints(DisableWaypoints)

EHI:ShowLootCounter({
    max = 8,
    triggers =
    {
        [101019] = { special_function = SF.IncreaseProgressMax } -- Red Diamond
    },
    -- Difficulties Very Hard or lower can load sync via EHI as the Red Diamond does not spawn on these difficulties
    no_sync_load = OVKorAbove
})
local xp =
{
    objective =
    {
        diamond_heist_boxes_hack = 4000,
        diamond_heist_found_color_codes = { amount = 1000, stealth = true },
        diamond_heist_found_keycard = 2000,
        diamond_heist_cfo_in_heli = { amount = 4000, loud = true },
        vault_open = { amount = 4000, loud = true },
        escape =
        {
            { amount = 2000, stealth = true },
            { amount = 4000, loud = true }
        }
    }
}
if OVKorAbove then
    xp.loot =
    {
        red_diamond = 2000,
        diamonds_dah = 400
    }
else
    xp.loot_all = 400
end
EHI:AddXPBreakdown(xp)
if EHI:IsHost() then
    dah_laptop_codes = nil
    return
end
local bg = Idstring("g_code_screen"):key()
local codes = {}
for _, color in pairs(dah_laptop_codes) do
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
EHI:AddLoadSyncFunction(function(self)
    if EHI.ConditionFunctions.IsStealth() then
        EHI:Trigger(103969)
        local wd = managers.worlddefinition
        for index, color in pairs(dah_laptop_codes) do
            local unit_id = EHI:GetInstanceUnitID(100052, index)
            local unit = wd:get_unit(unit_id)
            local code = CheckIfCodeIsVisible(unit, color)
            if code then
                managers.ehi:CallFunction("ColorCodes", "SetCode", color, code)
            end
        end
    end
    -- Clear memory
    bg = nil
    codes = nil
    dah_laptop_codes = nil
end)