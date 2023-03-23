if _G.EHI then
    return
end

_G.EHI =
{
    debug = false,
    settings = {},

    _hooks = {},

    _sync_triggers = {},

    HookOnLoad = {},

    LootCounter =
    {
        CheckType =
        {
            AllLoot = 1, -- Currently unused
            BagsOnly = 2,
            ValueOfBags = 3,
            SmallLootOnly = 4, -- Currently unused
            ValueOfSmallLoot = 5,
            OneTypeOfLoot = 6,
            CustomCheck = 7,
            Debug = 8
        }
    },

    _cache =
    {
        MissionUnits = {},
        InstanceUnits = {},
        IgnoreWaypoints = {},
        ElementWaypointFunction = {}
    },

    Callback = {},
    CallbackMessage =
    {
        Spawned = "Spawned",
        -- Provides "loc" (a LocalizationManager class)
        LocLoaded = "LocLoaded",
        -- Provides "success" (a boolean value)
        MissionEnd = "MissionEnd",
        GameRestart = "GameRestart",
        -- Provides "self" (a LootManager class)
        LootSecured = "LootSecured",
        -- Provides "managers" (a global table with all managers)
        InitManagers = "InitManagers",
        InitFinalize = "InitFinalize",
        -- Provides "self" (a LootManager class)
        LootLoadSync = "LootLoadSync",
        OnMinionAdded = "OnMinionAdded",
        OnMinionKilled = "OnMinionKilled",
        -- Provides "mode" (a string value)
        AssaultModeChanged = "AssaultModeChanged",
    },

    _base_delay = {},
    _element_delay = {},

    SyncMessages =
    {
        EHISyncAddTracker = "EHISyncAddTracker"
    },

    SpecialFunctions =
    {
        RemoveTracker = 1,
        PauseTracker = 2,
        UnpauseTracker = 3,
        UnpauseTrackerIfExists = 4,
        AddTrackerIfDoesNotExist = 5,
        ReplaceTrackerWithTracker = 6,
        ShowAchievementFromStart = 7,
        SetAchievementComplete = 8,
        SetAchievementStatus = 9,
        SetAchievementFailed = 10,
        IncreaseChance = 12,
        TriggerIfEnabled = 13,
        CreateAnotherTrackerWithTracker = 14,
        SetChanceWhenTrackerExists = 15,
        Trigger = 17,
        RemoveTrigger = 18,
        SetTimeOrCreateTracker = 19,
        ExecuteIfElementIsEnabled = 20,
        SetTimeByPreplanning = 24,
        IncreaseProgress = 25,
        SetTrackerAccurate = 27,
        SetRandomTime = 32,
        DecreaseChance = 34,
        GetElementTimerAccurate = 35,
        UnpauseOrSetTimeByPreplanning = 36,
        UnpauseTrackerIfExistsAccurate = 37,
        FinalizeAchievement = 39,
        IncreaseChanceFromElement = 42,
        DecreaseChanceFromElement = 43,
        SetChanceFromElement = 44,
        SetChanceFromElementWhenTrackerExists = 45,
        PauseTrackerWithTime = 46,
        IncreaseProgressMax = 48,
        SetTimeIfLoudOrStealth = 49,
        AddTimeByPreplanning = 50,
        ShowWaypoint = 51,
        ShowEHIWaypoint = 52,
        DecreaseProgressMax = 53,
        DecreaseProgress = 54,

        Debug = 1000,
        CustomCode = 1001,
        CustomCodeIfEnabled = 1002,
        CustomCodeDelayed = 1003,

        -- Don't use it directly! Instead, call "EHI:GetFreeCustomSpecialFunctionID()" and "EHI:RegisterCustomSpecialFunction()" respectively
        CustomSF = 100000
    },

    SFF = {},

    ConditionFunctions =
    {
        IsLoud = function()
            return managers.groupai and not managers.groupai:state():whisper_mode()
        end,
        IsStealth = function()
            return managers.groupai and managers.groupai:state():whisper_mode()
        end
    },

    Icons =
    {
        Trophy = "milestone_trophy",
        Fire = "pd2_fire",
        Escape = "pd2_escape",
        LootDrop = "pd2_lootdrop",
        Fix = "pd2_fix",
        Bag = "wp_bag",
        Defend = "pd2_defend",
        C4 = "pd2_c4",
        Interact = "pd2_generic_interact",
        Winch = "equipment_winch_hook",
        Teargas = "teargas",
        Hostage = "hostage",
        Methlab = "pd2_methlab",
        Loop = "restarter",
        Wait = "faster",
        Vault = "C_Elephant_H_ElectionDay_Murphy",
        Car = "pd2_car",
        Heli = "heli",
        Boat = "boat",
        Lasers = "C_Dentist_H_BigBank_Entrapment",
        Money = "equipment_plates",
        Phone = "pd2_phone",
        Keycard = "equipment_bank_manager_key",
        Power = "pd2_power",
        Drill = "pd2_drill",
        Alarm = "C_Bain_H_GOBank_IsEverythingOK",
        Water = "pd2_water_tap",
        Blimp = "blimp",
        Sentry = "wp_sentry",
        PCHack = "wp_hack",
        Glasscutter = "equipment_glasscutter",
        Loot = "pd2_loot",
        Goto = "pd2_goto",
        Pager = "pagers_used",
        Train = "C_Bain_H_TransportVarious_ButWait",
        LiquidNitrogen = "equipment_liquid_nitrogen_canister",

        EndlessAssault = { { icon = "padlock", color = Color(1, 0, 0) } },
        CarEscape = { "pd2_car", "pd2_escape", "pd2_lootdrop" },
        CarEscapeNoLoot = { "pd2_car", "pd2_escape" },
        CarWait = { "pd2_car", "pd2_escape", "pd2_lootdrop", "faster" },
        HeliEscape = { "heli", "pd2_escape", "pd2_lootdrop" },
        HeliEscapeNoLoot = { "heli", "pd2_escape" },
        HeliLootDrop = { "heli", "pd2_lootdrop" },
        HeliDropDrill = { "heli", "pd2_drill", "pd2_goto" },
        HeliDropBag = { "heli", "wp_bag", "pd2_goto" },
        HeliDropC4 = { "heli", "pd2_c4", "pd2_goto" },
        HeliWait = { "heli", "pd2_escape", "pd2_lootdrop", "faster" },
        BoatEscape = { "boat", "pd2_escape", "pd2_lootdrop" },
        BoatEscapeNoLoot = { "boat", "pd2_escape" }
    },

    WaypointIconRedirect =
    {
        heli = "EHI_Heli"
    },

    Trackers =
    {
        MallcrasherMoney = "EHIMoneyCounterTracker",
        Warning = "EHIWarningTracker",
        Pausable = "EHIPausableTracker",
        Chance = "EHIChanceTracker",
        Counter = "EHICountTracker",
        Progress = "EHIProgressTracker",
        NeededValue = "EHINeededValueTracker",
        Achievement = "EHIAchievementTracker",
        AchievementUnlock = "EHIAchievementUnlockTracker",
        AchievementStatus = "EHIAchievementStatusTracker",
        AchievementProgress = "EHIAchievementProgressTracker",
        AchievementBagValue = "EHIAchievementBagValueTracker",
        AssaultDelay = "EHIAssaultDelayTracker",
        ColoredCodes = "EHIColoredCodesTracker",
        Inaccurate = "EHIInaccurateTracker",
        InaccurateWarning = "EHIInaccurateWarningTracker",
        InaccuratePausable = "EHIInaccuratePausableTracker",
        Trophy = "EHITrophyTracker",
        Daily = "EHIDailyTracker",
        DailyProgress = "EHIDailyProgressTracker"
    },

    AchievementTrackers =
    {
        EHIAchievementTracker = true,
        EHIAchievementUnlockTracker = true,
        EHIAchievementProgressTracker = true,
        EHIAchievementStatusTracker = true,
        EHIAchievementBagValueTracker = true
    },

    TrophyTrackers =
    {
        EHITrophyTracker = true
    },

    DailyTrackers =
    {
        EHIDailyTracker = true,
        EHIDailyProgressTracker = true
    },

    Waypoints =
    {
        Warning = "EHIWarningWaypoint"
    },

    Difficulties =
    {
        Normal = 0,
        Hard = 1,
        VeryHard = 2,
        OVERKILL = 3,
        Mayhem = 4,
        DeathWish = 5,
        DeathSentence = 6
    },

    HostElement = "on_executed",
    ClientElement = "client_on_executed",

    ModVersion = ModInstance and tonumber(ModInstance:GetVersion()) or "N/A",
    ModPath = ModPath,
    LocPath = ModPath .. "loc/",
    LuaPath = ModPath .. "lua/",
    MenuPath = ModPath .. "menu/",
    SettingsSaveFilePath = BLTModManager.Constants:SavesDirectory() .. "ehi.json",
    SaveDataVer = 1
}
local SF = EHI.SpecialFunctions
EHI.SyncFunctions =
{
    [SF.GetElementTimerAccurate] = true,
    [SF.UnpauseTrackerIfExistsAccurate] = true
}
EHI.TriggerFunction =
{
    [SF.TriggerIfEnabled] = true,
    [SF.Trigger] = true
}

