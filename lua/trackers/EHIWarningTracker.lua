local EHI = EHI
local lerp = math.lerp
local sin = math.sin
local min = math.min
local floor = math.floor
local Color = Color
local function anim(o, old_color, color, start_t)
    local c = Color(old_color.r, old_color.g, old_color.b)
    while true do
        local t = start_t
        while t > 0 do
            t = t - coroutine.yield()
            local n = sin(t * 180)
            c.r = lerp(old_color.r, color.r, n)
            c.g = lerp(old_color.g, color.g, n)
            c.b = lerp(old_color.b, color.b, n)
            o:set_color(c)
        end
        start_t = 1
    end
end
---@class EHIWarningTracker : EHITracker
---@field super EHITracker
EHIWarningTracker = class(EHITracker)
EHIWarningTracker._warning_color = EHI:GetTWColor("warning")
EHIWarningTracker._completion_color = EHI:GetTWColor("completion")
EHIWarningTracker._check_anim_progress = false
EHIWarningTracker._show_completion_color = false
function EHIWarningTracker:update(t, dt)
    EHIWarningTracker.super.update(self, t, dt)
    if self._time <= 10 and not self._time_warning then
        self._time_warning = true
        self:AnimateColor(self._check_anim_progress)
    end
end

function EHIWarningTracker:AnimateColor(check_progress, color)
    if self._text and alive(self._text) then
        local start_t = check_progress and (1 - min(EHI:RoundNumber(self._time, 0.1) - floor(self._time), 0.99)) or 1
        self._text:animate(anim, self._text_color, color or (self._show_completion_color and self._completion_color or self._warning_color), start_t)
    end
end

function EHIWarningTracker:Run(params)
    self._time_warning = false
    self._text:stop()
    self._check_anim_progress = (params.time or 0) <= 10
    EHIWarningTracker.super.Run(self, params)
end

function EHIWarningTracker:delete()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHIWarningTracker.super.delete(self)
end