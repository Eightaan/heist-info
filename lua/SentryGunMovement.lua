local EHI = EHI
if EHI:CheckLoadHook("SentryGunMovement") or not EHI:GetOption("show_enemy_turret_trackers") then
    return
end

local Icon = EHI.Icons
local WWarning = EHI.Waypoints.Warning

local show_waypoints = EHI:GetOption("show_waypoints_enemy_turret")
local show_waypoint_only = show_waypoints and EHI:GetWaypointOption("show_waypoints_only")

local original =
{
    init = SentryGunMovement.init,
    on_activated = SentryGunMovement.on_activated,
    rearm = SentryGunMovement.rearm,
    repair = SentryGunMovement.repair,
    load = SentryGunMovement.load,
    on_death = SentryGunMovement.on_death,
    pre_destroy = SentryGunMovement.pre_destroy
}

function SentryGunMovement:init(unit, ...)
    original.init(self, unit, ...)
    local key = tostring(unit:key())
    self._ehi_key_reload = key .. "_reload"
    self._ehi_key_repair = key .. "_repair"
end

function SentryGunMovement:Preload()
    if self._ehi_preloaded then
        return
    end
    if not show_waypoint_only then
        local Warning = EHI.Trackers.Warning
        if self._tweak.AUTO_RELOAD then
            managers.ehi:PreloadTracker({
                id = self._ehi_key_reload,
                icons = { Icon.Sentry, "reload" },
                hide_on_delete = true,
                class = Warning
            })
        end
        if self._tweak.AUTO_REPAIR then
            managers.ehi:PreloadTracker({
                id = self._ehi_key_repair,
                icons = { Icon.Sentry, Icon.Fix },
                hide_on_delete = true,
                class = Warning
            })
        end
    end
    self._ehi_preloaded = true
end

function SentryGunMovement:on_activated(...)
    original.on_activated(self, ...)
    self:Preload()
end

function SentryGunMovement:rearm(...)
    original.rearm(self, ...)
    local t = self._tweak.AUTO_RELOAD_DURATION -- 8s
    managers.ehi:RunTracker(self._ehi_key_reload, { time = t })
    if show_waypoints then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_reload, {
            time = t,
            texture = "guis/textures/pd2/skilltree/icons_atlas",
            text_rect = {0, 576, 64, 64},
            unit = self._unit,
            class = WWarning
        })
    end
end

function SentryGunMovement:repair(...)
    original.repair(self, ...)
    managers.ehi:RemoveTracker(self._ehi_key_reload)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_reload)
    local t = self._tweak.AUTO_REPAIR_DURATION -- 30s
    managers.ehi:RunTracker(self._ehi_key_repair, { time = t })
    if show_waypoints then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_repair, {
            time = t,
            icon = "pd2_fix",
            unit = self._unit,
            class = WWarning
        })
    end
end

function SentryGunMovement:load(save_data, ...)
    original.load(self, save_data, ...)
    if not save_data or not save_data.movement then
		return
	end
    self:Preload()
end

function SentryGunMovement:on_death(...)
    original.on_death(self, ...)
    managers.ehi:ForceRemoveTracker(self._ehi_key_reload)
    managers.ehi:ForceRemoveTracker(self._ehi_key_repair)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_reload)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_repair)
end

function SentryGunMovement:pre_destroy(...)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_reload)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_repair)
    original.pre_destroy(self, ...)
end