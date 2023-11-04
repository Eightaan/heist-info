---@meta
--[[
    This file is not loaded, it is here to provide code completion in VSCode
]]

_G.Global = {}
---@class World
_G.World = {}
_G.tweak_data = {}
---@class EHITweakData
_G.tweak_data.ehi = {}
_G.managers = {}
---@type boolean
_G.IS_VR = ...
---@class TimerGui
_G.TimerGui = {}
---@class DigitalGui
_G.DigitalGui = {}
---@class ExperienceManager
_G.ExperienceManager = {}
---@param o table? Can be used to provide `self` to the callback function
---@param base_callback_class table
---@param base_callback_func_name string
---@param base_callback_param any?
---@return function
_G.callback = function(o, base_callback_class, base_callback_func_name, base_callback_param)
end
---@return Vector3
---@overload fun(x: number, y: number, z: number): Vector3
_G.Vector3 = function()
end
---@return Rotation
---@overload fun(x: number, y: number): Rotation
---@overload fun(x: number, y: number, z: number): Rotation
---@overload fun(x: number, y: number, z: number, w: number): Rotation
_G.Rotation = function()
end
---@class _G.Color
---@field black Color
---@field red Color
---@field white Color
---@field green Color
---@field yellow Color

---@class _G.Color
_G.Color = {}
---@return Color
---@overload fun(r: number, g: number, b: number): Color
---@overload fun(a: number, r: number, g: number, b: number): Color
---@overload fun(hex: string): Color
_G.Color = function()
end
---@generic T
---@param TC T
---@return T
_G.deep_clone = function(TC)
end
CoreTable.deep_clone = _G.deep_clone

---@generic T: table
---@param super T? A base class which `class` will derive from
---@return T
function class(super) end

---@class Vector3
---@field x number
---@field y number
---@field z number

---@class Color
---@field red number
---@field green number
---@field blue number
---@field unpack fun(self: self): r: number, g: number, b: number
---@field with_alpha fun(self: self, alpha: number): self

---@class MissionScriptElementValues
---@field amount number `ElementCounter` | `ElementCounterOperator`
---@field chance number `ElementLogicChance` | `ElementLogicChanceOperator`
---@field value number `ElementJobValue`
---@field position Vector3
---@field rotation Rotation

---@class MissionScriptElement
---@field counter_value fun(self: self): number `ElementCounter`
---@field enabled fun(self: self): boolean
---@field value fun(self: self, value: string): any
---@field id fun(self: self): number
---@field editor_name fun(self: self): string
---@field _is_inside fun(self: self, position: Vector3): boolean `ElementAreaReportTrigger `
---@field _values_ok fun(self: self): boolean `ElementCounterFilter` | `ElementStopwatchFilter`
---@field _values MissionScriptElementValues
---@field _calc_base_delay fun(...): number
---@field _calc_element_delay fun(...): number
---@field _timer number `ElementTimer` | `ElementTimerOperator`
---@field _check_difficulty fun(self: self): boolean `ElementDifficulty`
---@field _check_mode fun(self: self): boolean `ElementFilter`

---@class MissionScript
---@field element fun(self: self, id: number): MissionScriptElement?

---@class BlackMarketManager
---@field equipped_grenade fun(self: self): string
---@field get_suspicion_offset_of_local fun(self: self, lerp: number, ignore_armor_kit: boolean?): number

---@class ControllerWrapper
---@field add_trigger fun(self: self, connection_name: string, func: function)
---@field enable fun(self: self)
---@field destroy fun(self: self)
---@field get_input_axis fun(self: self, connection_name: string): Vector3
---@field get_input_bool fun(self: self, connection_name: string): boolean
---@field get_input_pressed fun(self: self, connection_name: string): boolean

---@class ControllerManager
---@field create_controller fun(self: self, name: string, index: number?, debug: boolean?, prio: number?): ControllerWrapper

---@class CriminalsManager
---@field character_color_id_by_unit fun(self: self, Unit: unit): number

---@class GuiDataManager
---@field create_fullscreen_workspace fun(self: self): Workspace
---@field create_fullscreen_16_9_workspace fun(self: self): Workspace 16:9
---@field destroy_workspace fun(self: self, ws: Workspace)
---@field safe_to_full fun(self: self, in_x: number, in_y: number): number, number
---@field full_to_safe fun(self: self, in_x: number, in_y: number): number, number
---@field full_scaled_size fun(self: self): { x: number, y: number, w: number, h: number }

