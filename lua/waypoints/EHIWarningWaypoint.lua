local lerp = math.lerp
local sin = math.sin
local Color = Color
local function anim(o, old_color, color, icon, arrow, bitmap_world)
    local c = Color(old_color.r, old_color.g, old_color.b)
    while true do
        local t = 1
        while t > 0 do
            t = t - coroutine.yield()
            local n = sin(t * 180)
            c.r = lerp(old_color.r, color.r, n)
            c.g = lerp(old_color.g, color.g, n)
            c.b = lerp(old_color.b, color.b, n)
            o:set_color(c)
            icon:set_color(c)
            arrow:set_color(c)
            if bitmap_world then
                bitmap_world:set_color(c)
            end
        end
    end
end
---@class EHIWarningWaypoint: EHIWaypoint
---@field super EHIWaypoint
EHIWarningWaypoint = class(EHIWaypoint)
EHIWarningWaypoint._warning_color = EHI:GetTWColor("warning")
function EHIWarningWaypoint:update(t, dt)
    EHIWarningWaypoint.super.update(self, t, dt)
    if self._time <= 10 and not self._anim_started then
        self:AnimateColor()
        self._anim_started = true
    end
end

function EHIWarningWaypoint:AnimateColor(color)
    if self._timer and alive(self._timer) then
        self._timer:animate(anim, self._default_color, color or self._warning_color, self._bitmap, self._arrow, self._bitmap_world)
    end
end

function EHIWarningWaypoint:delete()
    if self._timer and alive(self._timer) then
        self._timer:stop()
    end
    EHIWarningWaypoint.super.delete(self)
end