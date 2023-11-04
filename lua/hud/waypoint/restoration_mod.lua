local tweak_data = tweak_data
local original =
{
    AddWaypoint = EHIWaypointManager.AddWaypoint
}

EHIWaypointManager._font = Idstring(tweak_data.menu.medium_font)
EHIWaypointManager._timer_font_size = 20
EHIWaypointManager._distance_font_size = 32
---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:AddWaypoint(id, params)
    params.distance = true
    original.AddWaypoint(self, id, params)
end

-- Use Vanilla texture file because Restoration HUD does not have the icons
-- Reported here: https://modworkshop.net/mod/28118
-- Don't forget to remove it from VR too when it is fixed
tweak_data.hud_icons.pd2_car.texture = "guis/textures/pd2/pd2_waypoints"
tweak_data.hud_icons.pd2_water_tap.texture = "guis/textures/pd2/pd2_waypoints"

EHIWaypoint._default_color = tweak_data.hud.prime_color