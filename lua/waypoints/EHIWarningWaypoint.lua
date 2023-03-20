local function warning(o, icon, arrow, bitmap_world)
    while true do
        local t = 1
        while t > 0 do
            t = t - coroutine.yield()
            local n = math.sin(t * 180)
            local g = math.lerp(1, 0, n)
            local c = Color(1, g, g)
            o:set_color(c)
            icon:set_color(c)
            arrow:set_color(c)
            if bitmap_world then
                bitmap_world:set_color(c)
            end
        end
    end
end
EHIWarningWaypoint = class(EHIWaypoint)
function EHIWarningWaypoint:update(t, dt)
    EHIWarningWaypoint.super.update(self, t, dt)
    if self._time <= 10 and not self._warning_started then
        self:AnimateWarning()
        self._warning_started = true
    end
end

function EHIWarningWaypoint:AnimateWarning()
    self._timer:animate(warning, self._bitmap, self._arrow, self._bitmap_world)
end

function EHIWarningWaypoint:delete()
    if self._timer and alive(self._timer) then
        self._timer:stop()
    end
    EHIWarningWaypoint.super.delete(self)
end