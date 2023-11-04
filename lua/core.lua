if _G.EHI then
    return
end

_G.EHI =
{
    debug =
    {
        achievements = false,
        mission_door = false,
        loot_manager_escape = false,
        instances = false,
        gained_experience = false
    },
    settings = {},

    FilterTracker =
    {
        show_timers =
        {
            waypoint = "show_waypoints_timers",
            table_name = "Timer"
        }
    },

    OptionTracker =
    {
        show_timers =
        {
            file = "EHITimerTracker",
            count = 1
        },
        show_sniper_tracker =
        {
            file = "EHISniperTrackers",
            count = 1
        }
    },

    _hooks = {},

    XPElementLevel =
    {
        jewelry_store = true,
        ukrainian_job = true,
        election_day_1 = true,
        alex_1 = true,
        alex_2 = true,
        alex_3 = true,
        firestarter_1 = true,
        safehouse = true
    },
    XPElementLevelNoCheck =
    {
        mallcrasher = true, -- Mallcrasher
        rat = true -- Cook Off
    },

    LootCounter =
    {
        CheckType =
        {
            AllLoot = 1,
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
        DisableAchievements = false,
        MissionUnits = {},
        InstanceUnits = {},
        IgnoreWaypoints = {},
        ElementWaypointFunction = {},
        XPElement = 0
    },

    Callback = {},
    CallbackMessage =
    {
        Spawned = "Spawned",
        -- Provides `loc` (a LocalizationManager class)
        LocLoaded = "LocLoaded",
        -- Provides `success` (a boolean value)
        MissionEnd = "MissionEnd",
        GameRestart = "GameRestart",
        -- Provides `self` (a LootManager class)
        LootSecured = "LootSecured",
        -- Provides `managers` (a global table with all managers)
        InitManagers = "InitManagers",
        InitFinalize = "InitFinalize",
        -- Provides `self` (a LootManager class)
        LootLoadSync = "LootLoadSync",
        OnMinionAdded = "OnMinionAdded",
        OnMinionKilled = "OnMinionKilled",
        -- Provides `boost` (a string value) and `operation` (a string value -> `add`, `remove`)
        TeamAISkillBoostChange = "TeamAISkillBoostChanged",
        -- Provides `boost` (a string value) and `operation` (a string value -> `add`, `remove`)
        TeamAIAbilityBoostChange = "TeamAIAbilityBoostChanged",
        -- Provides `mode` (a string value -> `normal`, `phalanx`)
        AssaultModeChanged = "AssaultModeChanged",
        -- Provides `mode` (a string value -> `normal`, `endless`)
        AssaultWaveModeChanged = "AssaultWaveModeChanged"
    },

    SyncMessages =
    {
        EHISyncAddBuff = "EHISyncAddBuff",
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
        AddAchievementToCounter = 11,
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
        -- Autosets tracker class to `EHIInaccurateTracker`; see `EHIManager:ParseMissionTriggers()`
        SetRandomTime = 32,
        DecreaseChance = 34,
        GetElementTimerAccurate = 35,
        UnpauseTrackerIfExistsAccurate = 36,
        UnpauseOrSetTimeByPreplanning = 37,
        FinalizeAchievement = 39,
        IncreaseChanceFromElement = 42,
        DecreaseChanceFromElement = 43,
        SetChanceFromElement = 44,
        SetChanceFromElementWhenTrackerExists = 45,
        PauseTrackerWithTime = 46,
        IncreaseProgressMax = 47,
        IncreaseProgressMax2 = 48,
        SetTimeIfLoudOrStealth = 49,
        AddTimeByPreplanning = 50,
        -- Autosets Vanilla settings for Waypoints; see `EHIManager:ParseMissionTriggers()`
        ShowWaypoint = 51,
        ShowEHIWaypoint = 52,
        DecreaseProgressMax = 53,
        DecreaseProgress = 54,
        IncreaseCounter = 55,
        DecreaseCounter = 56,
        SetCounter = 57,
        SniperSpawned = 58,
        SniperDead = 59,
        SniperRespawn = 60,

        CallCustomFunction = 100,
        CallTrackerManagerFunction = 101,
        CallWaypointManagerFunction = 102,

        Debug = 1000,
        DebugElement = 1001,
        CustomCode = 1002,
        CustomCodeIfEnabled = 1003,
        CustomCodeDelayed = 1004,

        -- Don't use it directly! Instead, call `EHI:GetFreeCustomSpecialFunctionID()` and `EHI:RegisterCustomSpecialFunction()` respectively; or provide a function to `EHI:RegisterCustomSpecialFunction()` as a first argument
        CustomSF = 100000
    },

    ConditionFunctions =
    {
        ---Checks if loud is active
        ---@return boolean
        IsLoud = function()
            return managers.groupai and not managers.groupai:state():whisper_mode()
        end,
        ---Checks if stealth is active
        ---@return boolean
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
        Turret = "turret",
        PCHack = "wp_hack",
        Glasscutter = "equipment_glasscutter",
        Loot = "pd2_loot",
        Goto = "pd2_goto",
        Pager = "pagers_used",
        Train = "C_Bain_H_TransportVarious_ButWait",
        LiquidNitrogen = "equipment_liquid_nitrogen_canister",
        Kill = "pd2_kill",
        Oil = "oil",
        Door = "pd2_door",
        USB = "equipment_usb_no_data",
        Destruction = "C_Vlad_H_Mallcrasher_Shoot",

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

    Trackers =
    {
        Base = "EHITracker",
        Warning = "EHIWarningTracker",
        -- Optional `paused`
        Pausable = "EHIPausableTracker",
        -- Optional `chance`
        Chance = "EHIChanceTracker",
        -- Optional `count`
        Counter = "EHICountTracker",
        -- Optional `max` and `progress`
        Progress = "EHIProgressTracker",
        NeededValue = "EHINeededValueTracker",
        Timer =
        {
            Base = "EHITimerTracker",
            Progress = "EHIProgressTimerTracker",
            Chance = "EHIChanceTimerTracker"
        },
        Sniper =
        {
            Count = "EHISniperCountTracker",
            -- Requires `chance`  
            -- Optional `chance_success`
            Chance = "EHISniperChanceTracker",
            -- Requires `time` and `refresh_t`
            Timed = "EHISniperTimedTracker",
            -- Requires `time`  
            -- Optional `count_on_refresh`
            TimedCount = "EHISniperTimedCountTracker",
            -- Requires `chance`, `time` and `recheck_t`
            TimedChance = "EHISniperTimedChanceTracker",
            -- Requires `chance`, `time` and `recheck_t`
            TimedChanceOnce = "EHISniperTimedChanceOnceTracker",
            -- Requires `chance`, `time`, `on_fail_refresh_t` and `on_success_refresh_t`
            Loop = "EHISniperLoopTracker",
            -- Requires `time` and `refresh_t`
            Heli = "EHISniperHeliTracker",
            -- Requires `chance`, `time` and `recheck_t`
            HeliTimedChance = "EHISniperHeliTimedChanceTracker"
        },
        Achievement =
        {
            Base = "EHIAchievementTracker",
            Unlock = "EHIAchievementUnlockTracker",
            -- Optional `status`
            Status = "EHIAchievementStatusTracker",
            Progress = "EHIAchievementProgressTracker",
            BagValue = "EHIAchievementBagValueTracker",
            LootCounter = "EHIAchievementLootCounterTracker"
        },
        Assault =
        {
            Time = "EHIAssaultTimeTracker",
            Delay = "EHIAssaultDelayTracker",
            Assault = "EHIAssaultTracker"
        },
        ColoredCodes = "EHIColoredCodesTracker",
        Inaccurate = "EHIInaccurateTracker",
        InaccurateWarning = "EHIInaccurateWarningTracker",
        InaccuratePausable = "EHIInaccuratePausableTracker",
        Trophy = "EHITrophyTracker",
        Daily = "EHIDailyTracker",
        DailyProgress = "EHIDailyProgressTracker"
    },

    Waypoints =
    {
        Warning = "EHIWarningWaypoint",
        Progress = "EHIProgressWaypoint",
        Pausable = "EHIPausableWaypoint",
        Inaccurate = "EHIInaccurateWaypoint",
        InaccuratePausable = "EHIInaccuratePausableWaypoint",
        InaccurateWarning = "EHIInaccurateWarningWaypoint"
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
    -- PAYDAY 2/mods/Extra Heist Info/
    ModPath = ModPath,
    -- PAYDAY 2/mods/Extra Heist Info/loc/
    LocPath = ModPath .. "loc/",
    -- PAYDAY 2/mods/Extra Heist Info/lua/
    LuaPath = ModPath .. "lua/",
    -- PAYDAY 2/mods/Extra Heist Info/menu/
    MenuPath = ModPath .. "menu/",
    -- PAYDAY 2/mods/saves/ehi.json
    SettingsSaveFilePath = BLTModManager.Constants:SavesDirectory() .. "ehi.json",
    SaveDataVer = 1
}
local SF = EHI.SpecialFunctions
EHI.SyncFunctions =
{
    [SF.GetElementTimerAccurate] = true,
    [SF.UnpauseTrackerIfExistsAccurate] = true
}
EHI.ClientSyncFunctions =
{
    [SF.GetElementTimerAccurate] = true,
    [SF.UnpauseTrackerIfExistsAccurate] = true
}
EHI.TriggerFunction =
{
    [SF.TriggerIfEnabled] = true,
    [SF.Trigger] = true
}
EHI.WaypointIconRedirect =
{
    [EHI.Icons.Heli] = "EHI_Heli"
}

---@param self EHI
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
        time_format = 2, -- 1 = Seconds only, 2 = Minutes and seconds
        tracker_alignment = 1, -- 1 = Vertical, 2 = Horizontal
        vr_x_offset = 0,
        vr_y_offset = 150,
        vr_scale = 1,
        vr_tracker_alignment = 1, -- 1 = Vertical, 2 = Horizontal

        colors =
        {
            tracker_waypoint =
            {
                inaccurate =
                {
                    r = 255,
                    g = 165,
                    b = 0
                },
                pause =
                {
                    r = 255,
                    g = 0,
                    b = 0
                },
                drill_autorepair =
                {
                    r = 137,
                    g = 209,
                    b = 254
                },
                warning =
                {
                    r = 255,
                    g = 0,
                    b = 0
                },
                completion =
                {
                    r = 0,
                    g = 255,
                    b = 0
                }
            },
            mission_briefing =
            {
                loot_secured =
                {
                    r = 255,
                    g = 188,
                    b = 0
                },
                total_xp =
                {
                    r = 0,
                    g = 255,
                    b = 0
                },
                optional =
                {
                    r = 137,
                    g = 209,
                    b = 254
                }
            }
        },

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
            show_achievement_description = false,
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
        show_trade_delay_amount_of_killed_civilians = false,
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
        show_minion_option = 3, -- 1 = You only; 2 = Total number of minions in one number; 3 = Number of minions per player
        show_minion_per_player = true,
        show_minion_killed_message = true,
        show_minion_killed_message_type = 1, -- 1 = Popup; 2 = Hint
        show_difficulty_tracker = true,
        show_drama_tracker = true,
        show_pager_tracker = true,
        show_pager_callback = true,
        show_enemy_count_tracker = true,
        show_enemy_count_show_pagers = true,
        show_civilian_count_tracker = true,
        show_laser_tracker = false,
        show_assault_delay_tracker = true,
        show_assault_time_tracker = true,
        aggregate_assault_delay_and_assault_time = true,
        show_loot_counter = true,
        show_all_loot_secured_popup = true,
        variable_random_loot_format = 3, -- 1 = Max-(Max+Random)?; 2 = MaxRandom?; 3 = Max+Random?
        show_bodybags_counter = true,
        show_escape_chance = true,
        show_sniper_tracker = true,

        -- Waypoints
        show_waypoints = true,
        show_waypoints_only = false,
        show_waypoints_present_timer = 2,
        show_waypoints_mission = true,
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
        buffs_vr_x_offset = 0,
        buffs_vr_y_offset = 80,
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
            unseen_strike_initial = true,
            -- Fugitive
            trigger_happy = true,
            desperado = true,
            running_from_death_reload = true,
            running_from_death_movement = true,
            up_you_go = true,
            swan_song = true,
            bloodthirst = true,
            bloodthirst_reload = true,
            bloodthirst_ratio = 34, -- value / 100
            berserker = true,
            berserker_refresh = 4, -- 1 / value
            berserker_format = 1, -- 1 = Multiplier; 2 = Percent

            -- Perks
            infiltrator = true,
            gambler = true,
            grinder = true,
            maniac = true,
            anarchist = true, -- +Armorer
            expresident = true,
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
            regen_throwable_ai = true,
            health = false,
            armor = false
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
    if self._cache.__loaded then
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
    self._cache.__loaded = true
    self._cache.DisableAchievements = not self:ShowMissionAchievements()
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
            self._cache.UnlockablesAreDisabled = mutator:are_achievements_disabled()
        end
        local level = Global.game_settings.level_id
        if level == "Enemy_Spawner" or level == "enemy_spawner2" or level == "modders_devmap" then -- These 3 maps disable achievements
            self._cache.UnlockablesAreDisabled = true
        end
    end)
end

---@return boolean
function EHI:IsVR()
    return self._cache.is_vr
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
        -- Swap the numbers
        diff_1, diff_2 = diff_2, diff_1
    end
    return self._cache.DifficultyIndex >= diff_1 and self._cache.DifficultyIndex <= diff_2
end

function EHI:DifficultyIndex()
    return self._cache.DifficultyIndex or 0
end

function EHI:IsMayhemOrAbove()
    return self:IsDifficultyOrAbove(self.Difficulties.Mayhem)
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

function EHI:IsPlayingSFN()
    return Global.game_settings.level_id == "haunted"
end

function EHI:IsNotPlayingSFN()
    return Global.game_settings.level_id ~= "haunted"
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

---@param vr_option string Option to be checked if the game is running in VR version
---@param option string Option to be checked if the game is running in non-VR version
---@param expected_value any What the expected value in the option should be
---@param vr_expected_value any? What the expected value in the VR option should be in VR (don't pass a value if the same value is expected for both options)
---@return boolean
function EHI:CheckVRAndNonVROption(vr_option, option, expected_value, vr_expected_value)
    if self:IsVR() then
        return self:GetOption(vr_option) == (vr_expected_value or expected_value)
    end
    return self:GetOption(option) == expected_value
end

---@param option string
function EHI:OptionAndLoadTracker(option)
    if self.OptionTracker[option] then
        local tracker = self.OptionTracker[option]
        tracker.count = tracker.count - 1
        if tracker.count == 0 then
            dofile(string.format("%s%s%s.lua", self.LuaPath, "trackers/", tracker.file))
        end
    end
end

---@param option string
function EHI:GetOptionAndLoadTracker(option)
    local result = self:GetOption(option)
    if result and self.OptionTracker[option] then
        local tracker = self.OptionTracker[option]
        tracker.count = tracker.count - 1
        if tracker.count == 0 then
            dofile(string.format("%s%s%s.lua", self.LuaPath, "trackers/", tracker.file))
        end
    end
    return result
end

---@param option string
function EHI:GetOption(option)
    if option then
        return self.settings[option]
    end
end

function EHI:GetTWColor(color)
    if color and self.settings.colors.tracker_waypoint[color] then
        return self:GetColor(self.settings.colors.tracker_waypoint[color])
    end
    return Color.white
end

---@return boolean
function EHI:ShowMissionAchievements()
    return self:GetUnlockableAndOption("show_achievements_mission") and self:GetUnlockableOption("show_achievements")
end

---@param id string Achievement ID
---@return boolean
function EHI:CanShowAchievement(id)
    if self:ShowMissionAchievements() then
        return self:IsAchievementLocked(id)
    end
    return false
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

---@param equipment string
---@return Color
function EHI:GetEquipmentColor(equipment)
    if equipment and self.settings.equipment_color[equipment] then
        return self:GetColor(self.settings.equipment_color[equipment])
    end
    return Color.white
end

function EHI:GetWaypointOption(waypoint)
    return self:GetOption("show_waypoints") and self:GetOption(waypoint)
end

---@param waypoint any
---@return boolean
---@return boolean
function EHI:GetWaypointOptionWithOnly(waypoint)
    local show = self:GetWaypointOption(waypoint)
    return show, show and self:GetOption("show_waypoints_only")
end

---@param color {r: number, g: number, b: number}
---@return Color
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

---@return boolean
function EHI:MissionTrackersAndWaypointEnabled()
    return self:GetOption("show_mission_trackers") and self:GetOption("show_waypoints")
end

function EHI:IsXPTrackerEnabled()
    return self:GetOption("show_gained_xp") and not self:IsPlayingCrimeSpree()
end

function EHI:IsXPTrackerDisabled()
    return not self:IsXPTrackerEnabled()
end

function EHI:IsXPTrackerVisible()
    return self:IsXPTrackerEnabled() and not self:GetOption("show_xp_in_mission_briefing_only")
end

function EHI:IsXPTrackerHidden()
    return not self:IsXPTrackerVisible()
end

function EHI:AreGagePackagesSpawned()
    return self._cache.GagePackagesSpawned or false
end

function EHI:IsLootCounterVisible()
    return self:GetOption("show_loot_counter") and not self:IsPlayingCrimeSpree()
end

function EHI:IsPlayingCrimeSpree()
    return Global.game_settings and Global.game_settings.gamemode and Global.game_settings.gamemode == "crime_spree"
end

function EHI:AssaultDelayTrackerIsEnabled()
    return self:GetOption("show_assault_delay_tracker") and not tweak_data.levels:IsLevelSkirmish()
end

---@return boolean
function EHI:CombineAssaultDelayAndAssaultTime()
    return self:GetOption("show_assault_delay_tracker") and self:GetOption("show_assault_time_tracker") and self:GetOption("aggregate_assault_delay_and_assault_time")
end

function EHI:IsTradeTrackerDisabled()
    return not self:GetOption("show_trade_delay") or self:IsPlayingSFN()
end

---@param params XPBreakdown
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

---@param f fun(dropin: boolean)
function EHI:AddOnAlarmCallback(f)
    self:AddCallback("Alarm", f)
end

---@param dropin boolean
function EHI:RunOnAlarmCallbacks(dropin)
    self:CallCallbackOnce("Alarm", dropin)
end

---@param f fun(custody_state: boolean)
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
---@param id string|number
---@param post_call function
function EHI:HookElement(object, func, id, post_call)
    Hooks:PostHook(object, func, "EHI_Element_" .. id, post_call)
end

---@param id string
function EHI:Unhook(id)
    Hooks:RemovePostHook("EHI_" .. id)
end

---Hooks elements that removes loot bags (due to fire or out of bounds)
---@param elements number|number[] Index or indexes of ElementCarry that removes loot bags with operation "remove"
function EHI:HookLootRemovalElement(elements)
    if type(elements) ~= "table" and type(elements) ~= "number" then
        return
    end
    local f
    local HookFunction
    local ElementFunction
    local id
    if self:IsHost() then
        HookFunction = self.PreHookWithID
        ElementFunction = self.HostElement
        id = "EHI_Prehook_Element_"
        f = function(e, instigator, ...)
            if not e._values.enabled or not alive(instigator) then
                return
            end
            if e._values.type_filter and e._values.type_filter ~= "none" then
                local carry_ext = instigator:carry_data()
                if not carry_ext then
                    return
                end
                local carry_id = carry_ext:carry_id()
                if carry_id ~= e._values.type_filter then
                    return
                end
            end
            managers.ehi_tracker:DecreaseLootCounterProgressMax()
        end
    else
        HookFunction = self.HookWithID
        ElementFunction = self.ClientElement
        id = "EHI_Element_"
        f = function(...)
            managers.ehi_tracker:DecreaseLootCounterProgressMax()
        end
    end
    if type(elements) == "table" then
        for _, index in ipairs(elements) do
            local element = managers.mission:get_element_by_id(index)
            if element then
                HookFunction(self, element, ElementFunction, id .. tostring(index), f)
            end
        end
    else -- number
        local element = managers.mission:get_element_by_id(elements)
        if element then
            HookFunction(self, element, ElementFunction, id .. tostring(elements), f)
        end
    end
end

---@return boolean
function EHI:ShowDramaTracker()
    return self:IsHost() and self:GetOption("show_drama_tracker") and self:IsNotPlayingSFN()
end

---@return boolean
function EHI:IsRunningBB()
    return BB and BB.grace_period and Global.game_settings.single_player and Global.game_settings.team_ai
end

function EHI:IsRunningUsefulBots()
    if self:IsHost() then
        return UsefulBots and Global.game_settings.team_ai
    elseif self._cache.HostHasUsefulBots ~= nil then
        return self._cache.HostHasUsefulBots
    end
    return false
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
---@param n number
---@param bracket number? Number in `*10` or `/10`
---@return number
function EHI:RoundNumber(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math_floor(n / bracket + sign * 0.5) * bracket
end

---@param n number
function EHI:RoundChanceNumber(n)
    return self:RoundNumber(n, 0.01) * 100
end

---@param id number Element ID
---@return Vector3?
function EHI:GetElementPosition(id)
    local element = managers.mission:get_element_by_id(id)
    if not element then
        return nil
    end
    return element:value("position")
end

---@param id number Unit ID
---@return Vector3?
function EHI:GetUnitPosition(id)
    local unit = managers.worlddefinition:get_unit(id)
    if not unit then
        return nil
    end
    if not unit.position then
        return nil
    end
    return unit:position()
end

---@param message string
---@param data any
function EHI:Sync(message, data)
    LuaNetworking:SendToPeersExcept(1, message, data or "")
end
---@param message string
---@param tbl table?
function EHI:SyncTable(message, tbl)
    LuaNetworking:SendToPeersExcept(1, message, LuaNetworking:TableToString(tbl or {}))
end
if Global.game_settings and Global.game_settings.single_player then
    EHI.Sync = function(...) end
    EHI.SyncTable = function(...) end
end

---@param triggers table
function EHI:SetSyncTriggers(triggers)
    managers.ehi_manager:SetSyncTriggers(triggers)
end

function EHI:AddSyncTrigger(id, trigger)
    managers.ehi_manager:AddSyncTrigger(id, trigger)
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
    if self.XPElementLevelNoCheck[level_id] then
        return false
    end
    return self._cache.XPElement <= 1 or self.XPElementLevel[level_id]
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

---Adds trigger to mission element when they run
---@param new_triggers table
---@param trigger_id_all string
---@param trigger_icons_all table?
function EHI:AddTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:AddTriggers(new_triggers, trigger_id_all, trigger_icons_all)
end

---Adds trigger to mission element when they run. If trigger already exists, it is moved and added into table
---@param new_triggers table
---@param params table?
---@param trigger_id_all string
---@param trigger_icons_all table?
function EHI:AddTriggers2(new_triggers, params, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:AddTriggers2(new_triggers, params, trigger_id_all, trigger_icons_all)
end

---@param new_triggers table
---@param type string
---|"base" # Random delay is defined in the BASE DELAY
---|"element" # Random delay is defined when calling the elements
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:AddHostTriggers(new_triggers, type, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:AddHostTriggers(new_triggers, type, trigger_id_all, trigger_icons_all)
end

---@param id number
---@param waypoint table
function EHI:AddWaypointToTrigger(id, waypoint)
    managers.ehi_manager:AddWaypointToTrigger(id, waypoint)
end

---@param id number
---@param icon string
function EHI:UpdateWaypointTriggerIcon(id, icon)
    managers.ehi_manager:UpdateWaypointTriggerIcon(id, icon)
end

---@param id number
---@param f fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)
---@return nil
---@overload fun(self, f: fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)): integer
function EHI:RegisterCustomSpecialFunction(id, f)
    return managers.ehi_manager:RegisterCustomSpecialFunction(id, f)
end

---Unregisters custom special function
---@param id number
function EHI:UnregisterCustomSpecialFunction(id)
    managers.ehi_manager:UnregisterCustomSpecialFunction(id)
end

function EHI:GetFreeCustomSpecialFunctionID()
    local id = (self._cache.SFFUsed or self.SpecialFunctions.CustomSF) + 1
    self._cache.SFFUsed = id
    return id
end

---@param elements_to_hook table
function EHI:HookElements(elements_to_hook)
    managers.ehi_manager:HookElements(elements_to_hook)
end

---@param params ElementTrigger
---@return ElementTrigger?
function EHI:AddAssaultDelay(params)
    if not self:GetOption("show_assault_delay_tracker") then
        if params.special_function and params.special_function > SF.CustomSF then
            self:UnregisterCustomSpecialFunction(params.special_function)
        end
        return nil
    end
    local id = "AssaultDelay"
    local class = self.Trackers.Assault.Delay
    local pos = nil
    if self:CombineAssaultDelayAndAssaultTime() then
        id = "Assault"
        class = self.Trackers.Assault.Assault
        pos = 0
    elseif params.random_time then
        class = "EHIInaccurateAssaultDelayTracker"
    end
    local tbl = {}
    -- Copy every passed value to the trigger
    for key, value in pairs(params) do
        tbl[key] = value
    end
    if params.random_time then
        tbl.additional_time = tbl.additional_time or 30
    else
        tbl.time = tbl.time or 30
    end
    tbl.id = id
    tbl.class = class
    tbl.pos = pos
    return tbl
end

---@param f function Loot counter function
---@param check any? Boolean value of option 'show_loot_counter'
---@param trigger_once boolean? Should the trigger run once?
---@return table?
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

---@param f function Loot counter function
---@param trigger_once boolean? Should the trigger run once?
---@return table
function EHI:AddLootCounter2(f, trigger_once)
    local tbl =
    {
        special_function = SF.CustomCode,
        f = f
    }
    if trigger_once then
        tbl.trigger_times = 1
    end
    return tbl
end

---@param f fun(self: EHIManager, trigger: table, element: table, enabled: boolean) Loot counter function
---@param trigger_once boolean? Should the trigger run once?
---@return table
function EHI:AddLootCounter3(f, trigger_once)
    local tbl =
    {
        special_function = self:RegisterCustomSpecialFunction(f)
    }
    if trigger_once then
        tbl.trigger_times = 1
    end
    return tbl
end

function EHI:AddPositionFromElement(data, id, check)
    local vector = self:GetElementPosition(data.position_by_element)
    if vector then
        data.position = vector
        data.position_by_element = nil
    elseif check then
        data.position = Vector3()
        self:Log(string.format("Element with ID '%d' has not been found. Element ID to hook '%s'. Position vector set to default value to avoid crashing.", data.position_by_element, tostring(id)))
    end
end

function EHI:AddPositionFromUnit(data, id, check)
    local vector = self:GetUnitPosition(data.position_by_unit)
    if vector then
        data.position = vector
        data.position_by_unit = nil
    elseif check then
        data.position = Vector3()
        self:Log(string.format("Unit with ID '%d' has not been found. Element ID to hook '%s'. Position vector set to default value to avoid crashing.", data.position_by_unit, tostring(id)))
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

---@param new_triggers ParseTriggersTable
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:ParseTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:ParseTriggers(new_triggers, trigger_id_all, trigger_icons_all)
end

---@param new_triggers table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:ParseMissionTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:ParseMissionTriggers(new_triggers, trigger_id_all, trigger_icons_all)
end

---@param new_triggers table
---@param defer_loading_waypoints boolean?
function EHI:ParseMissionInstanceTriggers(new_triggers, defer_loading_waypoints)
    managers.ehi_manager:ParseMissionInstanceTriggers(new_triggers, defer_loading_waypoints)
end

---@param triggers table<number, ElementTrigger>
---@param option string
---| "show_timers" Filters out not loaded trackers with option show_timers
function EHI:FilterOutNotLoadedTrackers(triggers, option)
    managers.ehi_manager:FilterOutNotLoadedTrackers(triggers, option)
end

function EHI:ShouldDisableWaypoints()
    return self:GetOption("show_timers") and self:GetWaypointOption("show_waypoints_timers")
end

local function Waypoint(self, instigator, ...)
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
    self._cache.ElementWaypointFunction[id] = element.on_executed
    element.on_executed = Waypoint
end

---@param id number
function EHI:RestoreElementWaypoint(id)
    local element = managers.mission:get_element_by_id(id)
    if not (element and self._cache.ElementWaypointFunction[id]) then
        return
    end
    element.on_executed = self._cache.ElementWaypointFunction[id]
    self._cache.ElementWaypointFunction[id] = nil
end

---@param waypoints table?
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
---@param params LootCounterTable
---@param manager EHIManager
function EHI:ShowLootCounterOffset(params, manager)
    params.offset = nil
    params.n_offset = managers.loot:GetSecuredBagsAmount()
    params.hook_triggers = params.triggers ~= nil
    self:ShowLootCounterNoChecks(params)
end

---@param params LootCounterTable?
function EHI:ShowLootCounter(params)
    if not self:GetOption("show_loot_counter") then
        return
    end
    self:ShowLootCounterNoCheck(params)
end

---@param params LootCounterTable?
function EHI:ShowLootCounterNoCheck(params)
    if self:IsPlayingCrimeSpree() then
        return
    end
    self:ShowLootCounterNoChecks(params)
end

---@param params LootCounterTable?
function EHI:ShowLootCounterNoChecks(params)
    params = params or {}
    local n_offset = params.n_offset or 0
    if params.offset then
        if self:IsHost() or params.client_from_start then
            n_offset = managers.loot:GetSecuredBagsAmount()
        else
            managers.ehi_manager:AddFullSyncFunction(callback(self, self, "ShowLootCounterOffset", params))
            return
        end
    end
    managers.ehi_tracker:ShowLootCounter(params.max, params.max_random, n_offset)
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
            managers.ehi_tracker:RandomLootSpawned()
        end
        local function DecreaseRandom(...)
            managers.ehi_tracker:RandomLootDeclined()
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
    self:HookLootCounter(params.no_sync_load)
end

function EHI:HookLootCounter(no_sync_load)
    if not self._cache.LootCounter then
        local BagsOnly = self.LootCounter.CheckType.BagsOnly
        local function Callback(loot)
            loot:EHIReportProgress("LootCounter", BagsOnly)
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

---@param params AchievementLootCounterTable
function EHI:ShowAchievementLootCounter(params)
    if self._cache.UnlockablesAreDisabled or self._cache.DisableAchievements or self:IsAchievementUnlocked(params.achievement) or params.difficulty_pass == false then
        if params.show_loot_counter then
            self:ShowLootCounter({ max = params.max, load_sync = params.loot_counter_load_sync })
        end
        return
    end
    self:ShowAchievementLootCounterNoCheck(params)
end

---@param params AchievementLootCounterTable
function EHI:ShowAchievementLootCounterNoCheck(params)
    if params.show_loot_counter and self:GetOption("show_loot_counter") then
        managers.ehi_tracker:AddAchievementLootCounter(params.achievement, params.max, params.loot_counter_on_fail, params.start_silent)
    else
        managers.ehi_tracker:AddAchievementProgressTracker(params.achievement, params.max, params.progress, params.show_finish_after_reaching_target, params.class)
    end
    if params.load_sync then
        self:AddLoadSyncFunction(params.load_sync)
    end
    if params.alarm_callback then
        self:AddOnAlarmCallback(params.alarm_callback)
    end
    if params.failed_on_alarm then
        self:AddOnAlarmCallback(function()
            managers.ehi_tracker:SetAchievementFailed(params.achievement)
        end)
    end
    if params.silent_failed_on_alarm then
        self:AddOnAlarmCallback(function()
            if managers.ehi_manager:GetInSyncState() then
                managers.ehi_tracker:CallFunction(params.achievement, "SetFailedSilent")
            else
                managers.ehi_tracker:SetAchievementFailed(params.achievement)
            end
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

---@param params AchievementBagValueCounterTable
function EHI:ShowAchievementBagValueCounter(params)
    if self._cache.UnlockablesAreDisabled or self._cache.DisableAchievements or self:IsAchievementUnlocked(params.achievement) then
        return
    end
    managers.ehi_tracker:AddAchievementBagValueCounter(params.achievement, params.value, params.show_finish_after_reaching_target)
    self:AddAchievementToCounter(params)
end

---@param params AchievementLootCounterTable|AchievementBagValueCounterTable
function EHI:AddAchievementToCounter(params)
    local check_type = params.counter and params.counter.check_type or self.LootCounter.CheckType.BagsOnly
    local loot_type = params.counter and params.counter.loot_type
    local f = params.counter and params.counter.f
    ---@param loot LootManager
    local function callback(loot)
        loot:EHIReportProgress(params.achievement, check_type, loot_type, f)
    end
    self:AddCallback(self.CallbackMessage.LootSecured, callback)
    if not (params.load_sync or params.no_sync) then
        self:AddCallback(self.CallbackMessage.LootLoadSync, callback)
    end
end

---@param params AchievementKillCounterTable
function EHI:ShowAchievementKillCounter(params)
    if params.achievement_option and not self:GetUnlockableAndOption(params.achievement_option) then
        return
    end
    if self._cache.UnlockablesAreDisabled or self._cache.DisableAchievements or self:IsAchievementUnlocked2(params.achievement) or params.difficulty_pass == false then
        self:Log("Achievement disabled! id: " .. tostring(params.achievement))
        return
    end
    local id = params.achievement
    local id_stat = params.achievement_stat
    local tweak_data = tweak_data.achievement.persistent_stat_unlocks[id_stat]
    if not tweak_data then
        self:Log("No statistics found for achievement " .. tostring(id) .. "; Stat: " .. tostring(id_stat))
        return
    end
    local progress = self:GetAchievementProgress(id_stat)
    local max = tweak_data[1] and tweak_data[1].at or 0
    if progress >= max then
        self:Log("Achievement already unlocked; return")
        self:Log(string.format("progress: %d; max: %d", progress, max))
        return
    end
    managers.ehi_tracker:AddAchievementKillCounter(id, progress, max)
    self.KillCounter = self.KillCounter or {}
    self.KillCounter[id_stat] = id
    if not self.KillCounterHook then
        EHI:HookWithID(AchievmentManager, "award_progress", "EHI_award_progress_KillCounter", function(am, stat, value)
            local s = EHI.KillCounter[stat]
            if s then
                managers.ehi_tracker:IncreaseTrackerProgress(s, value)
            end
        end)
        self.KillCounterHook = true
    end
end

---@param f fun(self: EHIManager)
function EHI:AddLoadSyncFunction(f)
    managers.ehi_manager:AddLoadSyncFunction(f)
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
---@param instance_continent_index? number Defaults to `100000`
function EHI:UpdateInstanceUnits(tbl, instance_start_index, instance_continent_index)
    if not self:GetOption("show_timers") then
        return
    end
    self:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
end

---@param tbl table
---@param instance_start_index number
---@param instance_continent_index? number Defaults to `100000`
function EHI:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
    local new_tbl = {}
    instance_continent_index = instance_continent_index or 100000
    for id, data in pairs(tbl) do
        local computed_id = self:GetInstanceElementID(id, instance_start_index, instance_continent_index)
        new_tbl[computed_id] = deep_clone(data)
        if new_tbl[computed_id].remove_vanilla_waypoint then
            new_tbl[computed_id].remove_vanilla_waypoint = self:GetInstanceElementID(new_tbl[computed_id].remove_vanilla_waypoint, instance_start_index, instance_continent_index)
        end
        new_tbl[computed_id].base_index = id
    end
    self:FinalizeUnits(new_tbl)
    for id, data in pairs(new_tbl) do
        self._cache.InstanceUnits[id] = data
    end
end

---@param tbl MissionDoorTable
function EHI:SetMissionDoorData(tbl)
    if TimerGui.SetMissionDoorData then
        TimerGui.SetMissionDoorData(tbl)
    end
end

function EHI:CheckNotLoad()
    if Global.load_level and not Global.editor_mode then
        return false
    end
    return true
end

---@param hook string
function EHI:CheckLoadHook(hook)
    if not Global.load_level or Global.editor_mode then
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
    if self._hooks[hook] or Global.editor_mode then
        return true
    end
    self._hooks[hook] = true
    return false
end

---Returns default keypad time reset for the current difficulty  
---Default values:  
---`normal = 5s`  
---`hard = 15s`  
---`veryhard = 15s`  
---`overkill = 20s`  
---`mayhem = 30s`  
---`deathwish = 30s`  
---`deathsentence = 40s`  
---@param time_override KeypadResetTimerTable? Overrides default keypad time reset for each difficulty
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

---Returns value for the current difficulty. If the value is not provided `-1` is returned
---@param values ValueBasedOnDifficultyTable
---@return any
function EHI:GetValueBasedOnDifficulty(values)
    if values.normal_or_above and self:IsDifficultyOrAbove(self.Difficulties.Normal) then
        return values.normal_or_above
    elseif self:IsDifficulty(self.Difficulties.Normal) then
        return values.normal or -1
    elseif values.hard_or_below and self:IsDifficultyOrBelow(self.Difficulties.Hard) then
        return values.hard_or_below
    elseif values.hard_or_above and self:IsDifficultyOrAbove(self.Difficulties.Hard) then
        return values.hard_or_above
    elseif self:IsDifficulty(self.Difficulties.Hard) then
        return values.hard or -1
    elseif values.veryhard_or_below and self:IsDifficultyOrBelow(self.Difficulties.VeryHard) then
        return values.veryhard_or_below
    elseif values.veryhard_or_above and self:IsDifficultyOrAbove(self.Difficulties.VeryHard) then
        return values.veryhard_or_below
    elseif self:IsDifficulty(self.Difficulties.VeryHard) then
        return values.veryhard or -1
    elseif values.overkill_or_below and self:IsDifficultyOrBelow(self.Difficulties.OVERKILL) then
        return values.overkill_or_below
    elseif values.overkill_or_above and self:IsDifficultyOrAbove(self.Difficulties.OVERKILL) then
        return values.overkill_or_above
    elseif self:IsDifficulty(self.Difficulties.OVERKILL) then
        return values.overkill or -1
    elseif values.mayhem_or_below and self:IsDifficultyOrBelow(self.Difficulties.Mayhem) then
        return values.mayhem_or_below
    elseif values.mayhem_or_above and self:IsMayhemOrAbove() then
        return values.mayhem_or_above
    elseif self:IsDifficulty(self.Difficulties.Mayhem) then
        return values.mayhem or -1
    elseif values.deathwish_or_below and self:IsDifficultyOrBelow(self.Difficulties.DeathWish) then
        return values.deathwish_or_below
    elseif values.deathwish_or_above and self:IsDifficultyOrAbove(self.Difficulties.DeathWish) then
        return values.deathwish_or_above
    elseif self:IsDifficulty(self.Difficulties.DeathWish) then
        return values.deathwish or -1
    elseif values.deathsentence_or_below and self:IsDifficultyOrBelow(self.Difficulties.DeathSentence) then
        return values.deathsentence_or_below
    else
        return values.deathsentence or -1
    end
end

---@param trigger ElementTrigger?
---@param params ElementTrigger?
---@param overwrite_SF boolean?
---@return ElementTrigger?
function EHI:ClientCopyTrigger(trigger, params, overwrite_SF)
    if trigger == nil then
        return nil
    end
    ---@type ElementTrigger
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
    if overwrite_SF or not tbl.special_function then
        tbl.special_function = SF.AddTrackerIfDoesNotExist
    end
    return tbl
end

---@param type string
---|"ammo_bag" # Ignore ammo bags
---@param pos Vector3[] Table with positions that should be ignored
function EHI:SetDeployableIgnorePos(type, pos)
    if not type then
        self:Log("[EHI:SetDeployableIgnorePos()] Type is nil")
        return
    end
    if type == "ammo_bag" and AmmoBagBase.SetIgnoredPos then
        AmmoBagBase.SetIgnoredPos(pos)
    end
end

---@param level_id string
---@return boolean
function EHI:EscapeVehicleWillReturn(level_id)
    if self:IsHost() and SWAYRMod and SWAYRMod.included(level_id) then
        return false
    end
    return true
end

Load()
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

---@param package_id string Package ID in Beardlib
---@param achievement_id string
---@param skip_check boolean?
---@return boolean
function EHI:IsBeardLibAchievementLocked(package_id, achievement_id, skip_check)
    local Achievement = CustomAchievementPackage:new(package_id):Achievement(achievement_id)
    if not Achievement then
        return false
    end
    if Achievement:IsUnlocked() and not skip_check then
        return false
    end
    self._cache.Beardlib = self._cache.Beardlib or {}
    self._cache.Beardlib[achievement_id] = { name = Achievement:GetName(), objective = Achievement:GetObjective() }
    tweak_data.hud_icons["ehi_" .. achievement_id] = { texture = Achievement:GetIcon() }
    return true
end

---@param achievement string Achievement ID in Vanilla; Beardlib is not supported
---@return integer
function EHI:GetAchievementProgress(achievement)
    return managers.network.account:get_stat(achievement)
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

if EHI.debug.achievements then
    function EHI:IsAchievementLocked2(achievement)
        return true
    end
end

if EHI.debug.instances then -- For testing purposes
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

---@param tbl table
---@param ... any
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