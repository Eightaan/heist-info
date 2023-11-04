local EHI = EHI
---@class EHIECMTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIECMTracker = class(EHIWarningTracker)
---@param panel Panel
---@param params EHITracker_params
function EHIECMTracker:init(panel, params)
    EHIECMTracker.super.init(self, panel, params)
    self._unit = params.unit
end

function EHIECMTracker:SetTime(time)
    self._text:stop()
    self._time_warning = false
    self:SetTextColor(Color.white)
    self._check_anim_progress = time <= 10
    EHIECMTracker.super.SetTime(self, time)
end

function EHIECMTracker:SetTimeIfLower(time, owner_id, unit)
    if self._time >= time then
        return
    end
    self:SetTime(time)
    self:_UpdateOwnerID(owner_id)
    self._unit = unit
end

function EHIECMTracker:UpdateOwnerID(owner_id, unit)
    if self._unit == unit then
        self:SetIconColor(EHI:GetPeerColorByPeerID(owner_id))
    end
end

function EHIECMTracker:_UpdateOwnerID(owner_id)
    self:SetIconColor(EHI:GetPeerColorByPeerID(owner_id))
end

function EHIECMTracker:Destroyed(unit)
    if self._unit == unit then
        self:delete()
    end
end