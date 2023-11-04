--[[
    This file is not loaded, it is here to provide code completion in VSCode
]]

_G.tweak_data = {}
_G.managers = {}
---@type boolean
_G.IS_VR = ...

---@class managers Global table of all managers in the game
---@field ehi_manager EHIManager
---@field ehi_tracker EHITrackerManager
---@field ehi_waypoint EHIWaypointManager
---@field ehi_buff EHIBuffManager
---@field ehi_trade EHITradeManager
---@field loot LootManager
---@field [unknown] unknown

---@class tweak_data Global table of all configuration data
---@field levels LevelsTweakData
---@field [unknown] unknown

---@class _G Global
---@field managers managers Global table of all managers in the game
---@field tweak_data tweak_data Global table of all configuration data

---@class mathlib
---@field lerp fun(a: number, b: number, lerp: number): number Linearly interpolates between `a` and `b` by `lerp`
---@field round fun(n: number, precision: number?): number Rounds number with precision
---@field clamp fun(number: number, min: number, max: number): number Returns `number` clamped to the inclusive range of `min` and `max`
---@field rand fun(a: number, b: number?): number
---@field mod fun(n: number, div: number): number Returns remainder of a division

---@class tablelib
---@field size fun(tbl: table): number Returns size of the table
---@field contains fun(v: table, e: string): boolean Returns `true` or `false` if `e` exists in the table
---@field index_of fun(v: table, e: string): integer Returns `index` of the element when found, otherwise `-1` is returned

---@class ParseAchievementDefinitionTable
---@field difficulty_pass boolean Difficulty check, setting this to `false` will disable the achievement to show on the screen
---@field elements table Elements to hook
---@field failed_on_alarm boolean Fails the achievement on alarm
---@field load_sync fun(self: EHIManager) Function to run if client drops-in to the game
---@field alarm_callback fun(dropin: boolean) Function to run after alarm has sounded
---@field cleanup_callback fun() Function runs during achievement traversal when difficulty check or unlock check is false; intended to delete remnants so they don't occupy memory
---@field mission_end_callback boolean Achieves or fails achievement on mission end

---@class ParseAchievementTable
---@field [string] ParseAchievementDefinitionTable Achievement Definition

---@class ParseTriggersTable
---@field mission table Triggers related to mission
---@field achievement ParseAchievementTable Triggers related to achievements in the mission
---@field other table Triggers not related to mission or achievements
---@field trophy table Triggers related to Safehouse trophies
---@field daily table Triggers related to Safehouse daily mission
---@field preload table Trackers to preload during game load, achievements not recommended

---@class LootCounterSequenceTriggersTable
---@field loot table Sequences where loot spawns (ipairs); triggers "LootCounter:RandomLootSpawned()"
---@field no_loot table Sequences where no loot or garbage spawns (ipairs); triggers "LootCounter:RandomLootDeclined()"

---@class LootCounterTable
---@field max integer Maximum number of loot
---@field max_random integer Defines a variable number of loot
---@field load_sync fun(self: EHIManager)|nil|false Synchronizes secured bags in Loot Counter, automatically sets `no_sync_load` to true
---@field no_sync_load boolean Prevents Loot Counter from sync after joining
---@field offset boolean If offset is required, used in multi-day heists
---@field client_from_start boolean If client is playing from mission briefing; does not do anything on host
---@field n_offset integer Provided via EHI:ShowLootCounterOffset(); DO NOT PROVIDE IT
---@field triggers table If loot is manipulated via Mission Script, also see field `hook_triggers`
---@field hook_triggers boolean If Loot Counter is created during spawn or gameplay, triggers must be hooked in order to work
---@field sequence_triggers table<number, LootCounterSequenceTriggersTable> Used for random loot spawning via sequences
---@field no_counting boolean Disables standard Loot Counter updates via LootManager

---@class AchievementCounterTable
---@field check_type integer See `EHI.LootCounter.CheckType`, defaults to `EHI.LootCounter.CheckType.BagsOnly` if not provided
---@field loot_type string|table<string> What loot should be counted
---@field f fun(self: LootManager, tracker_id: string, loot_type: string|table<string>) Function for custom calculation when `loot_type` is set to `EHI.LootCounter.CheckType.CustomCheck`

---@class AchievementLootCounterTable
---@field achievement string Achievement ID
---@field show_loot_counter boolean If achievement is already earned, show Loot Counter instead
---@field max integer Maximum number of loot
---@field progress integer Start with progress if provided, otherwise 0
---@field remove_after_reaching_target boolean Setting this to `false` will show `FINISH` in the tracker
---@field class string Achievement tracker class
---@field load_sync fun(self: EHIManager) Synchronizes secured bags in the achievement
---@field alarm_callback fun(dropin: boolean) Do some action when alarm is sounded
---@field failed_on_alarm boolean Fails achievement in tracker on alarm
---@field triggers table Adds triggers when counter is manipulated via Mission Script, prevents counting
---@field hook_triggers boolean If tracker is created during spawn or gameplay, triggers must be hooked in order to work
---@field add_to_counter boolean Adds achievement to update loop when a loot is secured; applicable only to `triggers`, useful when standard loot counting is required with triggers
---@field no_counting boolean Prevents standard counting
---@field counter AchievementCounterTable Modifies counter checks
---@field difficulty_pass boolean?
---@field loot_counter_on_fail boolean? If the achievement loot counter should switch to EHILootCounter class when failed
---@field silent_failed_on_alarm boolean Fails achievement silently and switches to Loot Counter (only for dropins that are currently syncing and after the achievement has failed); Depends on Loot Counter to be visible in order to work

---@class AchievementBagValueCounterTable
---@field achievement string Achievement ID
---@field value number Value of loot needed to secure
---@field remove_after_reaching_target boolean Setting this to `false` will show `FINISH` in the tracker
---@field counter AchievementCounterTable Modifies counter checks

---@class AddTrackerTable
---@field id string Tracker ID
---@field icons table? Icons in the tracker
---@field class string? Tracker class, defaults to `EHITracker` if not provided

---@class AddWaypointTable
---@field id string Waypoint ID
---@field time number
---@field class string? Waypoint class, defaults to `EHIWaypoint` if not provided
---@field remove_vanilla_waypoint number?
---@field icon string|table
---@field texture string
---@field text_rect table

---@class WaypointDataTable
---@field bitmap userdata
---@field bitmap_world userdata
---@field timer_gui userdata
---@field distance userdata
---@field position Vector3

---@class MissionDoorAdvancedTable
---@field w_id number Waypoint ID
---@field restore boolean? If the waypoint should be restored when the drill finishes
---@field unit_id number? ID of the MissionDoor device (safe, door, vault, ...)

---@class MissionDoorTable
---@field [Vector3] number|MissionDoorAdvancedTable