local EHI = EHI
if EHI:CheckLoadHook("HUDManager") then
    return
end

local original =
{
    save = HUDManager.save,
    load = HUDManager.load
}

function HUDManager:AddWaypointSoft(id, data)
    self._hud.stored_waypoints[id] = data
    self._hud.ehi_removed_waypoints = self._hud.ehi_removed_waypoints or {}
    self._hud.ehi_removed_waypoints[id] = true
end

function HUDManager:SoftRemoveWaypoint(id)
    local init_data = self._hud.waypoints[id] and self._hud.waypoints[id].init_data
    if init_data then
        self:remove_waypoint(id)
        self:AddWaypointSoft(id, init_data)
    end
end

function HUDManager:RestoreWaypoint(id)
    local data = self._hud.stored_waypoints[id]
    if data then
        self:add_waypoint(id, data)
        self._hud.stored_waypoints[id] = nil
    end
    if type(self._hud.ehi_removed_waypoints) == "table" then
        self._hud.ehi_removed_waypoints[id] = nil
    end
end

function HUDManager:save(data, ...)
    original.save(self, data, ...)
    local state = data.HUDManager
    -- Sync hidden waypoints to ensure that unmodified clients will see them correctly
    for id, _ in pairs(self._hud.ehi_removed_waypoints or {}) do
        if self._hud.stored_waypoints[id] then
            state.waypoints[id] = self._hud.stored_waypoints[id]
        end
    end
end

function HUDManager:load(...)
    original.load(self, ...)
    for id, _ in pairs(self._hud.waypoints or {}) do
        if EHI._cache.IgnoreWaypoints[id] then
            self:SoftRemoveWaypoint(id)
        end
    end
end