local function LoadDefaultValues(self)
    self.settings =
    {
        mod_language = 1, -- Auto (default)

        -- Menu Only
        show_preview_text = true,

        -- Common
        x_offset = 0,
        y_offset = 150,
        text_scale = 1,
        scale = 1,
        vr_scale = 1,
        time_format = 2, -- 1 = Seconds only, 2 = Minutes and seconds
        tracker_alignment = 1, -- 1 = Vertical, 2 = Horizontal

        -- Visuals
        show_tracker_bg = true,
        show_tracker_corners = true,
        show_one_icon = false,

        -- Trackers
        show_mission_trackers = true,
        show_unlockables = true,
        unlockables =
        {
            -- Achievements
            show_achievements = true,
            show_achievements_mission = true,
            hide_unlocked_achievements = true,
            show_achievements_weapon = true,
            show_achievements_melee = true,
            show_achievements_grenade = true,
            show_achievements_vehicle = true,
            show_achievements_other = true,
            show_achievement_failed_popup = true,
            show_achievement_started_popup = true,

            -- Trophies
            show_trophies = true,
            hide_unlocked_trophies = true,
            show_trophy_failed_popup = true,
            show_trophy_started_popup = true,

            -- Daily missions
            show_dailies = true,
            show_daily_failed_popup = true,
            show_daily_started_popup = true
        },
        show_gained_xp = true,
        show_xp_in_mission_briefing_only = false,
        xp_format = 3,
        xp_panel = 1,
        total_xp_show_difference = true,
        show_trade_delay = true,
        show_trade_delay_option = 1,
        show_trade_delay_other_players_only = true,
        show_trade_delay_suppress_in_stealth = true,
        show_timers = true,
        show_camera_loop = true,
        show_enemy_turret_trackers = true,
        show_zipline_timer = true,
        show_gage_tracker = true,
        gage_tracker_panel = 1,
        show_captain_damage_reduction = true,
        show_equipment_tracker = true,
        equipment_format = 1,
        show_equipment_doctorbag = true,
        show_equipment_ammobag = true,
        show_equipment_grenadecases = true,
        show_equipment_bodybags = true,
        show_equipment_firstaidkit = true,
        show_equipment_ecmjammer = true,
        ecmjammer_block_ecm_without_pager_delay = false,
        show_equipment_ecmfeedback = true,
        show_equipment_aggregate_health = true,
        show_equipment_aggregate_all = false,
        equipment_color =
        {
            doctor_bag =
            {
                r = 255,
                g = 0,
                b = 0
            },
            ammo_bag =
            {
                r = 255,
                g = 255,
                b = 0
            },
            grenade_crate =
            {
                r = 0,
                g = 255,
                b = 0
            },
            first_aid_kit =
            {
                r = 255,
                g = 102,
                b = 102
            },
            bodybags_bag =
            {
                r = 51,
                g = 204,
                b = 255
            }
        },
        show_minion_tracker = true,
        show_minion_per_player = true,
        show_minion_killed_message = true,
        show_minion_killed_message_type = 1, -- 1 = Popup; 2 = Hint
        show_difficulty_tracker = true,
        show_drama_tracker = true,
        show_pager_tracker = true,
        show_pager_callback = true,
        show_enemy_count_tracker = true,
        show_enemy_count_show_pagers = true,
        show_laser_tracker = false,
        show_assault_delay_tracker = true,
        show_loot_counter = true,
        show_all_loot_secured_popup = true,
        variable_random_loot_format = 3, -- 1 = Max-(Max+Random)?; 2 = MaxRandom?; 3 = Max+Random?
        show_bodybags_counter = true,
        show_escape_chance = true,

        -- Waypoints
        show_waypoints = true,
        show_waypoints_only = false,
        show_waypoints_present_timer = 2,
        show_waypoints_enemy_turret = true,
        show_waypoints_timers = true,
        show_waypoints_pager = true,
        show_waypoints_cameras = true,
        show_waypoints_zipline = true,
        show_waypoints_ecmjammer = true,

        -- Buffs
        show_buffs = true,
        buffs_x_offset = 0,
        buffs_y_offset = 80,
        buffs_alignment = 2, -- 1 = Left; 2 = Center; 3 = Right
        buffs_scale = 1,
        buffs_shape = 1, -- 1 = Square; 2 = Circle
        buffs_show_progress = true,
        buffs_invert_progress = false,
        buff_option =
        {
            -- Skills
            -- Mastermind
            inspire_basic = true,
            inspire_ace = true,
            uppers = true,
            uppers_range = true,
            uppers_range_refresh = 2, -- 1 / value
            quick_fix = true,
            painkillers = true,
            combat_medic = true,
            hostage_taker_muscle = true,
            forced_friendship = true,
            ammo_efficiency = true,
            aggressive_reload = true,
            -- Enforcer
            overkill = true,
            underdog = true,
            bullseye = true,
            bulletstorm = true,
            -- Ghost
            sixth_sense_initial = true,
            sixth_sense_marked = true,
            sixth_sense_refresh = true,
            dire_need = true,
            second_wind = true,
            unseen_strike = true,
            -- Fugitive
            running_from_death_reload = true,
            running_from_death_movement = true,
            up_you_go = true,
            swan_song = true,
            bloodthirst = true,
            bloodthirst_reload = true,
            bloodthirst_ratio = 34, -- value / 100
            berserker = true,
            berserker_refresh = 4, -- 1 / value

            -- Perks
            infiltrator = true,
            gambler = true,
            grinder = true,
            maniac = true,
            anarchist = true, -- +Armorer
            biker = true,
            kingpin = true,
            sicario = true,
            stoic = true,
            tag_team = true,
            hacker = true,
            leech = true,
            copycat = true,

            -- Other
            interact = true,
            reload = true,
            melee_charge = true,
            shield_regen = true,
            stamina = true,
            dodge = true,
            dodge_refresh = 1, -- 1 / value
            dodge_persistent = false,
            crit = true,
            crit_refresh = 1, -- 1 / value
            crit_persistent = false,
            inspire_ai = true,
            regen_throwable_ai = true
        },

        -- Inventory
        show_inventory_detailed_description = false,
        hide_original_desc = true,

        -- Other
        show_remaining_xp = true,
        show_remaining_xp_to_100 = false,
        show_mission_xp_overview = true
    }
end

local function Load()
    local self = EHI
    if self._cache.loaded then
        return
    end
    LoadDefaultValues(self)
    local file = io.open(self.SettingsSaveFilePath, "r")
    if file then
        local table
        local success, _ = pcall(function()
            table = json.decode(file:read("*all"))
        end)
        file:close()
        if success then
            if table.SaveDataVer and table.SaveDataVer == self.SaveDataVer then
                local function LoadValues(settings_table, file_table)
                    if settings_table == nil then
                        return
                    end
                    for k, v in pairs(file_table) do
                        if settings_table[k] ~= nil then
                            if type(v) == "table" then -- Load subtables in table and calls itself to load subtables or values in that subtable
                                LoadValues(settings_table[k], v)
                            else -- Load values to the table
                                settings_table[k] = v
                            end
                        end
                    end
                end
                LoadValues(self.settings, table)
            else
                self._cache.SaveDataNotCompatible = true
                self:Save()
            end
        else -- Save File got corrupted, use default values
            self._cache.SaveFileCorrupted = true
            self:Save() -- Resave the data
        end
    end
    self._cache.loaded = true
end

local function DifficultyToIndex(difficulty)
    local difficulties = {
        "easy", -- Leftover from PD:TH
        "normal",
        "hard",
        "overkill",
        "overkill_145",
        "easy_wish",
        "overkill_290",
        "sm_wish"
    }
    return table.index_of(difficulties, difficulty) - 2
end

function EHI:Init()
    local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
    self._cache.DifficultyIndex = DifficultyToIndex(difficulty)
    self:AddCallback(self.CallbackMessage.InitManagers, function(managers)
        local mutator = managers.mutators
        if mutator:can_mutators_be_active() then
            EHI._cache.UnlockablesAreDisabled = mutator:are_achievements_disabled()
        end
        local level = Global.game_settings.level_id
        if level == "Enemy_Spawner" or level == "enemy_spawner2" or level == "modders_devmap" then -- These 3 maps disable achievements
            EHI._cache.UnlockablesAreDisabled = true
        end
    end)
end

---@param difficulty number
function EHI:IsDifficultyOrAbove(difficulty)
    return difficulty <= self._cache.DifficultyIndex
end

---@param difficulty number
function EHI:IsDifficultyOrBelow(difficulty)
    return difficulty >= self._cache.DifficultyIndex
end

---@param difficulty number
function EHI:IsDifficulty(difficulty)
    return self._cache.DifficultyIndex == difficulty
end

---@param diff_1 number
---@param diff_2 number
function EHI:IsBetweenDifficulties(diff_1, diff_2)
    if diff_1 > diff_2 then
        diff_1 = diff_1 - diff_2
        diff_2 = diff_1 + diff_2
        diff_1 = diff_2 - diff_1
    end
    return self._cache.DifficultyIndex >= diff_1 and self._cache.DifficultyIndex <= diff_2
end

if Global.load_level then
    local function return_true()
        return true
    end
    local function return_false()
        return false
    end
    if Network:is_server() then
        EHI.IsHost = return_true
        EHI.IsClient = return_false
    else
        EHI.IsHost = return_false
        EHI.IsClient = return_true
    end
end

---@return boolean
function EHI:IsPlayingFromStart()
    return self:IsHost() or (self:IsClient() and not managers.statistics:is_dropin())
end

function EHI:Log(s)
    log("[EHI] " .. (s or "nil"))
end

---Works the same way as EHI:Log(), but the string is not saved on HDD
---@param s any
function EHI:LogFast(s)
    local prefix = os.date("%I:%M:%S %p")
    io.stdout:write(prefix .. " Lua: [EHI] " .. (s or "nil") .. "\n")
end

function EHI:LogTraceback()
    log("[EHI] " .. debug.traceback())
end

function EHI:Save()
    self.settings.SaveDataVer = self.SaveDataVer
    self.settings.ModVersion = self.ModVersion
    local file = io.open(self.SettingsSaveFilePath, "w+")
    if file then
        file:write(json.encode(self.settings) or "{}")
        file:close()
    end
