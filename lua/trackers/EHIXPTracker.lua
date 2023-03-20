EHIXPTracker = class(EHITracker)
EHIXPTracker._forced_icons = { "xp" }
function EHIXPTracker:init(panel, params)
    params.time = 5
    self._xp = params.amount or 0
    EHIXPTracker.super.init(self, panel, params)
end

function EHIXPTracker:Format() -- Formats the amount of XP in the panel
    return managers.experience:cash_string(self._xp, self._xp >= 0 and "+" or "") -- May show up a negative value because it is called from EHITotalXPTracker (diff)
end

function EHIXPTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:delete()
    end
end

function EHIXPTracker:AddXP(amount)
    self._time = 5
    self._xp = self._xp + amount
    self._text:set_text(self:Format())
    self:FitTheText()
    self:AnimateBG()
end

EHITotalXPTracker = class(EHIXPTracker)
EHITotalXPTracker._update = false
EHITotalXPTracker._show_diff = EHI:GetOption("total_xp_show_difference")
function EHITotalXPTracker:init(panel, params)
    self._total_xp = params.amount or 0
    EHITotalXPTracker.super.init(self, panel, params)
end

function EHITotalXPTracker:UpdateTotalXP()
    if self._total_xp ~= self._xp then
        if self._show_diff then
            self._parent_class:AddTracker({
                id = "XP_" .. self._total_xp .. "_" .. self._xp,
                amount = self._xp - self._total_xp,
                class = "EHIXPTracker"
            })
        end
        self._total_xp = self._xp
        self._text:set_text(self:Format())
        self:FitTheText()
        self:AnimateBG()
    end
end

function EHITotalXPTracker:SetXP(amount)
    self._xp = amount
    self:UpdateTotalXP()
end

function EHITotalXPTracker:Format() -- Formats the amount of XP in the panel
    return managers.experience:cash_string(self._total_xp, "+") -- Will never show a negative value
end