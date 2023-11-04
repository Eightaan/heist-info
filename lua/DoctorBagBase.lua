local EHI = EHI
if EHI:CheckLoadHook("DoctorBagBase") or not EHI:GetEquipmentOption("show_equipment_doctorbag") then
    return
end

local UpdateTracker
if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_deployable:TrackerDoesNotExist("Deployables") then
            managers.ehi_deployable:AddAggregatedDeployablesTracker()
        end
        managers.ehi_deployable:CallFunction("Deployables", "UpdateAmount", "doctor_bag", unit, key, amount)
    end
elseif EHI:GetOption("show_equipment_aggregate_health") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_deployable:TrackerDoesNotExist("Health") then
            managers.ehi_deployable:AddAggregatedHealthTracker()
        end
        managers.ehi_deployable:CallFunction("Health", "UpdateAmount", "doctor_bag", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_deployable:TrackerDoesNotExist("DoctorBags") then
            managers.ehi_deployable:CreateDeployableTracker("DoctorBags")
        end
        managers.ehi_deployable:CallFunction("DoctorBags", "UpdateAmount", unit, key, amount)
    end
end

if EHI:IsVR() then
    local old_UpdateTracker = UpdateTracker
    local function Reload(key, data)
        old_UpdateTracker(data.unit, key, data.amount)
    end
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_deployable:IsLoading() then
            managers.ehi_deployable:AddToLoadQueue(key, { unit = unit, amount = amount }, Reload)
            return
        end
        old_UpdateTracker(unit, key, amount)
    end
end

local original =
{
    init = DoctorBagBase.init,
    _set_visual_stage = DoctorBagBase._set_visual_stage,
    destroy = DoctorBagBase.destroy,

    custom_set_empty = CustomDoctorBagBase._set_empty
}

function DoctorBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._offset = 0
end

function DoctorBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    UpdateTracker(self._unit, self._ehi_key, self:GetRealAmount())
end

function DoctorBagBase:GetEHIKey()
    return self._ehi_key
end

function DoctorBagBase:GetRealAmount()
    return (self._amount or self._max_amount) - self._offset
end

function DoctorBagBase:SetOffset(offset)
    self._offset = offset
    if self._unit:interaction():active() and not self._ignore then
        UpdateTracker(self._unit, self._ehi_key, self:GetRealAmount())
    end
end

function DoctorBagBase:destroy(...)
    UpdateTracker(self._unit, self._ehi_key, 0)
    original.destroy(self, ...)
end

function CustomDoctorBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
    UpdateTracker(self._unit, self._ehi_key, 0)
end