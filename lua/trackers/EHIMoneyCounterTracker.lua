EHIMoneyCounterTracker = class(EHITracker)
EHIMoneyCounterTracker._update = false
function EHIMoneyCounterTracker:init(panel, params)
    self._money = params.money or 0
    EHIMoneyCounterTracker.super.init(self, panel, params)
end

function EHIMoneyCounterTracker:Format()
    return "$" .. self._money
end

function EHIMoneyCounterTracker:MoneyChanged()
    self._text:set_text(self:Format())
    self:FitTheText()
end

function EHIMoneyCounterTracker:AddMoney(money)
    self._money = self._money + money
    self:MoneyChanged()
end

function EHIMoneyCounterTracker:RemoveMoney(money)
    self._money = self._money - money
    self:MoneyChanged()
end