local EHI = EHI
local Icon = EHI.Icons
EHIkosugi5Tracker = class(EHIAchievementProgressTracker)
function EHIkosugi5Tracker:init(panel, params)
    params.max = 16 -- Random loot
    self._armor_max = 4 -- Armor
    self._armor_counter = 0
    self._completion = {}
    EHIkosugi5Tracker.super.init(self, panel, params)
    self._remove_after_reaching_counter_target = false
    EHI:AddAchievementToCounter({
        achievement = "kosugi_5",
        counter =
        {
            check_type = EHI.LootCounter.CheckType.CustomCheck,
            f = function(self, tracker_id, loot_type)
                local armor_count = self:GetSecuredBagsTypeAmount("samurai_suit")
                local total_count = self:GetSecuredBagsAmount()
                managers.ehi:CallFunction(tracker_id, "SetProgressArmor", armor_count)
                managers.ehi:SetTrackerProgress(tracker_id, total_count - armor_count)
            end
        }
    })
end

function EHIkosugi5Tracker:OverridePanel()
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._armor_progress_text = self._time_bg_box:text({
        name = "text2",
        text = self:FormatArmorProgress(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self:FitTheText(self._armor_progress_text)
    self._armor_progress_text:set_left(self._text:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIkosugi5Tracker:FormatArmorProgress()
    return self._armor_counter .. "/" .. self._armor_max
end

function EHIkosugi5Tracker:SetCompleted(force)
    EHIkosugi5Tracker.super.SetCompleted(self, force)
    if self._status then
        self._text:set_text(self:Format())
        self:FitTheText()
        self:CheckCompletion("loot")
    end
end

function EHIkosugi5Tracker:SetProgressArmor(progress)
    if self._armor_counter ~= progress and not self._armor_counting_disabled then
        self._armor_counter = progress
        self._armor_progress_text:set_text(self:FormatArmorProgress())
        self:FitTheText(self._armor_progress_text)
        if self._armor_counter == self._armor_max then
            self._armor_progress_text:set_color(Color.green)
            self._armor_counting_disabled = true
            self:CheckCompletion("armor")
        end
        self:AnimateBG()
    end
end

function EHIkosugi5Tracker:CheckCompletion(type)
    self._completion[type] = true
    if self._completion.loot and self._completion.armor and not self._completion.final then
        self._completion.final = true
        self:AddTrackerToUpdate()
    end
end

local function CheckForBrokenWeapons()
    local world = managers.worlddefinition
    for i = 100863, 100867, 1 do
        local weapon = world:get_unit(i)
        if weapon and weapon:damage() and weapon:damage()._state and weapon:damage()._state.graphic_group and weapon:damage()._state.graphic_group.grp_wpn then
            local state = weapon:damage()._state.graphic_group.grp_wpn
            if state[1] == "set_visibility" and state[2] then
                --EHI:Log("Found broken unit weapon with ID: " .. tostring(i))
                managers.ehi:IncreaseTrackerProgressMax("LootCounter", 1)
            end
        end
    end
end

local function CheckForBrokenCocaine() -- Not working for drop-ins
    local world = managers.worlddefinition
    for i = 100686, 100692, 1 do -- 2 - 8
        local unit = world:get_unit(i)
        if unit and unit:damage() and unit:damage()._variables and unit:damage()._variables.var_hidden == 0 then
            --EHI:Log("Found broken unit cocaine with ID: " .. tostring(unit:editor_id()))
            managers.ehi:IncreaseTrackerProgressMax("LootCounter", 1)
        end
    end
end

for _, unit_id in ipairs({ 100098, 102897, 102899, 102900 }) do
    managers.mission:add_runned_unit_sequence_trigger(unit_id, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(unit_id),
            time = 10,
            icons = { Icon.Fire }
        })
    end)
end

EHI.AchievementTrackers.EHIkosugi5Tracker = true
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local DisableTriggerAndExecute = EHI:GetFreeCustomSpecialFunctionID()
local trigger = { special_function = SF.Trigger, data = { 1, 2 } }
local triggers = {
    [1] = { time = 300, id = "Blackhawk", icons = { Icon.Heli, Icon.Goto } },
    [2] = { special_function = SF.RemoveTrigger, data = { 101131, 100900 } },
    [101131] = trigger,
    [100900] = trigger,
    [101219] = { time = 27, id = "BlackhawkDropLoot", icons = { Icon.Heli, Icon.Loot, Icon.Goto } },
    [100303] = { time = 30, id = "BlackhawkDropGuards", icons = { Icon.Heli, "pager_icon", Icon.Goto }, class = TT.Warning },

    [100955] = { time = 10, id = "KeycardLeft", icons = { Icon.Keycard }, class = TT.Warning, special_function = DisableTriggerAndExecute, data = { id = 100957 } },
    [100957] = { time = 10, id = "KeycardRight", icons = { Icon.Keycard }, class = TT.Warning, special_function = DisableTriggerAndExecute, data = { id = 100955 } },
    [100967] = { special_function = SF.RemoveTracker, data = { "KeycardLeft", "KeycardRight" } }
}

local kosugi_3 = { id = "kosugi_3", special_function = SF.IncreaseProgress }
local achievements =
{
    kosugi_2 =
    {
        elements =
        {
            [102700] = { max = 6, class = TT.AchievementProgress, status_is_overridable = true, remove_after_reaching_target = false },
            [102796] = { special_function = SF.SetAchievementFailed },
            [100311] = { special_function = SF.IncreaseProgress }
        }
    },
    kosugi_3 =
    {
        elements =
        {
            [102700] = { max = 7, class = TT.AchievementProgress },
            [104040] = kosugi_3, -- Artifact
            [104041] = kosugi_3, -- Money
            [104042] = kosugi_3, -- Coke
            [104044] = kosugi_3, -- Server
            [104047] = kosugi_3, -- Gold
            [104048] = kosugi_3, -- Weapon
            [104049] = kosugi_3 -- Painting
        },
        load_sync = function(self)
            local counter = 0
            for _, loot_type in ipairs({ "artifact_statue", "money", "coke", "gold", "circuit", "weapon", "painting" }) do
                local amount = managers.loot:GetSecuredBagsTypeAmount(loot_type)
                counter = counter + math.min(amount, 1)
            end
            if counter < 7 then
                self:AddAchievementProgressTracker("kosugi_3", 7, counter)
            end
        end
    },
    kosugi_5 =
    {
        elements =
        {
            [102700] = { class = "EHIkosugi5Tracker" }
        },
        load_sync = function(self)
            local counter_armor = managers.loot:GetSecuredBagsTypeAmount("samurai_suit")
            local counter_loot = managers.loot:GetSecuredBagsAmount() - counter_armor
            if counter_loot < 16 or counter_armor < 4 then
                self:AddAchievementProgressTracker("kosugi_5", nil, math.min(counter_loot, 16)) -- Max is passed in the tracker "init" function
                self:CallFunction("kosugi_5", "SetProgressArmor", math.min(counter_armor, 4))
            end
        end,
        cleanup_callback = function()
            EHIkosugi5Tracker = nil
        end
    }
}

local dailies = {}
if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
    local IncreaseProgress = { special_function = SF.IncreaseProgress }
    local elements = {
        [103427] = { max = 9, icons = { "daily_secret_identity" }, class = TT.DailyProgress, remove_after_reaching_target = false },
        [100484] = IncreaseProgress,
        [100515] = IncreaseProgress,
        [100534] = IncreaseProgress,
        [100536] = IncreaseProgress
    }
    for i = 100491, 100509, 2 do
        elements[i] = IncreaseProgress
    end
    for i = 100519, 100531, 2 do
        elements[i] = IncreaseProgress
    end
    for i = 100539, 100555, 2 do
        elements[i] = IncreaseProgress
    end
    tweak_data.ehi.icons.daily_secret_identity = { texture = "guis/textures/pd2_mod_ehi/daily_secret_identity" }
    tweak_data.hud_icons.daily_secret_identity = tweak_data.ehi.icons.daily_secret_identity
    dailies.daily_secret_identity = { elements = elements }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    daily = dailies
})
EHI:RegisterCustomSpecialFunction(DisableTriggerAndExecute, function(t, ...)
    EHI:UnhookTrigger(t.data.id)
    EHI:CheckCondition(t)
end)

