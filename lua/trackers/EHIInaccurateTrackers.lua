local color = tweak_data.ehi.color.Inaccurate
local lerp = math.lerp
local sin = math.sin
local Color = Color
EHIInaccurateTracker = class(EHITracker)
EHIInaccurateTracker._tracker_type = "inaccurate"
EHIInaccurateTracker._text_color = color
function EHIInaccurateTracker:SetTrackerAccurate(time)
    self._text_color = Color.white
    EHIInaccurateTracker.super.SetTrackerAccurate(self, time)
end

EHIInaccuratePausableTracker = class(EHIPausableTracker)
EHIInaccuratePausableTracker._tracker_type = "inaccurate"
EHIInaccuratePausableTracker._text_color = color
function EHIInaccuratePausableTracker:SetTrackerAccurate(time)
    self._text_color = Color.white
    EHIInaccuratePausableTracker.super.SetTrackerAccurate(self, time)
end

EHIInaccurateWarningTracker = class(EHIWarningTracker)
EHIInaccurateWarningTracker._tracker_type = "inaccurate"
EHIInaccurateWarningTracker._text_color = color
function EHIInaccurateWarningTracker:AnimateWarning()
    if self._tracker_type == "accurate" then
        EHIInaccurateWarningTracker.super.AnimateWarning(self)
    else
        self._text:animate(function(o)
            while true do
                local t = 1
                while t > 0 do
                    t = t - coroutine.yield()
                    local n = sin(t * 180)
                    local g = lerp(color.g, 0, n)
                    o:set_color(Color(1, g, 0))
                end
            end
        end)
    end
end

function EHIInaccurateWarningTracker:SetTrackerAccurate(time)
    self._text_color = Color.white
    EHIInaccurateWarningTracker.super.SetTrackerAccurate(self, time)
end