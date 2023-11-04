---@class EHICountTracker : EHITracker
---@field super EHITracker
EHICountTracker = class(EHITracker)
EHICountTracker._update = false
function EHICountTracker:pre_init(params)
    self._count = params.count or 0
end

function EHICountTracker:Format()
    return tostring(self._count)
end

---@param count number?
function EHICountTracker:IncreaseCount(count)
    self:SetCount(self._count + (count or 1))
end

---@param count number?
function EHICountTracker:DecreaseCount(count)
    self:SetCount(self._count - (count or 1))
end

function EHICountTracker:SetCount(count)
    self._count = count
    self._text:set_text(self:Format())
    self:AnimateBG()
end

function EHICountTracker:ResetCount()
    self:SetCount(0)
end

function EHICountTracker:GetCount()
    return self._count
end