end

---Delays execution of a function
---@param name string ID
---@param t number time
---@param func function
function EHI:DelayCall(name, t, func)
    DelayedCalls:Add(name, t, func)
end

function EHI:GetOption(option)
    if option then
        return self.settings[option]
    end
end

function EHI:ShowMissionAchievements()
    return self:GetUnlockableAndOption("show_achievements_mission") and self:GetUnlockableOption("show_achievements")
end

---@param id string Achievement ID
---@return boolean
function EHI:CanShowAchievement(id)
    if not self:ShowMissionAchievements() then
        return false
    end
    return self:IsAchievementLocked(id)
end

function EHI:GetUnlockableOption(option)
    if option then
        return self.settings.unlockables[option]
    end
end

function EHI:GetUnlockableAndOption(option)
    return self:GetOption("show_unlockables") and self:GetUnlockableOption(option)
end

function EHI:GetEquipmentOption(option)
    return self:GetOption("show_equipment_tracker") and self:GetOption(option)
end

function EHI:GetEquipmentColor(equipment)
    if equipment and self.settings.equipment_color[equipment] then
        return self:GetColor(self.settings.equipment_color[equipment])
    end
    return Color.white
end

function EHI:GetWaypointOption(waypoint)
    return self:GetOption("show_waypoints") and self:GetOption(waypoint)
end

function EHI:GetColor(color)
    if color and color.r and color.g and color.b then
        return Color(255, color.r, color.g, color.b) / 255
    end
    return Color.white
end

function EHI:GetBuffOption(option)
    if option then
        return self.settings.buff_option[option]
    end
end

function EHI:GetBuffAndOption(option)
    return self:GetOption("show_buffs") and self:GetBuffOption(option)
end

function EHI:MissionTrackersAndWaypointEnabled()
    return self:GetOption("show_mission_trackers") and self:GetOption("show_waypoints")
end

function EHI:IsXPTrackerDisabled()
    if not self:GetOption("show_gained_xp") or self:IsPlayingCrimeSpree() then
        return true
    end
    return false
end

function EHI:IsXPTrackerVisible()
    local result = not self:IsXPTrackerDisabled()
    return result and not self:GetOption("show_xp_in_mission_briefing_only")
end

function EHI:IsXPTrackerHidden()
    return not self:IsXPTrackerVisible()
end

function EHI:AreGagePackagesSpawned()
    return self._cache.GagePackages and self._cache.GagePackages > 0
end

function EHI:IsPlayingCrimeSpree()
    return Global.game_settings and Global.game_settings.gamemode and Global.game_settings.gamemode == "crime_spree"
end

function EHI:AssaultDelayTrackerIsEnabled()
    return self:GetOption("show_assault_delay_tracker") and not tweak_data.levels:IsLevelSkirmish()
end

function EHI:CombineAssaultDelayAndAssaultTime()
    return self:GetOption("show_assault_delay_tracker") and self:GetOption("show_assault_time_tracker") and self:GetOption("aggregate_assault_delay_and_assault_time")
end

---@param params table
function EHI:AddXPBreakdown(params)
    if self:IsXPTrackerDisabled() or not managers.menu_component then
        return
    end
    if not managers.menu_component._mission_briefing_gui then
        self:AddCallback("MissionBriefingGuiInit", function(gui)
            gui:AddXPBreakdown(params)
        end)
        return
    end
    managers.menu_component._mission_briefing_gui:AddXPBreakdown(params)
end

