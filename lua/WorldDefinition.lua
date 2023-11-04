local EHI = EHI
if EHI:CheckLoadHook("WorldDefinition") then
    return
end

---@class WorldDefinition
---@field get_unit fun(self: self, id: number): Unit?

function EHI:FinalizeUnitsClient()
    self:FinalizeUnits(self._cache.MissionUnits)
    self:FinalizeUnits(self._cache.InstanceUnits)
end

---@param tbl table<number, UnitUpdateDefinition>
function EHI:FinalizeUnits(tbl)
    local wd = managers.worlddefinition
    for id, unit_data in pairs(tbl) do
        local unit = wd:get_unit(id)
        if unit then
            if unit_data.f then
                if type(unit_data.f) == "string" then
                    wd[unit_data.f](wd, id, unit_data, unit)
                else
                    unit_data.f(id, unit_data, unit)
                end
            else
                local timer_gui = unit:timer_gui()
                local digital_gui = unit:digital_gui()
                if timer_gui and timer_gui._ehi_key then
                    if unit_data.child_units then
                        timer_gui:SetChildUnits(unit_data.child_units, wd)
                    end
                    timer_gui:SetIcons(unit_data.icons)
                    timer_gui:SetRemoveOnPowerOff(unit_data.remove_on_power_off)
                    if unit_data.disable_set_visible then
                        timer_gui:DisableOnSetVisible()
                    end
                    if unit_data.remove_on_alarm then
                        timer_gui:SetOnAlarm()
                    end
                    if unit_data.remove_vanilla_waypoint then
                        timer_gui:RemoveVanillaWaypoint(unit_data.remove_vanilla_waypoint)
                        if unit_data.restore_waypoint_on_done then
                            timer_gui:SetRestoreVanillaWaypointOnDone()
                        end
                    end
                    if unit_data.ignore_visibility then
                        timer_gui:SetIgnoreVisibility()
                    end
                    if unit_data.set_custom_id then
                        timer_gui:SetCustomID(unit_data.set_custom_id)
                    end
                    if unit_data.tracker_merge_id then
                        timer_gui:SetTrackerMergeID(unit_data.tracker_merge_id, unit_data.destroy_tracker_merge_on_done)
                    end
                    if unit_data.custom_callback then
                        timer_gui:SetCustomCallback(unit_data.custom_callback.id, unit_data.custom_callback.f)
                    end
                    timer_gui:SetWaypointPosition(unit_data.position)
                    timer_gui:Finalize()
                end
                if digital_gui and digital_gui._ehi_key then
                    digital_gui:SetIcons(unit_data.icons)
                    digital_gui:SetIgnore(unit_data.ignore)
                    digital_gui:SetRemoveOnPause(unit_data.remove_on_pause)
                    digital_gui:SetWarning(unit_data.warning)
                    digital_gui:SetCompletion(unit_data.completion)
                    if unit_data.remove_on_alarm then
                        digital_gui:SetOnAlarm()
                    end
                    if unit_data.custom_callback then
                        digital_gui:SetCustomCallback(unit_data.custom_callback.id, unit_data.custom_callback.f)
                    end
                    if unit_data.icon_on_pause then
                        digital_gui:SetIconOnPause(unit_data.icon_on_pause[1])
                    end
                    if unit_data.remove_vanilla_waypoint then
                        digital_gui:RemoveVanillaWaypoint(unit_data.remove_vanilla_waypoint)
                    end
                    if unit_data.ignore_visibility then
                        digital_gui:SetIgnoreVisibility()
                    end
                    digital_gui:Finalize()
                end
            end
            -- Clear configured unit from the table
            tbl[id] = nil
        end
    end
end

local units = {}
EHI:HookWithID(WorldDefinition, "init", "EHI_WorldDefinition_init", function(...)
    units = tweak_data.ehi.units
end)

EHI:HookWithID(WorldDefinition, "create", "EHI_WorldDefinition_create", function(self, ...)
    if self._definition.statics then
        for _, values in ipairs(self._definition.statics) do
            if units[values.unit_data.name] and not values.unit_data.instance then
                EHI._cache.MissionUnits[values.unit_data.unit_id] = units[values.unit_data.name]
            end
        end
    end
    for _, continent in pairs(self._continent_definitions) do
        if continent.statics then
            for _, values in ipairs(continent.statics) do
                if units[values.unit_data.name] and not values.unit_data.instance then
                    EHI._cache.MissionUnits[values.unit_data.unit_id] = units[values.unit_data.name]
                end
            end
        end
    end
end)

EHI:PreHookWithID(WorldDefinition, "init_done", "EHI_WorldDefinition_init_done", function(...)
    EHI:FinalizeUnits(EHI._cache.MissionUnits)
    EHI:FinalizeUnits(EHI._cache.InstanceUnits)
end)

function WorldDefinition:IgnoreDeployable(unit_id, unit_data, unit)
    if unit:base() and unit:base().SetIgnore then
        unit:base():SetIgnore()
    end
end

function WorldDefinition:IgnoreChildDeployable(unit_id, unit_data, unit)
    if unit:base() and unit:base().SetIgnoreChild then
        unit:base():SetIgnoreChild()
    end
end

function WorldDefinition:SetDeployableOffset(unit_id, unit_data, unit)
    if unit:base() and unit:base().SetOffset then
        unit:base():SetOffset(unit_data.offset or 1)
    end
end

function WorldDefinition:chasC4(unit_id, unit_data, unit)
    if not unit:digital_gui()._ehi_key then
        return
    end
    if not unit_data.instance then
        unit:digital_gui():SetIcons(unit_data.icons)
        return
    end
    if EHI:GetBaseUnitID(unit_id, unit_data.instance.start_index, unit_data.continent_index) == 100054 then
        unit:digital_gui():SetIcons(unit_data.icons)
    else
        unit:digital_gui():SetIgnore(true)
    end
end