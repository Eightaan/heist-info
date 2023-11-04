local EHI = EHI
if EHI:CheckLoadHook("CoreWorldInstanceManager") then
    return
end
EHI:Init()
local debug_instance = false
local debug_unit = false
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers -- Tracker Type
local used_start_indexes = {}
---@type ParseInstanceTable
local instances =
{
    ["levels/instances/shared/obj_skm/world"] = -- Hostage in the Holdout mode
    {
        [100032] = { time = 7, id = "skm_HostageRescue", icons = { Icon.Kill }, class = TT.Warning },
        [100036] = { id = "skm_HostageRescue", special_function = SF.RemoveTracker }
    },
    ["levels/instances/unique/hlm_reader/world"] =
    {
        [100038] = { time = 90 + 1.5, id = "mia_1_Reader", icons = { Icon.PCHack }, class = TT.Pausable, waypoint = { position_by_element_and_remove_vanilla_waypoint = 100060, restore_on_done = true } },
        [100039] = { time = 120 + 1.5, id = "mia_1_Reader", icons = { Icon.PCHack }, class = TT.Pausable, waypoint = { position_by_element_and_remove_vanilla_waypoint = 100060, restore_on_done = true } },
        [100040] = { time = 180 + 1.5, id = "mia_1_Reader", icons = { Icon.PCHack }, class = TT.Pausable, waypoint = { position_by_element_and_remove_vanilla_waypoint = 100060, restore_on_done = true } },
        [100045] = { id = "mia_1_Reader", special_function = SF.PauseTracker },
        [100051] = { id = "mia_1_Reader", special_function = SF.UnpauseTracker }
    },
    ["levels/instances/unique/pbr/pbr_mountain_comm_dish/world"] =
    {
        [100008] = { time = 5, id = "pbr_SatelliteC4Explosion", icons = { Icon.C4 }, waypoint = { position_by_unit = 100022 } }
    },
    ["levels/instances/unique/pbr/pbr_mountain_comm_dish_huge/world"] =
    {
        [100013] = { time = 5, id = "pbr_HugeSatelliteC4Explosion", icons = { Icon.C4 }, waypoint = { position_by_unit = 100000 } }
    },
    ["levels/instances/unique/pbr/pbr_flare/world"] =
    {
        [100024] = { time = 60, id = "pbr2_Flare", icons = { Icon.Heli, Icon.Winch }, waypoint = { icon = Icon.Winch, position_by_element = 100017 } }
    },
    ["levels/instances/unique/brb/single_door/world"] =
    {
        [100021] = { remove_vanilla_waypoint = true }, -- Defend
        [100022] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/rvd/rvd_hackbox/world"] =
    {
        [100034] = { remove_vanilla_waypoint = true }, -- Defend
        [100031] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/fex/fex_explosives/world"] =
    {
        [100008] = { time = 60, id = "fex_ExplosivesTimer", icons = { "equipment_timer" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [100007] = { id = "fex_ExplosivesTimer", special_function = SF.PauseTracker }
    },
    ["levels/instances/unique/sand/sand_helicopter_turret/world"] =
    {
        [100027] = { id = "sand_TurretTimer", icons = { Icon.Heli, Icon.Turret, Icon.Wait }, special_function = SF.GetElementTimerAccurate, element = 100012 }
    }
}
instances["levels/instances/unique/brb/single_door_large/world"] = deep_clone(instances["levels/instances/unique/brb/single_door/world"])

if EHI:IsClient() then
    instances["levels/instances/unique/pbr/pbr_flare/world"][100025] = EHI:ClientCopyTrigger(instances["levels/instances/unique/pbr/pbr_flare/world"][100024], { time = 27 })
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"][100027].client = { time = EHI:IsDifficulty(EHI.Difficulties.DeathSentence) and 90 or 60, random_time = 30 }
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"][100024] = { id = "sand_TurretTimer", special_function = SF.RemoveTracker }
end

local original =
{
    prepare_mission_data = CoreWorldInstanceManager.prepare_mission_data,
    prepare_unit_data = CoreWorldInstanceManager.prepare_unit_data,
    custom_create_instance = CoreWorldInstanceManager.custom_create_instance
}

---@param instance { folder: string, start_index: number, continent: string, rotation: Rotation }
---@param ... unknown
---@return unknown
function CoreWorldInstanceManager:prepare_mission_data(instance, ...)
    local instance_data = original.prepare_mission_data(self, instance, ...)
    local folder = instance.folder
    if instances[folder] then
        local start_index = instance.start_index
        if not used_start_indexes[start_index] then
            -- Don't compute the indexes again if the instance on this start_index has been computed already
            -- start_index is unique for each instance in a heist, so this shouldn't break anything
            local instance_elements = instances[folder]
            ---@type { base_id: number }
            local continent_data = managers.worlddefinition._continents[instance.continent]
            local triggers = {}
            local waypoints = {}
            local defer_loading_waypoints = false
            for id, trigger in pairs(instance_elements) do
                local final_index = EHI:GetInstanceElementID(id, start_index, continent_data.base_id)
                if trigger.remove_vanilla_waypoint then
                    waypoints[final_index] = true
                else
                    ---@type ElementTrigger
                    local new_trigger = deep_clone(trigger)
                    new_trigger.id = new_trigger.id .. start_index
                    if trigger.element then
                        new_trigger.element = EHI:GetInstanceElementID(trigger.element, start_index, continent_data.base_id)
                    end
                    if trigger.waypoint then
                        if trigger.waypoint.position_by_element_and_remove_vanilla_waypoint then
                            local wp_id = EHI:GetInstanceElementID(trigger.waypoint.position_by_element_and_remove_vanilla_waypoint, start_index, continent_data.base_id)
                            new_trigger.waypoint.position_by_element = wp_id
                            new_trigger.waypoint.remove_vanilla_waypoint = wp_id
                            new_trigger.waypoint.position_by_element_and_remove_vanilla_waypoint = nil
                            defer_loading_waypoints = true
                        end
                        if trigger.waypoint.position_by_element then
                            new_trigger.waypoint.position_by_element = EHI:GetInstanceElementID(trigger.waypoint.position_by_element, start_index, continent_data.base_id)
                            defer_loading_waypoints = true
                        end
                        if trigger.waypoint.position_by_unit then
                            new_trigger.waypoint.position_by_unit = EHI:GetInstanceUnitID(trigger.waypoint.position_by_unit, start_index, continent_data.base_id)
                            defer_loading_waypoints = true
                        end
                        if trigger.waypoint.remove_vanilla_waypoint then
                            new_trigger.waypoint.remove_vanilla_waypoint = EHI:GetInstanceElementID(trigger.waypoint.remove_vanilla_waypoint, start_index, continent_data.base_id)
                        end
                    end
                    triggers[final_index] = new_trigger
                end
            end
            EHI:ParseMissionInstanceTriggers(triggers, defer_loading_waypoints)
            if next(waypoints) then
                EHI:DisableWaypoints(waypoints)
            end
            used_start_indexes[start_index] = true
        end
    end
    if debug_instance then
        EHI:Log("---------------SEPARATOR---------------")
        EHI:Log("Instance Folder: " .. tostring(folder))
        EHI:Log("Instance Start Index: " .. tostring(instance.start_index))
        EHI:Log("Instance Rotation: " .. tostring(instance.rotation))
    end
    return instance_data
end

local units = {}
function CoreWorldInstanceManager:prepare_unit_data(instance, continent_data, ...)
    local instance_data = original.prepare_unit_data(self, instance, continent_data, ...)
    for _, entry in ipairs(instance_data.statics or {}) do
        if units[entry.unit_data.name] then
            local unit_data = deep_clone(units[entry.unit_data.name])
            unit_data.instance = instance
            unit_data.continent_index = continent_data.base_id
            if unit_data.remove_vanilla_waypoint then
                unit_data.remove_vanilla_waypoint = EHI:GetInstanceElementID(unit_data.remove_vanilla_waypoint, instance.start_index, continent_data.base_id)
            end
            EHI._cache.InstanceUnits[entry.unit_data.unit_id] = unit_data
        end
    end
    return instance_data
end

function CoreWorldInstanceManager:custom_create_instance(instance_name, ...)
    original.custom_create_instance(self, instance_name, ...)
	local instance = self:get_instance_data_by_name(instance_name)
	if not instance then
		return
	end
    EHI:FinalizeUnits(EHI._cache.InstanceUnits)
end

EHI:HookWithID(CoreWorldInstanceManager, "init", "EHI_CoreWorldInstanceManager_init", function(...)
    units = tweak_data.ehi.units
end)