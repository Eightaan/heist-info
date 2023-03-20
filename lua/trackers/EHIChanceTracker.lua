EHIChanceTracker = class(EHITracker)
EHIChanceTracker._update = false
function EHIChanceTracker:init(panel, params)
    self._flash = params.dont_flash ~= true
    self._flash_times = params.flash_times or 3
    self._chance = params.chance or 0
    EHIChanceTracker.super.init(self, panel, params)
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
    if amount < 0 then
        amount = 0
    end
    self._chance = amount
    self._text:set_text(self:Format())
    if self._flash then
        self:AnimateBG(self._flash_times)
    end
end