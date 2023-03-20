local EHI = EHI
if EHI:CheckLoadHook("ZipLine") or not EHI:GetOption("show_zipline_timer") then
    return
end

local Icon = EHI.Icons

local show_waypoint = EHI:GetWaypointOption("show_waypoints_zipline")
local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")

local original =
{
    init = ZipLine.init,
    update = ZipLine.update,
    release_bag = ZipLine.release_bag,
    set_usage_type = ZipLine.set_usage_type,
    attach_bag = ZipLine.attach_bag,
    set_user = ZipLine.set_user,
    sync_set_user = ZipLine.sync_set_user,
    destroy = ZipLine.destroy
}

function ZipLine:init(unit, ...)
    original.init(self, unit, ...)
    local key = tostring(unit:key())
    self._ehi_key_bag_half = key .. "_bag_drop"
    self._ehi_key_bag_full = key .. "_bag_reset"
    self._ehi_key_user_half = key .. "_person_drop"
    self._ehi_key_user_full = key .. "_person_reset"
    if not show_waypoint_only then
        managers.ehi:PreloadTracker({
            id = self._ehi_key_bag_half,
            icons = { Icon.Winch, Icon.Loot, Icon.Goto },
            hide_on_delete = true
        })
        managers.ehi:PreloadTracker({
            id = self._ehi_key_bag_full,
            icons = { Icon.Winch, Icon.Loop },
            hide_on_delete = true
        })
        managers.ehi:PreloadTracker({
            id = self._ehi_key_user_half,
            icons = { Icon.Winch, Icon.Escape, Icon.Goto },
            hide_on_delete = true
        })
        managers.ehi:PreloadTracker({
            id = self._ehi_key_user_full,
            icons = { Icon.Winch, Icon.Loop },
            hide_on_delete = true
        })
    end
    if self:is_usage_type_bag() then
        self:HookUpdateLoop()
    end
end

function ZipLine:HookUpdateLoop()
    if self._update_hooked then
        return
    end
    self.update = function(self, ...)
        original.update(self, ...)
        if self._ehi_bag_attached and not self._attached_bag then
            self._ehi_bag_attached = nil
            local t = self:total_time() * self._current_time
            managers.ehi:RemoveTracker(self._ehi_key_bag_half)
            managers.ehi:SetTrackerTimeNoAnim(self._ehi_key_bag_full, t)
            managers.ehi_waypoint:SetWaypointTime(self._ehi_key_bag_full, t)
        end
    end
    self._update_hooked = true
end

function ZipLine:UnhookUpdateLoop()
    self.update = original.update
    self._update_hooked = nil
end

function ZipLine:set_usage_type(...)
    original.set_usage_type(self, ...)
    if self:is_usage_type_bag() then
        self:HookUpdateLoop()
    else
        self:UnhookUpdateLoop()
    end
end

function ZipLine:release_bag(...)
    original.release_bag(self, ...)
    self._ehi_bag_attached = nil
end

function ZipLine:GetMovingObject()
    return self._sled_data.object or self._unit
end

function ZipLine:attach_bag(...)
    original.attach_bag(self, ...)
    local total_time = self:total_time()
    local total_time_2 = total_time * 2
    managers.ehi:RunTracker(self._ehi_key_bag_half, { time = total_time })
    managers.ehi:RunTracker(self._ehi_key_bag_full, { time = total_time_2 })
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_bag_full, {
            time = total_time_2,
            icon = Icon.Winch,
            unit = self:GetMovingObject()
        })
    end
    self._ehi_bag_attached = true
end

local function AddUserZipline(self, unit)
    if not unit then
        return
    end
    local total_time = self:total_time()
    local total_time_2 = total_time * 2
    managers.ehi:RunTracker(self._ehi_key_user_half, { time = total_time })
    managers.ehi:RunTracker(self._ehi_key_user_full, { time = total_time_2 })
    if show_waypoint then
        local local_unit = unit == managers.player:player_unit()
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_user_full, {
            time = total_time_2,
            present_timer = local_unit and total_time,
            icon = Icon.Winch,
            unit = self:GetMovingObject()
        })
    end
end

function ZipLine:set_user(unit, ...)
    AddUserZipline(self, unit)
    original.set_user(self, unit, ...)
end

function ZipLine:sync_set_user(unit, ...)
    AddUserZipline(self, unit)
    original.sync_set_user(self, unit, ...)
end

function ZipLine:destroy(...)
    managers.ehi:ForceRemoveTracker(self._ehi_key_bag_half)
    managers.ehi:ForceRemoveTracker(self._ehi_key_bag_full)
    managers.ehi:ForceRemoveTracker(self._ehi_key_user_half)
    managers.ehi:ForceRemoveTracker(self._ehi_key_user_full)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_bag_full)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_user_full)
    original.destroy(self, ...)
end