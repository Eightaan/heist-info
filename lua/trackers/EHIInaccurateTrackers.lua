local color = EHI:GetTWColor("inaccurate")
local Color = Color
---@class EHIInaccurateTracker : EHITracker
---@field super EHITracker
EHIInaccurateTracker = class(EHITracker)
EHIInaccurateTracker._tracker_type = "inaccurate"
EHIInaccurateTracker._text_color = color
function EHIInaccurateTracker:SetTrackerAccurate(time)
    self._text_color = Color.white
    EHIInaccurateTracker.super.SetTrackerAccurate(self, time)
end

---@class EHIInaccuratePausableTracker : EHIPausableTracker
---@field super EHIPausableTracker
EHIInaccuratePausableTracker = class(EHIPausableTracker)
EHIInaccuratePausableTracker._tracker_type = "inaccurate"
EHIInaccuratePausableTracker._text_color = color
function EHIInaccuratePausableTracker:SetTrackerAccurate(time)
    self._text_color = Color.white
    EHIInaccuratePausableTracker.super.SetTrackerAccurate(self, time)
end

---@class EHIInaccurateWarningTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIInaccurateWarningTracker = class(EHIWarningTracker)
EHIInaccurateWarningTracker._tracker_type = "inaccurate"
EHIInaccurateWarningTracker._text_color = color
function EHIInaccurateWarningTracker:SetTrackerAccurate(time)
    self._text_color = Color.white
    EHIInaccurateWarningTracker.super.SetTrackerAccurate(self, time)
end