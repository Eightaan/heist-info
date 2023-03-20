if EHI:CheckLoadHook("QuickCsGrenade") then
    return
end
local Icon = EHI.Icons

local _f_detonate = QuickCsGrenade.detonate
function QuickCsGrenade:detonate(...)
    _f_detonate(self, ...)
    local key = tostring(self._unit:key())
    managers.ehi:AddTracker({
        id = key,
        time = self._duration,
        icons = { Icon.Sentry, Icon.Teargas }
    })
    managers.ehi_waypoint:AddWaypoint(key, {
        time = self._duration,
        icon = Icon.Teargas,
        position = self._unit:position()
    })
end