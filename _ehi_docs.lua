---@meta
--[[
    This file is not loaded, it is here to provide code completion in VSCode
]]

---@class ElementWaypointTrigger
---@field id number|string? ID of the waypoint, if not provided, `id` is then copied from the trigger
---@field icon string? 
---@field time number? Time to run down. If not provided, `time` is then copied from the trigger
---@field class string? Class of the waypoint. If not provided, `class` is then copied from the trigger and converted to Waypoint class
---@field position Vector3
---@field position_by_element number?
---@field position_by_unit number?
---@field remove_vanilla_waypoint number?
---@field position_by_element_and_remove_vanilla_waypoint number?
---@field restore_on_done boolean? Depends on `remove_vanilla_waypoint`

---@class ElementClientTriggerData
---@field time number Maps to `additional_time`. If the field already exists, it is added to the field (+)
---@field random_time number,
---@field special_function number?

---@class ParseInstanceTable
---@field [string] table<number, ElementTrigger>

---@class ElementTrigger
---@field id string Tracker ID
---@field time number? Time to run down. Not required when tracker class is not using it. Defaults to `0` if not provided
---@field additional_time number? Time to add when the time is randomized. Used with conjuction with `random_time`
---@field random_time number? Auto converts tracker class to inaccurate tracker
---@field condition boolean?
---@field condition_function function? Function has to return `boolean` value
---@field icons table? Icons to show in the tracker
---@field class string? Class of tracker. If not provided it defaults to `EHITracker` in `EHITrackerManager`
---@field special_function number? Special function the trigger should do
---@field waypoint ElementWaypointTrigger? Waypoint definition
---@field waypoint_f fun(self: EHIManager, trigger: ElementTrigger)? In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
---@field trigger_times number? How many times the trigger should run. If the number is provided and once it hits `0`, the trigger is unhooked from the Element and removed from memory
---@field client ElementClientTriggerData? Table for clients only to prepopulate fields for tracker syncing. Only applicable to `SF.GetElementTimerAccurate` and `SF.UnpauseTrackerIfExistsAccurate`
---@field pos number? Tracker position
---@field f string|fun(arg: any?)? Arguments are unsupported in `SF.CustomCodeDelayed`
---@field flash_times number?
---@field flash_bg boolean?
---@field [any] any

---@class ParseTriggerTable
---@field [number] ElementTrigger

---@class ParseAchievementDefinitionTable
---@field beardlib boolean If the achievement is from Beardlib
---@field difficulty_pass boolean Difficulty check, setting this to `false` will disable the achievement to show on the screen
---@field elements table<number, ElementTrigger> Elements to hook
---@field failed_on_alarm boolean Fails the achievement on alarm
---@field load_sync fun(self: EHIManager) Function to run if client drops-in to the game
---@field alarm_callback fun(dropin: boolean) Function to run after alarm has sounded
---@field parsed_callback fun() Function runs after the achievement is parsed
---@field cleanup_callback fun() Function runs during achievement traversal when difficulty check or unlock check is false; intended to delete remnants so they don't occupy memory
---@field mission_end_callback boolean Achieves or fails achievement on mission end

---@class ParseAchievementTable
---@field [string] ParseAchievementDefinitionTable Achievement Definition

---@class ParseTriggersTable
---@field mission { [number]: ElementTrigger } Triggers related to mission
---@field achievement { [string]: ParseAchievementDefinitionTable } Triggers related to achievements in the mission
---@field other table Triggers not related to mission or achievements
---@field trophy table Triggers related to Safehouse trophies
---@field daily table Triggers related to Safehouse daily mission
---@field preload table Trackers to preload during game load, achievements not recommended

---@class ParseUnitsTable
---@field [number] UnitUpdateDefinition

---@class LootCounterSequenceTriggersTable
---@field loot string[] Sequences where loot spawns (ipairs); triggers "LootCounter:RandomLootSpawned()"
---@field no_loot string[] Sequences where no loot or garbage spawns (ipairs); triggers "LootCounter:RandomLootDeclined()"

