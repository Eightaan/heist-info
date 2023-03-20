local EHI = EHI
local lerp = math.lerp
local sin = math.sin
local min = math.min
local floor = math.floor
local Color = Color
local function anim(o, start_t)
    while true do
        local t = start_t
        while t > 0 do
            t = t - coroutine.yield()
            local n = sin(t * 180)
            local g = lerp(1, 0, n)
            o:set_color(Color(1, g, g))
        end
        start_t = 1
    end
end
EHIWarningTracker = class(EHITracker)
EHIWarningTracker._check_anim_progress = false
function EHIWarningTracker:update(t, dt)
    EHIWarningTracker.super.update(self, t, dt)
    if self._time <= 10 and not self._time_warning then
        self._time_warning = true
        self:AnimateWarning(self._check_anim_progress)
    end
end

function EHIWarningTracker:AnimateWarning(check_progress)
    if self._text and alive(self._text) then
        local start_t = check_progress and (1 - min(EHI:RoundNumber(self._time, 0.1) - floor(self._time), 0.99)) or 1
        self._text:animate(anim, start_t)
    end
end

function EHIWarningTracker:Run(params)
    self._time_warning = false
    self._check_anim_progress = (params.time or 0) <= 10
    EHIWarningTracker.super.Run(self, params)
end

function EHIWarningTracker:delete()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHIWarningTracker.super.delete(self)
end