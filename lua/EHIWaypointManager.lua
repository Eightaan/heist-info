local icons = tweak_data.ehi.icons

local EHI = EHI
EHIWaypointManager = class()
EHIWaypointManager._font = tweak_data.menu.pd2_large_font_id -- Large font
EHIWaypointManager._timer_font_size = 32
EHIWaypointManager._distance_font_size = tweak_data.hud.default_font_size
EHIWaypointManager._bitmap_w = 32
EHIWaypointManager._bitmap_h = 32
function EHIWaypointManager:init()
    self._enabled = EHI:GetOption("show_waypoints")
    self._present_timer = EHI:GetOption("show_waypoints_present_timer")
    self._scale = 1
    self._stored_waypoints = {}
    self._waypoints = {}
    setmetatable(self._waypoints, {__mode = "k"})
    self._waypoints_to_update = {}
    setmetatable(self._waypoints_to_update, {__mode = "k"})
    self._pager_waypoints = {}
    self._t = 0
end

function EHIWaypointManager:init_finalize()
    if not self._enabled then
        return
    end
    EHI:AddOnAlarmCallback(callback(self, self, "RemoveAllPagerWaypoints"))
end

function EHIWaypointManager:LoadTime(t)
    self._t = t
end

function EHIWaypointManager:SetPlayerHUD(hud)
    self._hud = hud
    for id, params in pairs(self._stored_waypoints) do
        self:AddWaypoint(id, params)
    end
    self._stored_waypoints = {}
end

function EHIWaypointManager:AddWaypoint(id, params)
    if not self._enabled then
        return
    end
    if not self._hud then
        self._stored_waypoints[id] = params
        return
    end
    if self._waypoints[id] then
        self:RemoveWaypoint(id)
    end
    params.id = id
    params.timer = params.time or 0
    params.pause_timer = 1
    params.no_sync = true
    params.present_timer = params.present_timer or self._present_timer
    self._hud:add_waypoint(id, params)
    local waypoint = self._hud:get_waypoint_data(id)
    if not waypoint then
        return
    end
    if not (waypoint.bitmap and waypoint.timer_gui) then
        self._enabled = false -- Disable waypoints as they don't have correct fields
        self._hud:remove_waypoint(id)
        return
    end
    self:SetWaypointInitialIcon(waypoint, params)
    if waypoint.distance then
        waypoint.distance:set_font(self._font)
        waypoint.distance:set_font_size(self._distance_font_size)
    end
    waypoint.timer_gui:set_font(self._font)
    waypoint.timer_gui:set_font_size(self._timer_font_size)
    local w = _G[params.class or "EHIWaypoint"]:new(waypoint, params, self)
    if w._update then
        self._waypoints_to_update[id] = w
    end
    self._waypoints[id] = w
end

function EHIWaypointManager:RemoveWaypoint(id)
    if not self._waypoints[id] then
        return
    end
    self._waypoints[id]:destroy()
    self._waypoints[id] = nil
    self._waypoints_to_update[id] = nil
    self._hud:remove_waypoint(id)
end

function EHIWaypointManager:SetWaypointInitialIcon(wp, params)
    local bitmap = wp.bitmap
    local bitmap_world = wp.bitmap_world -- VR
    local icon, texture_rect
    if params.texture then
        icon = params.texture
        texture_rect = params.text_rect
    else
        local _icon = type(params.icon) == "table" and params.icon[1] or params.icon
        if icons[_icon] then
            icon = icons[_icon].texture
            texture_rect = icons[_icon].texture_rect
        else
            icon, texture_rect = tweak_data.hud_icons:get_icon_or(_icon, icons.default.texture, icons.default.texture_rect)
        end
    end
    if texture_rect then
        bitmap:set_image(icon, unpack(texture_rect))
    else
        bitmap:set_image(icon)
    end
    bitmap:set_size(self._bitmap_w, self._bitmap_h)
    wp.size = Vector3(self._bitmap_w, self._bitmap_h, 0)
    if bitmap_world then
        if texture_rect then
            bitmap_world:set_image(icon, unpack(texture_rect))
        else
            bitmap_world:set_image(icon)
        end
        bitmap_world:set_size(self._bitmap_w, self._bitmap_h)
    end