---@class LootCounterTable
---@field max integer Maximum number of loot
---@field max_random integer Defines a variable number of loot
---@field load_sync fun(self: EHIManager)|nil|false Synchronizes secured bags in Loot Counter, automatically sets `no_sync_load` to true and you have to sync the progress manually via `EHITrackerManager:SyncSecuredLoot()`
---@field no_sync_load boolean Prevents Loot Counter from sync after joining
---@field offset boolean If offset is required, used in multi-day heists if loot is brought to next days
---@field client_from_start boolean If client is playing from mission briefing; does not do anything on host
---@field n_offset integer Provided via EHI:ShowLootCounterOffset(); DO NOT PROVIDE IT
---@field triggers table If loot is manipulated via Mission Script, also see field `hook_triggers`
---@field hook_triggers boolean If Loot Counter is created during spawn or gameplay, triggers must be hooked in order to work
---@field sequence_triggers table<number, LootCounterSequenceTriggersTable> Used for random loot spawning via sequences

---@class AchievementCounterTable
---@field check_type integer See `EHI.LootCounter.CheckType`, defaults to `EHI.LootCounter.CheckType.BagsOnly` if not provided
---@field loot_type string|string[] What loot should be counted
---@field f fun(loot: LootManager, tracker_id: string) Function for custom calculation when `check_type` is set to `EHI.LootCounter.CheckType.CustomCheck`

---@class AchievementLootCounterTable
---@field achievement string Achievement ID
---@field show_loot_counter boolean If achievement is already earned, show Loot Counter instead
---@field max integer Maximum number of loot
---@field progress integer Start with progress if provided, otherwise 0
---@field show_finish_after_reaching_target boolean Setting this to `true` will show `FINISH` in the tracker
---@field class string Achievement tracker class
---@field load_sync fun(self: EHIManager) Synchronizes secured bags in the achievement
---@field loot_counter_load_sync fun(self: EHIManager) Synchronizes secured bags in the loot counter if achievement is not visible
---@field alarm_callback fun(dropin: boolean) Do some action when alarm is sounded
---@field failed_on_alarm boolean Fails achievement in tracker on alarm
---@field triggers table Adds triggers when counter is manipulated via Mission Script, prevents counting
---@field hook_triggers boolean If tracker is created during spawn or gameplay, triggers must be hooked in order to work
---@field add_to_counter boolean Adds achievement to update loop when a loot is secured; applicable only to `triggers`, useful when standard loot counting is required with triggers
---@field no_counting boolean Prevents standard counting
---@field counter AchievementCounterTable Modifies counter checks
---@field difficulty_pass boolean?
---@field loot_counter_on_fail boolean? If the achievement loot counter should switch to `EHILootCounter` class when failed
---@field silent_failed_on_alarm boolean Fails achievement silently and switches to Loot Counter (only for dropins that are currently syncing and after the achievement has failed); Depends on Loot Counter to be visible in order to work
---@field start_silent boolean? If the achievement loot counter should start as `EHILootCounter` first; When achievement really starts, call `EHIAchievementLootCounterTracker:SetStarted()`
---@field no_sync boolean Disables loot sync

---@class AchievementBagValueCounterTable
---@field achievement string Achievement ID
---@field value number Value of loot needed to secure
---@field show_finish_after_reaching_target boolean Setting this to `true` will show `FINISH` in the tracker
---@field counter AchievementCounterTable Modifies counter checks

---@class AchievementKillCounterTable
---@field achievement string Achievement ID
---@field achievement_stat string Achievement Counter
---@field achievement_option string? If achievement belongs to some EHI setting
---@field difficulty_pass boolean?

---@class AddTrackerTable
---@field id string Tracker ID
---@field icons table? Icons in the tracker
---@field class string? Tracker class, defaults to `EHITracker` if not provided

---@class AddWaypointTable
---@field id string Waypoint ID
---@field time number
---@field class string? Waypoint class, defaults to `EHIWaypoint` if not provided
---@field remove_vanilla_waypoint number?
---@field restore_on_done boolean? Depends on `remove_vanilla_waypoint`
---@field icon string|table
---@field texture string
---@field text_rect { x: number, y: number, w: number, h: number }

---@class _WaypointDataTable
---@field bitmap userdata
---@field bitmap_world userdata
---@field timer_gui userdata
---@field distance userdata
---@field arrow userdata
---@field position Vector3

---@class WaypointDataTable : _WaypointDataTable
---@field init_data _WaypointDataTable

---@class MissionDoorAdvancedTable
---@field w_id number Waypoint ID
---@field restore boolean? If the waypoint should be restored when the drill finishes
---@field unit_id number? ID of the MissionDoor device (safe, door, vault, ...)

