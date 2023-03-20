local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local EscapeArrivalDelay = 674/30
local triggers = {
    [100006] = { time = 120, id = "LiquidNitrogen", icons = { Icon.LiquidNitrogen } },
    [100075] = { time = 120 + EscapeArrivalDelay, id = "Escape", icons = Icon.CarEscape, waypoint = { position_by_element = 100209 } }
}
if EHI:IsClient() then
    triggers[100082] = { time = EscapeArrivalDelay, id = "Escape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { position_by_element = 100209 } }
end

local other = {
    [100032] = EHI:AddAssaultDelay({ time = 1 + 30, trigger_times = 1 })
}

local function AddWaypoint(self, icon_name, pos_z_offset, ...)
    if self._is_active then
        self:remove_waypoint()
    end
    self._icon_name = icon_name
    self._pos_z_offset = Vector3(0, 0, pos_z_offset)
    self._is_active = true
end
local function ReplaceWaypointAddFunction(unit_id, unit_data, unit)
    unit:waypoint().add_waypoint = AddWaypoint
end
local tbl =
{
    [101975] = { f = ReplaceWaypointAddFunction },
    [101980] = { f = ReplaceWaypointAddFunction },
    [101981] = { f = ReplaceWaypointAddFunction },
    [101982] = { f = ReplaceWaypointAddFunction },
    [102184] = { f = ReplaceWaypointAddFunction },
    [102185] = { f = ReplaceWaypointAddFunction },
    [102186] = { f = ReplaceWaypointAddFunction },
    [102187] = { f = ReplaceWaypointAddFunction },
    [102188] = { f = ReplaceWaypointAddFunction }
}
EHI:UpdateUnits(tbl)

EHI:ParseTriggers({
    mission = triggers,
    other = other
})