---@class GroupAIStateBase
---@field hostage_count fun(self: self): number
---@field whisper_mode fun(self: self): boolean

---@class GroupAIManager
---@field state fun(self: self): GroupAIStateBase

---@class MissionManager
---@field _scripts table<string, MissionScript> All running scripts in a mission
---@field add_runned_unit_sequence_trigger fun(self: self, unit_id: number, sequence: string, callback: function)
---@field get_element_by_id fun(self: self, id: number): MissionScriptElement?

---@class MenuManager
---@field _input_enabled boolean
---@field _open_menus table
---@field is_pc_controller fun(self: self): boolean Returns `true` if the game was started by mouse or keyboard

---@class MousePointerManager
---@field convert_fullscreen_16_9_mouse_pos fun(self: self, in_x: number, in_y: number): number, number
---@field get_id fun(self: self): number Creates and returns a new mouse pointer id to use
---@field set_pointer_image fun(self: self, type: "arrow"|"link"|"hand"|"grab")
---@field use_mouse fun(self: self, params: table, position: number?)
---@field remove_mouse fun(self: self, id: number)

---@class NetworkPeer
---@field id fun(self: self): number

---@class NetworkManagerBaseSession
---@field local_peer fun(self: self): NetworkPeer
---@field peer_by_unit fun(self: self, Unit: unit): NetworkPeer

---@class NetworkManager
---@field session fun(self: self): NetworkManagerBaseSession

---@class managers Global table of all managers in the game
---@field blackmarket BlackMarketManager
---@field controller ControllerManager
---@field criminals CriminalsManager
---@field ehi_manager EHIManager
---@field ehi_tracker EHITrackerManager
---@field ehi_waypoint EHIWaypointManager
---@field ehi_buff EHIBuffManager
---@field ehi_trade EHITradeManager
---@field ehi_escape EHIEscapeChanceManager
---@field ehi_deployable EHIDeployableManager
---@field experience ExperienceManager
---@field game_play_central GamePlayCentralManager
---@field groupai GroupAIManager
---@field gui_data GuiDataManager
---@field hud HUDManager
---@field mission MissionManager
---@field menu MenuManager
---@field mouse_pointer MousePointerManager
---@field network NetworkManager
---@field localization LocalizationManager
---@field loot LootManager
---@field player PlayerManager
---@field worlddefinition WorldDefinition

---@class tweak_data Global table of all configuration data
---@field levels LevelsTweakData
---@field ehi EHITweakData
---@field [unknown] unknown

---@class Global_game_settings
---@field difficulty string
---@field gamemode string
---@field level_id string
---@field single_player boolean
---@field team_ai boolean

---@class Global
---@field achievment_manager table
---@field block_update_outfit_information boolean
---@field editor_mode boolean Only in `Beardlib Editor`
---@field load_level boolean
---@field hud_disabled boolean
---@field game_settings Global_game_settings
---@field mission_manager table
---@field statistics_manager table
---@field wallet_panel Panel?

---@class Gui
---@field create_world_workspace fun(self: self, w: number, h: number, x: Vector3, y: Vector3, z: Vector3): Workspace
---@field destroy_workspace fun(self: self, ws: Workspace)

---@class World
---@field newgui fun(self: self): Gui

---@class _G Global
---@field Global Global
---@field World World
---@field managers managers Global table of all managers in the game
---@field tweak_data tweak_data Global table of all configuration data
---@field PrintTableDeep fun(tbl: table, maxDepth: integer?, allowLogHeavyTables: boolean?, customNameForInitialLog: string?, tablesToIgnore: table|string?, skipFunctions: boolean?) Recursively prints tables; depends on mod: https://modworkshop.net/mod/34161
---@field PrintTable fun(tbl: table) Prints tables, provided by SuperBLT

---@class mathlib
---@field lerp fun(a: number, b: number, lerp: number): number Linearly interpolates between `a` and `b` by `lerp`
---@field round fun(n: number, precision: number?): number Rounds number with precision
---@field clamp fun(number: number, min: number, max: number): number Returns `number` clamped to the inclusive range of `min` and `max`
---@field rand fun(a: number, b: number?): number If `b` is provided, returns random number between `a` and `b`. Otherwise returns number between `0` and `a`
---@field mod fun(n: number, div: number): number Returns remainder of a division

---@class tablelib
---@field size fun(tbl: table): number Returns size of the table
---@field contains fun(v: table, e: string): boolean Returns `true` or `false` if `e` exists in the table
---@field index_of fun(v: table, e: string): integer Returns `index` of the element when found, otherwise `-1` is returned
---@field get_key fun(map: table, wanted_key_value: any): any? Returns `key name` if value exists
---@field list_to_set fun(list: table): table Maps values as keys