---@class MissionDoorTable
---@field [Vector3] number|MissionDoorAdvancedTable

---@class MissionDoorTableParsed
---@field [string] number|MissionDoorAdvancedTable

---@class ValueBasedOnDifficultyTable
---@field normal_or_above any Normal or above
---@field normal any Normal
---@field hard_or_below any Hard or below
---@field hard_or_above any Hard or above
---@field hard any Hard
---@field veryhard_or_below any Very Hard or below
---@field veryhard_or_above any Very Hard or above
---@field veryhard any Very Hard
---@field overkill_or_below any OVERKILL or below
---@field overkill_or_above any OVERKILL or above
---@field overkill any OVERKILL
---@field mayhem_or_below any Mayhem or below
---@field mayhem_or_above any Mayhem or above
---@field mayhem any Mayhem
---@field deathwish_or_below any Death Wish or below
---@field deathwish_or_above any Death Wish or above
---@field deathwish any Death Wish
---@field deathsentence_or_below any Death Sentence or below
---@field deathsentence any Death Sentence

---@class KeypadResetTimerTable
---@field normal number Normal `5s`
---@field hard number Hard `15s`
---@field veryhard number Very Hard `15s`
---@field overkill number OVERKILL `20s`
---@field mayhem number Mayhem `30s`
---@field deathwish number Death Wish `30s`
---@field deathsentence number Death Sentence `40s`

---@class UnitUpdateDefinition
---@field ignore boolean
---@field child_units table
---@field icons table
---@field remove_on_power_off boolean
---@field disable_set_visible boolean
---@field remove_on_alarm boolean
---@field remove_vanilla_waypoint number
---@field restore_waypoint_on_done boolean Depends on `remove_vanilla_waypoint`
---@field ignore_visibility boolean
---@field set_custom_id string
---@field tracker_merge_id string
---@field custom_callback table<string, string>
---@field position Vector3
---@field remove_on_pause boolean
---@field warning boolean
---@field completion boolean
---@field icon_on_pause table
---@field f string|fun(id: number, unit_data: self, unit: Unit)
---@field [any] any

---@class EHITracker_params
---@field id string
---@field icons table?
---@field time number?
---@field x number Provided by `EHITrackerManager`
---@field y number Provided by `EHITrackerManager`
---@field parent_class EHITrackerManager
---@field hide_on_delete boolean?
---@field flash_times number?
---@field flash_bg boolean?
---@field [any] any

---@class EHITracker_CreateText
---@field name string? Text name
---@field status_text string? Sets status text, like in achievements
---@field text string? Text to display
---@field w number?
---@field h number?
---@field color Color?

---@class XPBreakdown_tactic
---@field stealth _XPBreakdown
---@field loud _XPBreakdown

---@class XPBreakdown_random
---@field max number?
---@field [string] XPBreakdown_objectives

---@class _XPBreakdown_escape
---@field amount number
---@field stealth boolean
---@field loud boolean
---@field timer number `stealth` only
---@field c4_used boolean `loud` only

---@class XPBreakdown_escape
---@field [number] _XPBreakdown_escape

---@class XPBreakdown_objective
---@field [string] number|table
---@field escape number|XPBreakdown_escape

---@class _XPBreakdown_objectives
---@field amount number XP Base
---@field name string `ehi_experience_<name>`
---@field optional boolean?
---@field times number?
---@field escape number|XPBreakdown_escape
---@field random XPBreakdown_random
---@field stealth number
---@field loud number

---@class XPBreakdown_objectives
---@field [number] _XPBreakdown_objectives

---@class XPBreakdown_loot
---@field [string] number|{amount: number, times: number}

---@class _XPBreakdown
---@field objective XPBreakdown_objective
---@field objectives XPBreakdown_objectives
---@field loot XPBreakdown_loot
---@field loot_all number|{amount: number, times: number}
---@field wave number[]
---@field wave_all number|{amount: number, times: number}

---@class XPBreakdown
---@field objective XPBreakdown_objective
---@field objectives XPBreakdown_objectives
---@field loot XPBreakdown_loot
---@field loot_all number|{amount: number, times: number}
---@field wave number[]
---@field wave_all number|{amount: number, times: number}
---@field no_total_xp boolean
---@field tactic XPBreakdown_tactic