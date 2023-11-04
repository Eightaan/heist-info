local color = EHI:GetTWColor("inaccurate")
---@class EHIInaccurateWaypoint: EHIWaypoint
---@field super EHIWaypoint
EHIInaccurateWaypoint = class(EHIWaypoint)
EHIInaccurateWaypoint._default_color = color
function EHIInaccurateWaypoint:post_init(params)
    self:SetColor()
end

function EHIInaccurateWaypoint:SetWaypointAccurate(time)
    self._default_color = Color.white
    self:SetColor()
    self:SetTime(time)
end

---@class EHIInaccuratePausableWaypoint: EHIPausableWaypoint
EHIInaccuratePausableWaypoint = class(EHIPausableWaypoint)
EHIInaccuratePausableWaypoint._default_color = color
EHIInaccuratePausableWaypoint.SetWaypointAccurate = EHIInaccurateWaypoint.SetWaypointAccurate

---@class EHIInaccurateWarningWaypoint: EHIWarningWaypoint
EHIInaccurateWarningWaypoint = class(EHIWarningWaypoint)
EHIInaccurateWarningWaypoint._default_color = color
EHIInaccurateWarningWaypoint.SetWaypointAccurate = EHIInaccurateWaypoint.SetWaypointAccurate