local original =
{
    new = EHIWaypointManager.new,
    Save = VoidUI.Save
}

function EHIWaypointManager:new()
    self:UpdateValues()
    return original.new(self)
end

function EHIWaypointManager:UpdateValues()
    local scale = VoidUI.options.waypoint_scale
    self._bitmap_h = 32 * scale
    self._bitmap_w = 32 * scale
    self._distance_font_size = tweak_data.hud.default_font_size * scale
    self._timer_font_size = 32 * scale
end

function VoidUI:Save()
    original.Save(self)
    if managers.ehi_waypoint then
        managers.ehi_waypoint:UpdateValues()
    end
end