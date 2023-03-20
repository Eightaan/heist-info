local function completion(o, icon, arrow, bitmap_world)
    while true do
        local t = 1
        while t > 0 do
            t = t - coroutine.yield()
            local n = math.sin(t * 180)
            local g = math.lerp(1, 0, n)
            local c = Color(g, 1, g)
            o:set_color(c)
            icon:set_color(c)
            arrow:set_color(c)
            if bitmap_world then
                bitmap_world:set_color(c)
            end
        end
    end
end
EHITimerWaypoint = class(EHIPausableWaypoint)
EHITimerWaypoint._update = false
EHITimerWaypoint.AnimateWarning = EHIWarningWaypoint.AnimateWarning
EHITimerWaypoint.delete = EHIWarningWaypoint.delete
function EHITimerWaypoint:init(waypoint, params, parent_class)
    EHITimerWaypoint.super.init(self, waypoint, params, parent_class)
    self._warning = params.warning
    self._jammed = false
    self._not_powered = false
    if params.autorepair then
        self:SetAutorepair(true)
    end
    if params.completion then
        self._warning = true
        self.AnimateWarning = self.AnimateCompletion
    end
end

function EHITimerWaypoint:SetTime(t)
    if self._time == t then
        return
    end
    EHITimerWaypoint.super.SetTime(self, t)
    if self._time <= 10 and self._warning and not self._warning_started then
        self:AnimateWarning()
        self._warning_started = true
    end
end

function EHITimerWaypoint:AnimateCompletion()
    self._timer:animate(completion, self._bitmap, self._arrow, self._bitmap_world)
end

function EHITimerWaypoint:SetJammed(jammed)
    if self._warning_started and jammed then
        self._timer:stop()
        self._warning_started = false
    end
    self._jammed = jammed
    self:SetColorBasedOnStatus()
end

function EHITimerWaypoint:SetPowered(powered)
    self._not_powered = not powered
    self:SetColorBasedOnStatus()
end

function EHITimerWaypoint:SetRunning()
    self:SetJammed(false)
    self:SetPowered(true)
end

function EHITimerWaypoint:SetColorBasedOnStatus()
    if self._jammed or self._not_powered then
        self:SetColor(Color.red)
    else
        self:SetColor(self._default_color)
        if self._time <= 10 and self._warning and not self._warning_started then
            self._warning_started = true
            self:AnimateWarning()
        end
    end
end

function EHITimerWaypoint:SetAutorepair(state)
    self._default_color = state and tweak_data.ehi.color.DrillAutorepair or Color.white
    self:SetColor(self._default_color)
end