end

function EHIWaypointManager:SetWaypointIcon(id, new_icon)
    if id and self._waypoints[id] and self._waypoints[id]._bitmap then
        local wp = self._hud:get_waypoint_data(id)
        if not wp then
            return
        end
        local icon = { icon = new_icon }
        self:SetWaypointInitialIcon(wp, icon)
    end
end

function EHIWaypointManager:WaypointExists(id)
    return id and self._waypoints[id] or false
end

function EHIWaypointManager:WaypointDoesNotExist(id)
    return not self:WaypointExists(id)
end

function EHIWaypointManager:SetWaypointTime(id, time)
    local wp = self._waypoints[id]
    if wp then
        wp:SetTime(time)
    end
end

function EHIWaypointManager:SetTimerWaypointJammed(id, jammed)
    local wp = self._waypoints[id]
    if wp and wp.SetJammed then
        wp:SetJammed(jammed)
    end
end

function EHIWaypointManager:SetTimerWaypointPowered(id, powered)
    local wp = self._waypoints[id]
    if wp and wp.SetPowered then
        wp:SetPowered(powered)
    end
end

function EHIWaypointManager:SetTimerWaypointRunning(id)
    local wp = self._waypoints[id]
    if wp and wp.SetRunning then
        wp:SetRunning()
    end
end

function EHIWaypointManager:SetWaypointPause(id, pause)
    local wp = self._waypoints[id]
    if wp and wp.SetPaused then
        wp:SetPaused(pause)
    end
end

function EHIWaypointManager:PauseWaypoint(id)
    self:SetWaypointPause(id, true)
end

function EHIWaypointManager:UnpauseWaypoint(id)
    self:SetWaypointPause(id, false)
end

function EHIWaypointManager:AddPagerWaypoint(params)
    self._pager_waypoints[params.id] = true
    self:AddWaypoint(params.id, params)
end

function EHIWaypointManager:RemoveAllPagerWaypoints()
    for key, _ in pairs(self._pager_waypoints) do
        self:RemoveWaypoint(key)
    end
end

function EHIWaypointManager:AddWaypointToUpdate(id, wp)
    self._waypoints_to_update[id] = wp
end

function EHIWaypointManager:RemoveWaypointFromUpdate(id)
    self._waypoints_to_update[id] = nil
end

function EHIWaypointManager:update(t, dt)
    for _, waypoint in pairs(self._waypoints_to_update) do
        waypoint:update(t, dt)
    end
end

function EHIWaypointManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(self._t, dt)
end

function EHIWaypointManager:destroy()
    for key, _ in pairs(self._waypoints) do
        self._waypoints[key] = nil
    end
end

function EHIWaypointManager:CallFunction(id, f, ...)
    local wp = self._waypoints[id]
    if wp and wp[f] then
        wp[f](wp, ...)
    end
end

do
    local path = EHI.LuaPath .. "waypoints/"
    dofile(path .. "EHIWaypoint.lua")
    dofile(path .. "EHIWarningWaypoint.lua")
    dofile(path .. "EHIPausableWaypoint.lua")
    dofile(path .. "EHITimerWaypoint.lua")
end

if _G.IS_VR then
    if restoration and restoration.Options and restoration.Options:GetValue("HUD/Waypoints") then
        -- Use Vanilla texture file because Restoration HUD does not have the icons
        -- Reported here: https://modworkshop.net/mod/28118
        -- Don't forget to remove it from Restoration Mod theme file too when it is fixed
        tweak_data.hud_icons.pd2_car.texture = "guis/textures/pd2/pd2_waypoints"
        tweak_data.hud_icons.pd2_water_tap.texture = "guis/textures/pd2/pd2_waypoints"
    end
    return
end

if VoidUI and VoidUI.options.enable_waypoints then
    dofile(EHI.LuaPath .. "hud/waypoint/void_ui.lua")
elseif restoration and restoration.Options and restoration.Options:GetValue("HUD/Waypoints") then
    dofile(EHI.LuaPath .. "hud/waypoint/restoration_mod.lua")
end