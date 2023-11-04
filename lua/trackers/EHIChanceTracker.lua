---@class EHIChanceTracker : EHITracker
---@field super EHITracker
EHIChanceTracker = class(EHITracker)
EHIChanceTracker._update = false
function EHIChanceTracker:pre_init(params)
    self._chance = params.chance or 0
end

function EHIChanceTracker:Format()
    return self._chance .. "%"
end

function EHIChanceTracker:IncreaseChance(amount)
    self:SetChance(self._chance + amount)
end

function EHIChanceTracker:DecreaseChance(amount)
    self:SetChance(self._chance - amount)
end

function EHIChanceTracker:SetChance(amount)
    self._chance = math.max(0, amount)
    self._text:set_text(self:Format())
    self:AnimateBG()
end