---@param id string|number
---@param f function
function EHI:AddCallback(id, f)
    self.Callback[id] = self.Callback[id] or {}
    self.Callback[id][#self.Callback[id] + 1] = f
end

---@param id string|number
---@param ... any
function EHI:CallCallback(id, ...)
    for _, callback in ipairs(self.Callback[id] or {}) do
        callback(...)
    end
end

---Calls all callbacks, after that they are deleted from memory
---@param id string|number
---@param ... any
function EHI:CallCallbackOnce(id, ...)
    self:CallCallback(id, ...)
    self.Callback[id] = nil
end

---@param f function
function EHI:AddOnAlarmCallback(f)
    self:AddCallback("Alarm", f)
end

---@param dropin boolean
function EHI:RunOnAlarmCallbacks(dropin)
    self:CallCallbackOnce("Alarm", dropin)
end

---@param f function
function EHI:AddOnCustodyCallback(f)
    self:AddCallback("Custody", f)
end

---@param custody_state boolean
function EHI:RunOnCustodyCallback(custody_state)
    self:CallCallback("Custody", custody_state)
end

---@param object table
---@param func string
---@param post_call function
function EHI:Hook(object, func, post_call)
    self:HookWithID(object, func, "EHI_" .. func, post_call)
end

---@param object table
---@param func string
---@param id string
---@param post_call function
function EHI:HookWithID(object, func, id, post_call)
    Hooks:PostHook(object, func, id, post_call)
end

---@param object table
---@param func string
---@param pre_call function
function EHI:PreHook(object, func, pre_call)
    self:PreHookWithID(object, func, "EHI_Pre_" .. func, pre_call)
end

---@param object table
---@param func string
---@param id string
---@param pre_call function
function EHI:PreHookWithID(object, func, id, pre_call)
    Hooks:PreHook(object, func, id, pre_call)
end

---@param object table
---@param func string
---@param id string
---@param post_call function
function EHI:HookElement(object, func, id, post_call)
    Hooks:PostHook(object, func, "EHI_Element_" .. id, post_call)
end

---@param id string
function EHI:Unhook(id)
    Hooks:RemovePostHook("EHI_" .. id)
end

---@param id number
function EHI:UnhookElement(id)
    Hooks:RemovePostHook("EHI_Element_" .. id)
end

---@return boolean
function EHI:ShowDramaTracker()
    return self:GetOption("show_drama_tracker") and self:IsHost()
end

---@param peer_id number
function EHI:GetPeerColorByPeerID(peer_id)
    local color = Color.white
    if peer_id then
        color = tweak_data.chat_colors[peer_id] or Color.white
    end
    return color
end

---@param id number
---@param start_index number
---@param continent_index number?
---@return number
function EHI:GetInstanceElementID(id, start_index, continent_index)
    if continent_index then
        return continent_index + math.mod(id, 100000) + 30000 + start_index
    end
    return id + 30000 + start_index
end

---@param id number
---@param start_index number
---@param continent_index number?
---@return number
function EHI:GetInstanceUnitID(id, start_index, continent_index)
    return self:GetInstanceElementID(id, start_index, continent_index)
end

---@param final_index number
---@param start_index number
---@param continent_index number
---@return number
function EHI:GetBaseUnitID(final_index, start_index, continent_index)
    return (final_index - 30000 - start_index - continent_index) + 100000
end

local math_floor = math.floor
function EHI:RoundNumber(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math_floor(n / bracket + sign * 0.5) * bracket
end

function EHI:RoundChanceNumber(n)
    return self:RoundNumber(n, 0.01) * 100
end

---@param id number Element ID
---@return Vector3|nil
function EHI:GetInstanceElementPosition(id)
    local element = managers.mission:get_element_by_id(id)
    if not element then
        return nil
    end
    return element:value("position")
end

---@param id number Unit ID
---@return Vector3|nil
function EHI:GetInstanceUnitPosition(id)
    local unit = managers.worlddefinition:get_unit(id)
    if not unit then
        return nil
    end
    if not unit.position then
        return nil
    end
    return unit:position()
end

function EHI:Sync(message, data)
    LuaNetworking:SendToPeersExcept(1, message, data or "")
end
if Global.game_settings and Global.game_settings.single_player then
    EHI.Sync = function(...) end
end

---@param triggers table
function EHI:SetSyncTriggers(triggers)
    if self._sync_triggers then
        for key, value in pairs(triggers) do
            if self._sync_triggers[key] then
                self:Log("key: " .. tostring(key) .. " already exists in sync!")
            else
                self._sync_triggers[key] = deep_clone(value)
            end
        end
    else
        self._sync_triggers = deep_clone(triggers)
    end
end

function EHI:AddSyncTrigger(id, trigger)
    self:SetSyncTriggers({ [id] = trigger })
end

function EHI:AddTrackerSynced(id, delay)
    if self._sync_triggers[id] then
        local trigger = self._sync_triggers[id]
        local trigger_id = trigger.id
        if managers.ehi:TrackerExists(trigger_id) then
            if trigger.delay_only then
                managers.ehi:SetTrackerAccurate(trigger_id, delay)
            else
                managers.ehi:SetTrackerAccurate(trigger_id, (trigger.time or 0) + delay)
            end
        else
            managers.ehi:AddTracker({
                id = trigger_id,
                time = trigger.delay_only and delay or ((trigger.time or 0) + delay),
                icons = trigger.icons,
                class = trigger.synced and trigger.synced.class or trigger.class
            })
        end
        if trigger.client_on_executed then
            -- Right now there is only SF.RemoveTriggerWhenExecuted
            self._sync_triggers[id] = nil
        end
    end
end

function EHI:DebugEquipment(tracker_id, unit, key, amount, peer_id)
    self:Log("Received garbage. Key is nil. Tracker ID: " .. tostring(tracker_id))
    self:Log("unit: " .. tostring(unit))
    if unit and alive(unit) then
        self:Log("unit:name(): " .. tostring(unit:name()))
        self:Log("unit:key(): " .. tostring(unit:key()))
    end
    self:Log("key: " .. tostring(key))
    self:Log("amount: " .. tostring(amount))
    if peer_id then
        self:Log("Peer ID: " .. tostring(peer_id))
    end
    self:Log(debug.traceback())
end

---@param level_id string
---@return boolean
function EHI:IsOneXPElementHeist(level_id)
    return table.contains({
            "four_stores",
            "nightclub",
            "jewelry_store",
            "ukrainian_job",
            "election_day_1",
            "election_day_2",
            "election_day_3",
            "election_day_3_skip1",
            "election_day_3_skip2",
            "alex_1",
            "alex_2",
            "alex_3",
            "firestarter_1",
            "firestarter_2",
            "firestarter_3",
            "branchbank",
            "branchbank_gold",
            "branchbank_cash",
            "branchbank_deposit",
            "haunted",
            "safehouse",
            "short1_stage1",
            "short1_stage2",
            "short2_stage1",
            "short2_stage2b",
            "arm_cro",
            "arm_fac",
            "arm_hcm",
            "arm_par",
            "arm_und",
            "escape_cafe",
            "escape_cafe_day",
            "escape_garage",
            "escape_overpass",
            "escape_overpass_night",
            "escape_park",
            "escape_park_day",
            "escape_street"
        }, level_id)
end

---@param id string
---@return table
function EHI:GetAchievementIcon(id)
    local achievement = tweak_data.achievement.visual[id]
    return achievement and { achievement.icon_id }
end

---@param id string
---@return string
function EHI:GetAchievementIconString(id)
    local achievement = tweak_data.achievement.visual[id]
    return achievement and achievement.icon_id
end

local triggers = {}
local host_triggers = {}
local base_delay_triggers = {}
local element_delay_triggers = {}
---Adds trigger to mission element when they run
---@param new_triggers table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:AddTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    for key, value in pairs(new_triggers) do
        if triggers[key] then
            self:Log("key: " .. tostring(key) .. " already exists in triggers!")
        else
            triggers[key] = value
            if not value.id then
                triggers[key].id = trigger_id_all
            end
            if not value.icons and not value.run then
                triggers[key].icons = trigger_icons_all
            end
        end
    end
end

---Adds trigger to mission element when they run. If trigger already exists, it is moved and added into table
---@param new_triggers table
---@param params table?
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:AddTriggers2(new_triggers, params, trigger_id_all, trigger_icons_all)
    local function FillRestOfProperties(key, value)
        if not value.id then
            triggers[key].id = trigger_id_all
        end
        if not value.icons and not value.run then
            triggers[key].icons = trigger_icons_all
        end
    end
    for key, value in pairs(new_triggers) do
        if triggers[key] then
            local t = triggers[key]
            if t.special_function and self.TriggerFunction[t.special_function] then
                if value.special_function and self.TriggerFunction[value.special_function] then
                    if t.data then
                        local data = value.data or {}
                        for i = 1, #data, 1 do
                            t.data[#t.data + 1] = data[i]
                        end
                    else
                        self:Log("key: " .. tostring(key) .. " does not have 'data' table, new triggers won't be added!")
                    end
                elseif t.data then
                    local new_key = (key * 10) + 1
                    while triggers[new_key] do
                        new_key = new_key + 1
                    end
                    triggers[new_key] = value
                    FillRestOfProperties(new_key, value)
                    t.data[#t.data + 1] = new_key
                else
                    self:Log("key: " .. tostring(key) .. " does not have 'data' table, the trigger " .. tostring(new_key) .. " will not be called!")
                end
            elseif value.special_function and self.TriggerFunction[value.special_function] then
                if value.data then
                    local new_key = (key * 10) + 1
                    while table.contains(value.data, new_key) or new_triggers[new_key] or triggers[new_key] do
                        new_key = new_key + 1
                    end
                    triggers[new_key] = t
                    triggers[key] = value
                    FillRestOfProperties(key, value)
                    value.data[#value.data + 1] = new_key
                else
                    self:Log("key: " .. tostring(key) .. " with ID: " .. tostring(value.id) .. " does not have 'data' table, the former trigger won't be moved and triggers assigned to this one will not be called!")
                end
            else
                local new_key = (key * 10) + 1
                local key2 = new_key + 1
                triggers[key] = { special_function = params and params.SF or SF.Trigger, data = { new_key, key2 } }
                triggers[new_key] = t
                triggers[key2] = value
                FillRestOfProperties(key2, value)
            end
        else
            triggers[key] = value
            FillRestOfProperties(key, value)
        end
    end
end

function EHI:AddHostTriggers(new_triggers, trigger_id_all, trigger_icons_all, type)
    for key, value in pairs(new_triggers) do
        if host_triggers[key] then
            self:Log("key: " .. tostring(key) .. " already exists in host triggers!")
        else
            host_triggers[key] = value
            if not value.id then
                host_triggers[key].id = trigger_id_all
            end
            if not value.icons then
                host_triggers[key].icons = trigger_icons_all
            end
        end
        if type == "base" then
            if base_delay_triggers[key] then
                self:Log("key: " .. tostring(key) .. " already exists in host base delay triggers!")
            else
                base_delay_triggers[key] = true
            end
        else
            if value.hook_element or value.hook_elements then
                if value.hook_element then
                    element_delay_triggers[value.hook_element] = element_delay_triggers[value.hook_element] or {}
                    element_delay_triggers[value.hook_element][key] = true
                else
                    for _, element in pairs(value.hook_elements) do
                        element_delay_triggers[element] = element_delay_triggers[element] or {}
                        element_delay_triggers[element][key] = true
                    end
                end
            else
                self:Log("key: " .. tostring(key) .. " does not have element to hook!")
            end
        end
    end
end

function EHI:AddWaypointToTrigger(id, waypoint)
    local t = triggers[id]
    if not t then
        return
    end
    local w = deep_clone(waypoint)
    if not w.time then
        w.time = t.time
    end
    if not w.icon then
        local icon = t.icons
        if icon and icon[1] then
            if type(icon[1]) == "table" then
                w.icon = icon[1].icon
            elseif type(icon[1]) == "string" then
                w.icon = icon[1]
            end
        end
    end
    t.waypoint = w
end


local E = EHI
---@param trigger table
local function AddTracker(trigger)
    trigger.time = E:GetTime(trigger)
    managers.ehi:AddTracker(trigger)
end

---@param trigger table
---@return number
function EHI:GetTime(trigger)
    local full_time = trigger.time or 0
    full_time = full_time + (trigger.random_time and math.rand(trigger.random_time) or 0)
    return full_time
end

---@param trigger table
function EHI:AddTrackerWithRandomTime(trigger)
    local time = trigger.data[math.random(#trigger.data)]
    trigger.time = time
    managers.ehi:AddTracker(trigger)
    if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
        trigger.waypoint_f(trigger)
    elseif trigger.waypoint then
        managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.waypoint)
    end
end

---@param trigger table
function EHI:AddTracker(trigger)
    if trigger.run then
        trigger.run.time = self:GetTime(trigger.run)
        managers.ehi:RunTracker(trigger.id, trigger.run)
    else
        AddTracker(trigger)
    end
    if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
        trigger.waypoint_f(trigger)
    elseif trigger.waypoint then
        managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.waypoint)
    end
end

---@param id number
---@param delay number
function EHI:AddTrackerAndSync(id, delay)
    local trigger = host_triggers[id]
    managers.ehi:AddTrackerAndSync({
        id = trigger.id,
        time = (trigger.time or 0) + (delay or 0),
        icons = trigger.icons,
        class = trigger.class
    }, id, delay)
    if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
        trigger.waypoint_f(trigger)
    elseif trigger.waypoint then
        managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.waypoint)
    end
end

---@param trigger table
function EHI:CheckCondition(trigger)
    if trigger.condition_function then
        if trigger.condition_function() then
            self:AddTracker(trigger)
        end
    else
        self:AddTracker(trigger)
    end
end

local function GetElementTimer(self, trigger, id)
    if self:IsHost() then
        local element = managers.mission:get_element_by_id(trigger.element)
        if element then
            local t = (element._timer or 0) + (trigger.additional_time or 0)
            trigger.time = t
            self:CheckCondition(trigger)
            managers.ehi:Sync(id, t)
        end
    else
        self:CheckCondition(trigger)
    end
end

---@param id number
function EHI:UnhookTrigger(id)
    self:UnhookElement(id)
    triggers[id] = nil
end

---@param id string
local function PauseTracker(id)
    managers.ehi:PauseTracker(id)
    managers.ehi_waypoint:PauseWaypoint(id)
end

---@param id string
local function UnpauseTracker(id)
    managers.ehi:UnpauseTracker(id)
    managers.ehi_waypoint:UnpauseWaypoint(id)
end

---@param id string
local function RemoveTracker(id)
    managers.ehi:ForceRemoveTracker(id)
    managers.ehi_waypoint:RemoveWaypoint(id)
end

---@param id string
local function HideTracker(id)
    managers.ehi:x()
    managers.ehi_waypoint:RemoveWaypoint(id)
end

---@param id number
---@param element table
---@param enabled boolean
---@overload fun(self, id: number)
---@overload fun(self, id: number, element: table)
function EHI:Trigger(id, element, enabled)
    local trigger = triggers[id]
    if trigger then
        if trigger.special_function then
            local f = trigger.special_function
            if f == SF.RemoveTracker then
                if trigger.data then
                    for _, tracker in ipairs(trigger.data) do
                        RemoveTracker(tracker)
                    end
                else
                    RemoveTracker(trigger.id)
                end
            elseif f == SF.PauseTracker then
                PauseTracker(trigger.id)
            elseif f == SF.UnpauseTracker then
                UnpauseTracker(trigger.id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.ehi:TrackerExists(trigger.id) then
                    UnpauseTracker(trigger.id)
                else
                    self:CheckCondition(trigger)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if managers.ehi:TrackerDoesNotExist(trigger.id) then
                    self:CheckCondition(trigger)
                end
            elseif f == SF.ReplaceTrackerWithTracker then
                RemoveTracker(trigger.data.id)
                self:CheckCondition(trigger)
            elseif f == SF.ShowAchievementFromStart then -- Achievement unlock is checked during level load
                if not managers.statistics:is_dropin() then
                    self:CheckCondition(trigger)
                end
            elseif f == SF.SetAchievementComplete then
                managers.ehi:SetAchievementComplete(trigger.id, true)
            elseif f == SF.SetAchievementStatus then
                managers.ehi:SetAchievementStatus(trigger.id, trigger.status or "ok")
            elseif f == SF.SetAchievementFailed then
                managers.ehi:SetAchievementFailed(trigger.id)
            elseif f == SF.IncreaseChance then
                managers.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.TriggerIfEnabled then
                if enabled then
                    if trigger.data then
                        for _, t in ipairs(trigger.data) do
                            self:Trigger(t, element, enabled)
                        end
                    else
                        self:Trigger(trigger.id, element, enabled)
                    end
                end
            elseif f == SF.CreateAnotherTrackerWithTracker then
                self:CheckCondition(trigger)
                self:Trigger(trigger.data.fake_id, element, enabled)
            elseif f == SF.SetChanceWhenTrackerExists then
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:SetChance(trigger.id, trigger.chance)
                else
                    self:CheckCondition(trigger)
                end
            elseif f == SF.Trigger then
                if trigger.data then
                    for _, t in ipairs(trigger.data) do
                        self:Trigger(t, element, enabled)
                    end
                else
                    self:Trigger(trigger.id, element, enabled)
                end
            elseif f == SF.RemoveTrigger then
                if trigger.data then
                    for _, trigger_id in ipairs(trigger.data) do
                        self:UnhookTrigger(trigger_id)
                    end
                else
                    self:UnhookTrigger(trigger.id)
                end
            elseif f == SF.SetTimeOrCreateTracker then
                local key = trigger.id
                if managers.ehi:TrackerExists(key) or managers.ehi_waypoint:WaypointExists(key) then
                    local time = trigger.run and trigger.run.time or trigger.time or 0
                    managers.ehi:SetTrackerTime(key, time)
                    managers.ehi_waypoint:SetWaypointTime(key, time)
                else
                    self:CheckCondition(trigger)
                end
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    self:CheckCondition(trigger)
                end
            elseif f == SF.SetTimeByPreplanning then
                if managers.preplanning:IsAssetBought(trigger.data.id) then
                    trigger.time = trigger.data.yes
                else
                    trigger.time = trigger.data.no
                end
                if trigger.waypoint then
                    trigger.waypoint.time = trigger.time
                end
                self:CheckCondition(trigger)
            elseif f == SF.IncreaseProgress then
                managers.ehi:IncreaseTrackerProgress(trigger.id)
            elseif f == SF.SetTrackerAccurate then
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:SetTrackerAccurate(trigger.id, trigger.time)
                else
                    self:CheckCondition(trigger)
                end
            elseif f == SF.SetRandomTime then
                if managers.ehi:TrackerDoesNotExist(trigger.id) then
                    self:AddTrackerWithRandomTime(trigger)
                end
            elseif f == SF.DecreaseChance then
                managers.ehi:DecreaseChance(trigger.id, trigger.amount)
            elseif f == SF.GetElementTimerAccurate then
                GetElementTimer(self, trigger, id)
            elseif f == SF.UnpauseOrSetTimeByPreplanning then
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:UnpauseTracker(trigger.id)
                else
                    if trigger.time then
                        self:CheckCondition(trigger)
                        return
                    end
                    if managers.preplanning:IsAssetBought(trigger.data.id) then
                        trigger.time = trigger.data.yes
                    else
                        trigger.time = trigger.data.no
                    end
                    self:CheckCondition(trigger)
                end
            elseif f == SF.UnpauseTrackerIfExistsAccurate then
                if managers.ehi:TrackerExists(trigger.id) then
                    UnpauseTracker(trigger.id)
                else
                    GetElementTimer(self, trigger, id)
                end
            elseif f == SF.FinalizeAchievement then
                managers.ehi:CallFunction(trigger.id, "Finalize")
            elseif f == SF.IncreaseChanceFromElement then
                managers.ehi:IncreaseChance(trigger.id, element._values.chance)
            elseif f == SF.DecreaseChanceFromElement then
                managers.ehi:DecreaseChance(trigger.id, element._values.chance)
            elseif f == SF.SetChanceFromElement then
                managers.ehi:SetChance(trigger.id, element._values.chance)
            elseif f == SF.SetChanceFromElementWhenTrackerExists then
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:SetChance(trigger.id, element._values.chance)
                else
                    trigger.chance = element._values.chance
                    self:CheckCondition(trigger)
                end
            elseif f == SF.PauseTrackerWithTime then
                local t_id = trigger.id
                local t_time = trigger.time
                PauseTracker(t_id)
                managers.ehi:SetTrackerTimeNoAnim(t_id, t_time)
                managers.ehi_waypoint:SetWaypointTime(t_id, t_time)
            elseif f == SF.IncreaseProgressMax then
                managers.ehi:IncreaseTrackerProgressMax(trigger.id, trigger.max)
            elseif f == SF.SetTimeIfLoudOrStealth then
                if managers.groupai then
                    if managers.groupai:state():whisper_mode() then -- Stealth
                        trigger.time = trigger.data.no
                    else -- Loud
                        trigger.time = trigger.data.yes
                    end
                    self:CheckCondition(trigger)
                end
            elseif f == SF.AddTimeByPreplanning then
                local t = 0
                if managers.preplanning:IsAssetBought(trigger.data.id) then
                    t = trigger.data.yes
                else
                    t = trigger.data.no
                end
                trigger.time = trigger.time + t
                self:CheckCondition(trigger)
            elseif f == SF.ShowWaypoint then
                managers.hud:add_waypoint(trigger.id, trigger.data)
            elseif f == SF.ShowEHIWaypoint then
                managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.waypoint)
            elseif f == SF.DecreaseProgressMax then
                managers.ehi:DecreaseTrackerProgressMax(trigger.id, trigger.max)
            elseif f == SF.DecreaseProgress then
                managers.ehi:DecreaseTrackerProgress(trigger.id, trigger.progress)
            elseif f == SF.Debug then
                managers.hud:Debug(id)
            elseif f == SF.CustomCode then
                trigger.f(trigger.arg)
            elseif f == SF.CustomCodeIfEnabled then
                if enabled then
                    trigger.f(trigger.arg)
                end
            elseif f == SF.CustomCodeDelayed then
                self:DelayCall(tostring(id), trigger.t or 0, trigger.f)

            elseif f >= SF.CustomSF then
                self.SFF[f](trigger, element, enabled)
            end
        else
            self:CheckCondition(trigger)
        end
        if trigger.trigger_times and trigger.trigger_times > 0 then
            trigger.trigger_times = trigger.trigger_times - 1
            if trigger.trigger_times == 0 then
                self:UnhookTrigger(id)
            end
        end
    end
end

---Provided function should accept these parameters in this order: "trigger", "element", "enabled"
---@param id number
---@param f function
function EHI:RegisterCustomSpecialFunction(id, f)
    self.SFF[id] = f
end

---Unregisters custom special function
---@param id number
function EHI:UnregisterCustomSpecialFunction(id)
    self.SFF[id] = nil
end

function EHI:GetFreeCustomSpecialFunctionID()
    local id = (self._cache.SFFUsed or self.SpecialFunctions.CustomSF) + 1
    self._cache.SFFUsed = id
    return id
end

function EHI:InitElements()
    self:HookElements(triggers)
    if self:IsClient() then
        return
    end
    local scripts = managers.mission._scripts or {}
    for id, _ in pairs(base_delay_triggers) do
        for _, script in pairs(scripts) do
            local element = script:element(id)
            if element then
                self._base_delay[id] = element._calc_base_delay
                element._calc_base_delay = function(e, ...)
                    local delay = self._base_delay[e._id](e, ...)
                    self:AddTrackerAndSync(e._id, delay)
                    return delay
                end
            end
        end
    end
    for id, _ in pairs(element_delay_triggers) do
        for _, script in pairs(scripts) do
            local element = script:element(id)
            if element then
                self._element_delay[id] = element._calc_element_delay
                element._calc_element_delay = function(e, params, ...)
                    local delay = self._element_delay[e._id](e, params, ...)
                    if element_delay_triggers[e._id][params.id] then
                        if host_triggers[params.id] then
                            local trigger = host_triggers[params.id]
                            if trigger.remove_trigger_when_executed then
                                self:AddTrackerAndSync(params.id, delay)
                                element_delay_triggers[e._id][params.id] = nil
                            elseif trigger.set_time_when_tracker_exists then
                                if managers.ehi:TrackerExists(trigger.id) then
                                    managers.ehi:SetTrackerTimeNoAnim(trigger.id, delay)
                                    self:Sync(self.SyncMessages.EHISyncAddTracker, LuaNetworking:TableToString({ id = id, delay = delay or 0 }))
                                else
                                    self:AddTrackerAndSync(params.id, delay)
                                end
                            else
                                self:AddTrackerAndSync(params.id, delay)
                            end
                        else
                            self:AddTrackerAndSync(params.id, delay)
                        end
                    end
                    return delay
                end
            end
        end
    end
end

function EHI:HookElements(elements_to_hook)
    local function Client(element, ...)
        self:Trigger(element._id, element, true)
    end
    local function Host(element, ...)
        self:Trigger(element._id, element, element._values.enabled)
    end
    local client = self:IsClient()
    local func = client and self.ClientElement or self.HostElement
    local f = client and Client or Host
    local scripts = managers.mission._scripts or {}
    for id, _ in pairs(elements_to_hook) do
        if id >= 100000 and id <= 999999 then
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self:HookElement(element, func, id, f)
                elseif client then
                    --[[
                        On client, the element was not found
                        This is because the element is from an instance that is mission placed
                        Mission Placed instances are preloaded and all elements are not cached until
                        ElementInstancePoint is called
                        These instances are synced when you join
                        Delay the hook until the sync is complete (see: EHI:SyncLoad())
                    ]]
                    self.HookOnLoad[id] = true
                end
            end
        end
    end
end

function EHI:SyncLoad()
    for id, _ in pairs(self.HookOnLoad) do
        local trigger = triggers[id]
        if trigger then
            if trigger.special_function == SF.ShowWaypoint and trigger.data then
                if trigger.data.position_by_element then
                    trigger.id = trigger.id or trigger.data.position_by_element
                    self:AddPositionFromElement(trigger.data, trigger.id, true)
                elseif trigger.data.position_by_unit then
                    self:AddPositionFromUnit(trigger.data, trigger.id, true)
                end
            elseif trigger.waypoint then
                if trigger.waypoint.position_by_element then
                    self:AddPositionFromElement(trigger.waypoint, trigger.id, true)
                elseif trigger.waypoint.position_by_unit then
                    self:AddPositionFromUnit(trigger.waypoint, trigger.id, true)
                end
            end
        end
    end
    self:HookElements(self.HookOnLoad)
    self.HookOnLoad = nil
    self:DisableWaypoints(self.DisableOnLoad)
    self:DisableWaypointsOnInit()
    self.DisableOnLoad = nil
end

---@param params table
---@return table|nil
function EHI:AddAssaultDelay(params)
    if not self:GetOption("show_assault_delay_tracker") then
        return nil
    end
    local id = "AssaultDelay"
    local class = self.Trackers.AssaultDelay
    if self:CombineAssaultDelayAndAssaultTime() then
        id = "Assault"
        class = "EHIAssaultTracker"
    end
    local tbl = {}
    -- Copy every passed value to the trigger
    for key, value in pairs(params) do
        tbl[key] = value
    end
    tbl.time = tbl.time or 30
    tbl.id = id
    tbl.class = class
    return tbl
end

---@param f function Loot counter function
---@param check any? Boolean value of option 'show_loot_counter'
---@param trigger_once boolean? Should the trigger run once?
---@return table|nil
function EHI:AddLootCounter(f, check, trigger_once)
    if self:IsPlayingCrimeSpree() then
        return nil
    elseif check ~= nil and check == false then
        return nil
    elseif not self:GetOption("show_loot_counter") then
        return nil
    end
    local tbl = {}
    tbl.special_function = SF.CustomCode
    if trigger_once then
        tbl.trigger_times = 1
    end
    tbl.f = f
    return tbl
end

function EHI:AddPositionFromElement(data, id, check)
    local vector = self:GetInstanceElementPosition(data.position_by_element)
    if vector then
        data.position = vector
        data.position_by_element = nil
    elseif check then
        self:Log("Element with ID " .. tostring(data.position_by_element) .. " has not been found. Element ID to hook: " .. tostring(id))
    end
end

function EHI:AddPositionFromUnit(data, id, check)
    local vector = self:GetInstanceUnitPosition(data.position_by_unit)
    if vector then
        data.position = vector
        data.position_by_unit = nil
    elseif check then
        self:Log("Unit with ID " .. tostring(data.position_by_unit) .. " has not been found. Element ID to hook: " .. tostring(id))
    end
end

---@param achievements table Table with achievements
---@param package string Beardlib package where achievements are stored
---@param exclude table? If the achievement table contains vanilla achievements, provide their ID so they don't get marked as from Beardlib
function EHI:PreparseBeardlibAchievements(achievements, package, exclude)
    exclude = exclude or {}
    for id, data in pairs(achievements or {}) do
        if not exclude[id] then
            data.beardlib = true
            data.package = package
        end
    end
end

---@param new_triggers table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:ParseTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    new_triggers = new_triggers or {}
    self:PreloadTrackers(new_triggers.preload or {}, trigger_id_all or "Trigger", trigger_icons_all or {})
    local function ParseParams(data, id)
        if type(data.alarm_callback) == "function" then
            self:AddOnAlarmCallback(data.alarm_callback)
        end
        if type(data.load_sync) == "function" then
            self:AddLoadSyncFunction(data.load_sync)
        end
        if data.failed_on_alarm then
            self:AddOnAlarmCallback(function()
                managers.ehi:SetAchievementFailed(id)
            end)
        end
        if data.mission_end_callback then
            self:AddCallback(self.CallbackMessage.MissionEnd, function(success)
                if success then
                    managers.ehi:SetAchievementComplete(id, true)
                else
                    managers.ehi:SetAchievementFailed(id)
                end
            end)
        end
    end
    self:ParseOtherTriggers(new_triggers.other or {}, trigger_id_all or "Trigger", trigger_icons_all)
    local trophy = new_triggers.trophy
    if self:GetUnlockableAndOption("show_trophies") and trophy and next(trophy) then
        for id, data in pairs(trophy) do
            if data.difficulty_pass ~= false and self:IsTrophyLocked(id) then
                for _, element in pairs(data.elements or {}) do
                    if element.class and self.TrophyTrackers[element.class] and not data.icons then
                        data.icons = { self.Icons.Trophy }
                    end
                end
                self:AddTriggers2(data.elements or {}, nil, id)
                ParseParams(data, id)
            end
        end
    end
    local daily = new_triggers.daily
    if self:GetUnlockableAndOption("show_dailies") and daily and next(daily) then
        for id, data in pairs(daily) do
            if data.difficulty_pass ~= false and self:IsDailyAvailable(id) then
                for _, element in pairs(data.elements or {}) do
                    if element.class and self.DailyTrackers[element.class] and not data.icons then
                        data.icons = { self.Icons.Trophy }
                    end
                end
                self:AddTriggers2(data.elements or {}, nil, id)
                ParseParams(data, id)
            end
        end
    end
    local achievement_triggers = new_triggers.achievement
    if self:ShowMissionAchievements() and achievement_triggers and next(achievement_triggers) then
        local function Parser(data, id)
            for _, element in pairs(data.elements or {}) do
                if element.class and self.AchievementTrackers[element.class] then
                    element.beardlib = data.beardlib
                    if not element.icons then
                        if data.beardlib then
                            element.icons = { "ehi_" .. id }
                        else
                            element.icons = self:GetAchievementIcon(id)
                        end
                    end
                end
            end
            self:AddTriggers2(data.elements or {}, nil, id)
            ParseParams(data, id)
        end
        local function IsAchievementLocked(data, id)
            if data.beardlib then
                return not self:IsBeardLibAchievementUnlocked(data.package, id)
            else
                return self:IsAchievementLocked(id)
            end
        end
        for id, data in pairs(achievement_triggers) do
            if data.difficulty_pass ~= false and IsAchievementLocked(data, id) then
                Parser(data, id)
            elseif type(data.cleanup_callback) == "function" then
                data.cleanup_callback()
            end
        end
    end
    self:ParseMissionTriggers(new_triggers.mission or {}, trigger_id_all, trigger_icons_all)
    --self:PrintTable(triggers)
end

function EHI:ParseOtherTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    for id, data in pairs(new_triggers) do
        -- Don't bother with trackers that have "condition" set to false, they will never run and just occupy memory for no reason
        if data.condition == false then
            new_triggers[id] = nil
        end
    end
    self:AddTriggers(new_triggers, trigger_id_all or "Trigger", trigger_icons_all)
end

function EHI:ParseMissionTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    if not self:GetOption("show_mission_trackers") then
        for id, data in pairs(new_triggers) do
            if data.special_function and self.SyncFunctions[data.special_function] then
                self:AddTriggers2({ [id] = data }, nil, trigger_id_all or "Trigger", trigger_icons_all)
            end
        end
        return
    end
    local host = self:IsHost()
    for id, data in pairs(new_triggers) do
        -- Don't bother with trackers that have "condition" set to false, they will never run and just occupy memory for no reason
        if data.condition == false then
            new_triggers[id] = nil
        else
            data.condition = nil
            -- Mark every tracker, that has random time, as inaccurate
            if data.random_time then
                if not data.class then
                    data.class = self.Trackers.Inaccurate
                elseif data.class ~= self.Trackers.InaccuratePausable and data.class == self.Trackers.Warning then
                    data.class = self.Trackers.InaccurateWarning
                end
            end
            -- Fill the rest table properties for Waypoints (Vanilla settings in ElementWaypoint)
            if data.special_function == SF.ShowWaypoint then
                data.data.distance = true
                data.data.state = "sneak_present"
                data.data.present_timer = 0
                data.data.no_sync = true -- Don't sync them to others. They may get confused and report it as a bug :p
                if data.data.position_by_element then
                    data.id = data.id or data.data.position_by_element
                    self:AddPositionFromElement(data.data, data.id, host)
                elseif data.data.position_by_unit then
                    self:AddPositionFromUnit(data.data, data.id, host)
                end
                if data.data.icon then
                    data.data.icon = self.WaypointIconRedirect[data.data.icon] or data.data.icon
                end
                if not data.data.position then
                    data.data.position = Vector3()
                    self:Log("Waypoint in element with ID '" .. tostring(data.id) .. "' does not have valid waypoint position! Setting it to default vector to avoid crashing")
                end
            end
            -- Fill the rest table properties for EHI Waypoints
            if data.waypoint then
                data.waypoint.time = data.waypoint.time or data.time
                if not data.waypoint.icon then
                    local icon
                    if data.icons then
                        icon = data.icons[1] and data.icons[1].icon or data.icons[1]
                    elseif trigger_icons_all then
                        icon = trigger_icons_all[1] and trigger_icons_all[1].icon or trigger_icons_all[1]
                    end
                    if icon then
                        data.waypoint.icon = self.WaypointIconRedirect[icon] or icon
                    end
                end
                if data.waypoint.position_by_element then
                    self:AddPositionFromElement(data.waypoint, data.id, host)
                elseif data.waypoint.position_by_unit then
                    self:AddPositionFromUnit(data.waypoint, data.id, host)
                end
                if not data.waypoint.position then
                    data.waypoint.position = Vector3()
                    self:Log("Waypoint in element with ID '" .. tostring(data.id) .. "' does not have valid waypoint position! Setting it to default vector to avoid crashing")
                end
            end
        end
    end
    self:AddTriggers2(new_triggers, nil, trigger_id_all or "Trigger", trigger_icons_all)
end

---@param preload table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:PreloadTrackers(preload, trigger_id_all, trigger_icons_all)
    for _, params in ipairs(preload) do
        params.id = params.id or trigger_id_all
        params.icons = params.icons or trigger_icons_all
        managers.ehi:PreloadTracker(params)
    end
end

function EHI:ShouldDisableWaypoints()
    return self:GetOption("show_timers") and self:GetWaypointOption("show_waypoints_timers")
end

local function HostWaypoint(self, instigator, ...)
    if not self._values.enabled then
        return
    end
    if self._values.only_on_instigator and instigator ~= managers.player:player_unit() then
        ElementWaypoint.super.on_executed(self, instigator, ...)
        return
    end
    if not self._values.only_in_civilian or managers.player:current_state() == "civilian" then
        local text = managers.localization:text(self._values.text_id)
        managers.hud:AddWaypointSoft(self._id, {
            distance = true,
            state = "sneak_present",
            present_timer = 0,
            text = text,
            icon = self._values.icon,
            position = self._values.position
        })
    elseif managers.hud:get_waypoint_data(self._id) then
        managers.hud:remove_waypoint(self._id)
    end
    ElementWaypoint.super.on_executed(self, instigator, ...)
end
function EHI:DisableElementWaypoint(id)
    local element = managers.mission:get_element_by_id(id)
    if not element or self._cache.ElementWaypointFunction[id] then
        return
    end
    if self:IsHost() then
        self._cache.ElementWaypointFunction[id] = element.on_executed
        element.on_executed = HostWaypoint
    else
        self._cache.ElementWaypointFunction[id] = element.client_on_executed
        element.client_on_executed = function(...) end
    end
end

---@param id number
function EHI:RestoreElementWaypoint(id)
    local element = managers.mission:get_element_by_id(id)
    if not (element and self._cache.ElementWaypointFunction[id]) then
        return
    end
    if self:IsHost() then
        element.on_executed = self._cache.ElementWaypointFunction[id]
    else
        element.client_on_executed = self._cache.ElementWaypointFunction[id]
    end
    self._cache.ElementWaypointFunction[id] = nil
end

---@param waypoints table|nil
function EHI:DisableWaypoints(waypoints)
    if not self:ShouldDisableWaypoints() or waypoints == nil then
        return
    end
    if self.DisableOnLoad then
        for id, _ in pairs(waypoints) do
            self.DisableOnLoad[id] = true
        end
    else
        self.DisableOnLoad = waypoints
    end
    for id, _ in pairs(waypoints) do
        self._cache.IgnoreWaypoints[id] = true
    end
end

function EHI:DisableWaypointsOnInit()
    for id, _ in pairs(self.DisableOnLoad or {}) do
        self:DisableElementWaypoint(id)
    end
end

-- Used on clients when offset is required
-- Do not call it directly!
function EHI:ShowLootCounterOffset(params, manager)
    params.offset = nil
    params.n_offset = managers.loot:GetSecuredBagsAmount()
    self:ShowLootCounterNoCheck(params)
end

---@param params table
function EHI:ShowLootCounter(params)
    if not self:GetOption("show_loot_counter") then
        return
    end
    self:ShowLootCounterNoCheck(params)
end

---@param params table
function EHI:ShowLootCounterNoCheck(params)
    if self:IsPlayingCrimeSpree() then
        return
    end
    local n_offset = params.n_offset or 0
    if params.offset then
        if self:IsHost() or params.client_from_start then
            n_offset = managers.loot:GetSecuredBagsAmount()
        else
            managers.ehi:AddFullSyncFunction(callback(self, self, "ShowLootCounterOffset", params))
            return
        end
    end
    managers.ehi:ShowLootCounter(params.max, params.additional_loot, params.max_random, n_offset)
    if params.load_sync then
        self:AddLoadSyncFunction(params.load_sync)
        params.no_sync_load = true
    end
    if params.triggers then
        self:AddTriggers2(params.triggers, nil, "LootCounter")
        if params.hook_triggers then
            self:HookElements(params.triggers)
        end
    end
    if params.sequence_triggers then
        local function IncreaseMax(...)
            managers.ehi:CallFunction("LootCounter", "RandomLootSpawned")
        end
        local function DecreaseRandom(...)
            managers.ehi:CallFunction("LootCounter", "RandomLootDeclined")
        end
        for unit_id, sequences in pairs(params.sequence_triggers) do
            for _, sequence in ipairs(sequences.loot or {}) do
                managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, IncreaseMax)
            end
            for _, sequence in ipairs(sequences.no_loot or {}) do
                managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, DecreaseRandom)
            end
        end
    end
    if params.no_counting then
        return
    end
    self:HookLootCounter(params.no_sync_load)
end

function EHI:HookLootCounter(no_sync_load)
    if not self._cache.LootCounter then
        local function Callback(self)
            self:EHIReportProgress("LootCounter", EHI.LootCounter.CheckType.BagsOnly)
        end
        self:AddCallback(self.CallbackMessage.LootSecured, Callback)
        -- If sync load is disabled, the counter needs to be updated via EHIManager:AddLoadSyncFunction() to properly show number of secured loot
        -- Usually done in heists which have additional loot that spawns depending on random chance; example: Red Diamond in Diamond Heist (Classic)
        if not no_sync_load then
            self:AddCallback(self.CallbackMessage.LootLoadSync, Callback)
        end
        self._cache.LootCounter = true
    end
end

local show_achievement = false
---@param params table
function EHI:ShowAchievementLootCounter(params)
    if self._cache.UnlockablesAreDisabled or not show_achievement or self:IsAchievementUnlocked(params.achievement) then
        if params.show_loot_counter then
            self:ShowLootCounter({ max = params.max, additional_loot = params.additional_loot })
        end
        return
    end
    managers.ehi:AddAchievementProgressTracker(params.achievement, params.max, 0, params.remove_after_reaching_target)
    if params.load_sync then
        self:AddLoadSyncFunction(params.load_sync)
    end
    if params.alarm_callback then
        self:AddOnAlarmCallback(params.alarm_callback)
    end
    if params.failed_on_alarm then
        self:AddOnAlarmCallback(function()
            managers.ehi:SetAchievementFailed(params.achievement)
        end)
    end
    if params.triggers then
        self:AddTriggers2(params.triggers, nil, params.achievement)
        if params.hook_triggers then
            self:HookElements(params.triggers)
        end
        if params.add_to_counter then
            self:AddAchievementToCounter(params)
        end
        return
    elseif params.no_counting then
        return
    end
    self:AddAchievementToCounter(params)
end

function EHI:ShowAchievementBagValueCounter(params)
    if self._cache.UnlockablesAreDisabled or not show_achievement or self:IsAchievementUnlocked(params.achievement) then
        return
    end
    managers.ehi:AddAchievementBagValueCounter(params.achievement, params.value, params.remove_after_reaching_target)
    self:AddAchievementToCounter(params)
end

function EHI:AddAchievementToCounter(params)
    local check_type = params.counter and params.counter.check_type or self.LootCounter.CheckType.BagsOnly
    local loot_type = params.counter and params.counter.loot_type
    local f = params.counter and params.counter.f
    local function Callback(self)
        self:EHIReportProgress(params.achievement, check_type, loot_type, f)
    end
    self:AddCallback(self.CallbackMessage.LootSecured, Callback)
end

---@param id string Achievement ID
---@param id_stat string Achievement Counter
---@param achievement_option string? Achievement option
function EHI:ShowAchievementKillCounter(id, id_stat, achievement_option)
    if (achievement_option and not self:GetUnlockableAndOption(achievement_option)) or not show_achievement then
        return
    end
    if self._cache.UnlockablesAreDisabled or self:IsAchievementUnlocked2(id) then
        return
    end
    local tweak_data = tweak_data.achievement.persistent_stat_unlocks[id_stat]
    if not tweak_data then
        self:Log("No statistics found for achievement " .. tostring(id) .. "; Stat: " .. tostring(id_stat))
        return
    end
    local progress = self:GetAchievementProgress(id_stat)
    local max = tweak_data[1] and tweak_data[1].at or 0
    if progress >= max then
        return
    end
    managers.ehi:AddAchievementKillCounter(id, progress, max)
    self.KillCounter = self.KillCounter or {}
    self.KillCounter[id_stat] = id
    if not self.KillCounterHook then
        EHI:HookWithID(AchievmentManager, "award_progress", "EHI_award_progress_KillCounter", function(am, stat, value)
            local s = EHI.KillCounter[stat]
            if s then
                managers.ehi:IncreaseTrackerProgress(s, value)
            end
        end)
        self.KillCounterHook = true
    end
end

---@param f function
function EHI:AddLoadSyncFunction(f)
    if self:IsHost() then
        return
    end
    managers.ehi:AddLoadSyncFunction(f)
end

---@param tbl table
function EHI:UpdateUnits(tbl)
    if not self:GetOption("show_timers") then
        return
    end
    self:UpdateUnitsNoCheck(tbl)
end

function EHI:UpdateUnitsNoCheck(tbl)
    self:FinalizeUnits(tbl)
    for id, data in pairs(tbl) do
        self._cache.MissionUnits[id] = data
    end
end

---@param tbl table
---@param instance_start_index number
---@param instance_continent_index? number
function EHI:UpdateInstanceUnits(tbl, instance_start_index, instance_continent_index)
    if not self:GetOption("show_timers") then
        return
    end
    self:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
end

---@param tbl table
---@param instance_start_index number
---@param instance_continent_index? number
function EHI:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
    local new_tbl = {}
    instance_continent_index = instance_continent_index or 100000
    for id, data in pairs(tbl) do
        local computed_id = self:GetInstanceElementID(id, instance_start_index, instance_continent_index)
        new_tbl[computed_id] = deep_clone(data)
        if new_tbl[computed_id].remove_vanilla_waypoint then
            new_tbl[computed_id].waypoint_id = self:GetInstanceElementID(new_tbl[computed_id].waypoint_id, instance_start_index, instance_continent_index)
        end
        new_tbl[computed_id].base_index = id
    end
    self:FinalizeUnits(new_tbl)
    for id, data in pairs(new_tbl) do
        self._cache.InstanceUnits[id] = data
    end
end

---@param pos table
---@param index table
function EHI:SetMissionDoorPosAndIndex(pos, index)
    if TimerGui.SetMissionDoorPosAndIndex then
        TimerGui.SetMissionDoorPosAndIndex(pos, index)
    end
end

---@param hook string
function EHI:CheckLoadHook(hook)
    if not Global.load_level then
        return true
    end
    if self._hooks[hook] then
        return true
    end
    self._hooks[hook] = true
    return false
end

---@param hook string
function EHI:CheckHook(hook)
    if self._hooks[hook] then
        return true
    end
    self._hooks[hook] = true
    return false
end

---Returns default keypad time reset for the current difficulty
---@param time_override table? Overrides default keypad time reset for each difficulty
---@return integer
function EHI:GetKeypadResetTimer(time_override)
    time_override = time_override or {}
    if self:IsDifficulty(self.Difficulties.Normal) then
        return time_override.normal or 5
    elseif self:IsDifficulty(self.Difficulties.Hard) then
        return time_override.hard or 15
    elseif self:IsDifficulty(self.Difficulties.VeryHard) then
        return time_override.veryhard or 15
    elseif self:IsDifficulty(self.Difficulties.OVERKILL) then
        return time_override.overkill or 20
    elseif self:IsDifficulty(self.Difficulties.Mayhem) then
        return time_override.mayhem or 30
    elseif self:IsDifficulty(self.Difficulties.DeathWish) then
        return time_override.deathwish or 30
    else
        return time_override.deathsentence or 40
    end
end

---@param trigger table
---@param params table|nil
---@return table
function EHI:ClientCopyTrigger(trigger, params)
    local tbl = {}
    if trigger.waypoint then
        tbl.waypoint = deep_clone(trigger.waypoint)
    end
    for key, value in pairs(params or {}) do
        tbl[key] = value
    end
    for key, value in pairs(trigger) do
        tbl[key] = tbl[key] or value
    end
    tbl.special_function = SF.AddTrackerIfDoesNotExist
    return tbl
end

Load()
show_achievement = EHI:ShowMissionAchievements()

if EHI:GetWaypointOption("show_waypoints_only") then
    ---@param trigger table
    function EHI:AddTracker(trigger)
        if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
            if not trigger.run then
                trigger.time = self:GetTime(trigger)
            end
            trigger.waypoint_f(trigger)
        elseif trigger.waypoint then
            trigger.waypoint.time = self:GetTime(trigger)
            managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.waypoint)
        else
            AddTracker(trigger)
        end
    end
end

if not EHI:GetOption("show_mission_trackers") then
    function EHI:AddTrackerAndSync(id, delay)
        managers.ehi:Sync(id, delay)
    end

    GetElementTimer = function(self, trigger, id)
        if self:IsHost() then
            local element = managers.mission:get_element_by_id(trigger.element)
            if element then
                local t = (element._timer or 0) + (trigger.additional_time or 0)
                managers.ehi:Sync(id, t)
            end
        end
    end
end

if EHI:GetUnlockableOption("hide_unlocked_achievements") then
    local G = Global
    function EHI:IsAchievementUnlocked(achievement)
        local a = G.achievment_manager.achievments[achievement]
        return a and a.awarded
    end
    function EHI:IsBeardLibAchievementUnlocked(package_id, achievement_id)
        return not self:IsBeardLibAchievementLocked(package_id, achievement_id)
    end
else -- Always show trackers for achievements
    function EHI:IsAchievementUnlocked(achievement)
        return false
    end
    function EHI:IsBeardLibAchievementUnlocked(package_id, achievement_id)
        self:IsBeardLibAchievementLocked(package_id, achievement_id, true)
        return false
    end
end

if EHI:GetUnlockableOption("hide_unlocked_trophies") then
    function EHI:IsTrophyUnlocked(trophy)
        return managers.custom_safehouse:is_trophy_unlocked(trophy)
    end
else
    function EHI:IsTrophyUnlocked(trophy)
        return false
    end
end

function EHI:IsDailyAvailable(daily, skip_unlockables_check)
    local current_daily = managers.custom_safehouse:get_daily_challenge()
    if current_daily and current_daily.id == daily then
        if current_daily.state == "completed" or current_daily.state == "rewarded" then
            return false
        end
        if skip_unlockables_check then
            return true
        end
        return not self._cache.UnlockablesAreDisabled
    end
    return false
end

function EHI:IsDailyMissionAvailable(challenge)
    if managers.challenge:has_active_challenges(challenge) then
        local c = managers.challenge:get_active_challenge(challenge)
        if c.completed or c.rewarded then
            return false
        end
        return true
    end
    return false
end
--[[function EHI:PrintAllDailyActiveChallenges()
    self:PrintTable(managers.challenge:get_all_active_challenges())
end
EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
    EHI:PrintAllDailyActiveChallenges()
end)]]