---@class InteractionExt
---@field interact_position fun(): Vector3

---@class UnitBase
---@field key fun(): string
---@field editor_id fun(): number
---@field position fun(): Vector3
---@field damage fun(): UnitDamage

---@class UnitTimer : UnitBase
---@field base Drill
---@field timer_gui fun(): TimerGui
---@field interaction fun(): InteractionExt
---@field mission_door_device fun(): MissionDoorDevice

---@class UnitDigitalTimer : UnitBase
---@field digital_gui fun(): DigitalGui

---@class Unit
---@field base unknown
---@field timer_gui fun(): TimerGui
---@field digital_gui fun(): DigitalGui
---@field interaction fun(): InteractionExt
---@field mission_door_device fun(): MissionDoorDevice
---@field [unknown] unknown

---@class LocalizationManager
---@field btn_macro fun(self: self, button: string, to_upper: boolean?, nil_if_empty: boolean?): string
---@field exists fun(self: self, string_id: string): boolean SuperBLT only
---@field text fun(self: self, string_id: string, macros: table?): string
---@field to_upper_text fun(self: self, string_id: string, macros: table?): string

---@class Workspace
---@field show fun(self: self)
---@field hide fun(self: self)
---@field panel fun(self: self): Panel
---@field connect_keyboard fun(self: self, keyboard: userdata)

---@class PanelBaseObject
---@field x fun(self: self): number
---@field set_x fun(self: self, x: number)
---@field y fun(self: self): number
---@field set_y fun(self: self, y: number)
---@field w fun(self: self): number
---@field set_w fun(self: self, w: number)
---@field h fun(self: self): number
---@field set_h fun(self: self, h: number)
---@field top fun(self: self): number
---@field set_top fun(self: self, top: number)
---@field bottom fun(self: self): number
---@field set_bottom fun(self: self, bottom: number)
---@field left fun(self: self): number
---@field set_left fun(self: self, left: number)
---@field right fun(self: self): number
---@field set_right fun(self: self, right: number)
---@field center_x fun(self: self): number
---@field set_center_x fun(self: self, center_x: number)
---@field set_position fun(self: self, x: number, y: number)
---@field set_leftbottom fun(self: self, left: number, bottom: number)
---@field alpha fun(self: self) : number
---@field set_alpha fun(self: self, alpha: number)
---@field stop fun(self: self, anim_thread: thread?)
---@field animate fun(self: self, f: function, ...:any?): thread
---@field set_size fun(self: self, w: number, h: number)
---@field visible fun(self: self): boolean
---@field set_visible fun(self: self, visible: boolean)
---@field parent fun(self: self): self

---@class Panel : PanelBaseObject
---@field child fun(self: self, child_name: string): (PanelText|PanelBitmap|PanelRectangle|self)?
---@field remove fun(self: self, child_name: PanelBaseObject)
---@field text fun(self: self, params: table): PanelText
---@field bitmap fun(self: self, params: table): PanelBitmap
---@field rect fun(self: self, params: table): PanelRectangle
---@field panel fun(self: self, params: table): self
---@field children fun(self: self): table Returns an ipairs table of all items created on the panel
---@field inside fun(self: self, x: number, y: number): boolean Returns `true` or `false` if provided `x` and `y` are inside the panel

---@class PanelText : PanelBaseObject
---@field color fun(self: self): Color
---@field set_color fun(self: self, color: Color)
---@field set_text fun(self: self, text: string)
---@field text_rect fun(self: self): x: number, y: number, w: number, h: number Returns rectangle of the text
---@field font_size fun(self: self): number
---@field set_font_size fun(self: self, font_size: number)
---@field set_size fun(self: self, w: number, h: number)

---@class PanelBitmap : PanelBaseObject
---@field color fun(self: self): Color
---@field set_color fun(self: self, color: Color)
---@field set_image fun(self: self, texture_path: string, texture_rect_x: number?, texture_rect_y: number?, texture_rect_w: number?, texture_rect_h: number?)
---@field set_texture_rect fun(self: self, x: number, y: number, w: number, h: number)
---@field set_size fun(self: self, w: number, h: number)

---@class PanelRectangle : PanelBaseObject
---@field color fun(self: self): Color
---@field set_color fun(self: self, color: Color)
---@field set_size fun(self: self, w: number, h: number)