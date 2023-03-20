EHICountTracker = class(EHITracker)
EHICountTracker._update = false
function EHICountTracker:init(panel, params)
    self._count = 0
    self._anim_flash = params.flash ~= false
    self._flash_times = params.flash_times or 3
    EHICountTracker.super.init(self, panel, params)
end

function EHICountTracker:Format()
    return tostring(self._count)
end

function EHICountTracker:IncreaseCount()
    self:SetCount(self._count + 1)
end

function EHICountTracker:DecreaseCount()
    self:SetCount(self._count - 1)
end

function EHICountTracker:SetCount(count)
    self._count = count
    self._text:set_text(self:Format())
    if self._anim_flash then
        self:AnimateBG(self._flash_times)
    end
end