function EHI:IsTrophyLocked(trophy)
    return not self:IsTrophyUnlocked(trophy) and not self._cache.UnlockablesAreDisabled
end

function EHI:IsAchievementLocked(achievement)
    return not self:IsAchievementUnlocked(achievement) and not self._cache.UnlockablesAreDisabled
end

function EHI:IsBeardLibAchievementLocked(package_id, achievement_id, skip_check)
    local Achievement = CustomAchievementPackage:new(package_id):Achievement(achievement_id)
    if not Achievement then
        return false
    end
    if Achievement:IsUnlocked() and not skip_check then
        return false
    end
    self._cache[achievement_id] = Achievement:GetName()
    tweak_data.hud_icons["ehi_" .. achievement_id] = { texture = Achievement:GetIcon() }
    return true
end

function EHI:GetAchievementProgress(achievement)
    return managers.achievment:get_stat(achievement) or 0
end

-- Used for achievements that has in the description "Kill X enemies in an heist" and etc... to show them only once
-- This is done to prevent tracker spam if the player decides to replay the same heist with a similar weapon or weapon category
-- Once the achievement has been awarded, the achievement will no longer show on the screen
function EHI:IsAchievementLocked2(achievement)
    local a = Global.achievment_manager.achievments[achievement]
    return a and not a.awarded