-- Loot Counter
-- 2 cocaine
-- 1 server
-- 2 random money bundles inside the warehouse
-- 4 random money bundles outside
-- 4 pieces of armor
local base_amount = 2 + 1 + 2 + 4 + 4
local random_weapons = 2
local random_paintings = 2
local crates = 4 -- (Normal + Hard)
if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
    crates = 5
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) then
    crates = 6
    random_weapons = 1
    random_paintings = 1
end
EHI:ShowLootCounter({
    max = base_amount + crates + random_weapons + random_paintings,
    triggers =
    {
        [103396] = { special_function = SF.IncreaseProgressMax },
        [102700] = { special_function = SF.CustomCode, f = function()
            CheckForBrokenWeapons()
            CheckForBrokenCocaine()
        end}
    },
    load_sync = function(self)
        CheckForBrokenWeapons()
        if managers.game_play_central:GetMissionEnabledUnit(103995) then
            self:IncreaseTrackerProgressMax("LootCounter")
        end
        self:SyncSecuredLoot()
    end
})
-- Not included bugged loot, this is checked after spawn -> 102700 in EHI:ShowLootCounter()
-- Reported here:
-- https://steamcommunity.com/app/218620/discussions/14/5710018482972011532/

EHI:ShowAchievementLootCounter({
    achievement = "kosugi_1",
    max = 4
})
EHI:ShowAchievementLootCounter({
    achievement = "kosugi_4",
    max = 4,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = "samurai_suit"
    }
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 4000, stealth = true }
        }
    },
    loot =
    {
        samurai_suit = { amount = 6000, to_secure = 4 },
        _else = { amount = 500, times = 16 },
        xp_bonus = { amount = 4000, to_secure = 3, times = 1 },
    }
})