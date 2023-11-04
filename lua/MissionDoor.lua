local EHI = EHI
if EHI:CheckLoadHook("MissionDoor") then
    return
end
local C4 = EHI.Icons.C4

local function StartC4Sequence(unit)
    local key = tostring(unit:key())
    managers.ehi_tracker:AddTracker({
        id = key,
        time = 5,
        icons = { C4 }
    })
    managers.ehi_waypoint:AddWaypoint(key, {
        time = 5,
        icon = C4,
        position = unit:position()
    })
end

if EHI:IsHost() then
    local initiate_c4_sequence = MissionDoor._initiate_c4_sequence
    function MissionDoor:_initiate_c4_sequence(...)
        initiate_c4_sequence(self, ...)
        StartC4Sequence(self._unit)
    end
else
    local run_mission_door_device_sequence = MissionDoor.run_mission_door_device_sequence
    function MissionDoor.run_mission_door_device_sequence(unit, sequence_name, ...)
        if sequence_name == "activate_explode_sequence" and unit:damage():has_sequence(sequence_name) then
            StartC4Sequence(unit)
        end
        run_mission_door_device_sequence(unit, sequence_name, ...)
    end
end

if EHI.debug.mission_door and EHI:IsHost() then
    EHI._cache.MissionDoor = {}
    local _f_init = MissionDoor.init
    function MissionDoor:init(...)
        _f_init(self, ...)
        if self.tweak_data then
            local devices_data = tweak_data.mission_door[self.tweak_data].devices or {}
            local drill_data = devices_data.drill
            if not drill_data then
                return
            end
            local unit_key = tostring(self._unit:key())
            EHI._cache.MissionDoor[self.tweak_data] = EHI._cache.MissionDoor[self.tweak_data] or {}
            EHI._cache.MissionDoor[self.tweak_data][unit_key] = { unit = self._unit, positions = {} }
            local tbl = EHI._cache.MissionDoor[self.tweak_data][unit_key]
            for i, data in ipairs(drill_data) do
                local a_obj = self._unit:get_object(Idstring(data.align))
			    local position = a_obj:position()
                tbl.positions[i] = position
            end
        end
    end

    local definition = {}
    local continent_definitions = {}
    local continents = {}
    EHI:HookWithID(IngameWaitingForPlayersState, "at_enter", "EHI_MissionDoorDebug", function(...)
        local MissionDoor = EHI._cache.MissionDoor
        local world_instance = managers.world_instance
        local instance_data = world_instance:instance_data()
        if MissionDoor then
            local name_found = false
            for tweak_name, tbl in pairs(MissionDoor) do
                EHI:Log("tweak_name: " .. tostring(tweak_name))
                for _, value in pairs(tbl) do
                    local unit_id = value.unit:editor_id()
                    EHI:Log("Unit ID: " .. unit_id)
                    if definition.statics then
                        for _, values in ipairs(definition.statics) do
                            if values.unit_data.unit_id == unit_id then
                                EHI:Log("Unit Path: " .. tostring(values.unit_data.name))
                                name_found = true
                                break
                            end
                        end
                    end
                    if not name_found then
                        for _, continent in pairs(continent_definitions) do
                            if continent.statics then
                                for _, values in ipairs(continent.statics) do
                                    if values.unit_data.unit_id == unit_id then
                                        EHI:Log("Unit Path: " .. tostring(values.unit_data.name))
                                        name_found = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    if not name_found then -- Path not found
                        if unit_id >= 130000 then
                            for i, instance in ipairs(instance_data) do
                                local continent_data = continents[instance.continent] or {}
                                local continent_base_id = continent_data.base_id or 100000
                                local computed_instance_range_start = EHI:GetInstanceElementID(100000, instance.start_index, continent_base_id)
                                local computed_instance_range_end = computed_instance_range_start + instance.index_size - 1
                                if unit_id >= computed_instance_range_start and unit_id <= computed_instance_range_end then
                                    EHI:Log("Unit found in instance '" .. tostring(instance.name) .. "'")
                                    EHI:Log("Instance Path: " .. tostring(instance.folder))
                                    local i_data = world_instance:_get_instance_continent_data(instance.folder .. "/world")
                                    local base_unit_id = EHI:GetBaseUnitID(unit_id, instance.start_index, continent_base_id)
                                    for _, values in ipairs(i_data.statics) do
                                        if values.unit_data.unit_id == base_unit_id then
                                            EHI:Log("Unit Base ID: " .. base_unit_id)
                                            EHI:Log("Unit Path: " .. tostring(values.unit_data.name))
                                            break
                                        end
                                    end
                                    break
                                end
                            end
                        else
                            EHI:Log("Unit Path not found in default 'World' continent!")
                            EHI:Log("Unit Position: " .. tostring(value.unit:position()))
                        end
                    end
                    for i, pos in ipairs(value.positions) do
                        EHI:Log(string.format("Position %d: %s", i, tostring(pos)))
                    end
                    name_found = false
                    EHI:Log("-------------Unit Separator-------------")
                end
                EHI:Log("-------------Tweak Name Separator-------------")
            end
        end
        definition = nil
        continent_definitions = nil
        continents = nil
    end)

    EHI:PreHookWithID(WorldDefinition, "init_done", "EHI_MissionDoorDebug_WorldDefinition", function(self, ...)
        -- These fields are nilled when loading finishes, clone them so I can check for path
        definition = deep_clone(self._definition)
        continent_definitions = deep_clone(self._continent_definitions)
        continents = deep_clone(self._continents)
    end)
end