end

function EHI:IsAchievementUnlocked2(achievement)
    return not self:IsAchievementLocked2(achievement)
end

if EHI.debug then -- For testing purposes
    function EHI:IsAchievementLocked2(achievement)
        return true
    end

    function EHI:DebugInstance(instance_name)
        if self:IsClient() then
            self:Log("Instance debugging is only available when you are the host")
            return
        end
        local scripts = managers.mission._scripts or {}
        local instances = managers.world_instance:instance_data()
        for _, instance in ipairs(instances) do
            if instance.name == instance_name then
                self:PrintTable(instance or {})
                local start = self:GetInstanceElementID(100000, instance.start_index)
                local _end = start + instance.index_size - 1
                local f = function(e, ...)
                    managers.hud:DebugBaseElement2(e._id, instance.start_index, nil, e:editor_name(), instance_name)
                end
                self:Log(string.format("Hooking elements in instance '%s'", instance_name))
                for _, script in pairs(scripts) do
                    for i = start, _end, 1 do
                        local element = script:element(i)
                        if element then
                            self:HookWithID(element, self.HostElement, "EHI_Debug_Element_" .. tostring(i), f)
                        end
                    end
                end
                self:Log("Hooking done")
            end
        end
    end
end

function EHI:PrintTable(tbl, ...)
    local s = ""
    if ... then
        local _tbl = { ... }
        for _, _s in ipairs(_tbl) do
            s = s .. " " .. tostring(_s)
        end
    end
    if _G.PrintTableDeep then
        _G.PrintTableDeep(tbl, 5000, true, "[EHI]" .. s, {}, false)
    else
        if s ~= "" then
            self:Log(s)
        end
        _G.PrintTable(tbl)
    end
end

if Global.load_level then
    -- Add network hook when a level is loaded to prevent stupid people sending tracker data while in menu, because EHIManager does not exist
    Hooks:Add("NetworkReceivedData", "NetworkReceivedData_EHI", function(sender, id, data)
        if id == EHI.SyncMessages.EHISyncAddTracker then
            local tbl = LuaNetworking:StringToTable(data)
            EHI:AddTrackerSynced(tonumber(tbl.id), tonumber(tbl.delay))
        end
    end)
end