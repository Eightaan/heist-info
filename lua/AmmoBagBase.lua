local EHI = EHI
if EHI:CheckLoadHook("AmmoBagBase") then
    return
end

if not EHI:GetEquipmentOption("show_equipment_ammobag") then
    return
end

local UpdateTracker
if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("Deployables") and amount ~= 0 then
            managers.ehi:AddAggregatedDeployablesTracker()
        end
        managers.ehi:CallFunction("Deployables", "UpdateAmount", "ammo_bag", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("AmmoBags") and amount ~= 0 then
            managers.ehi:CreateDeployableTracker("AmmoBags")
        end
        managers.ehi:CallFunction("AmmoBags", "UpdateAmount", unit, key, amount)
    end
end

if _G.IS_VR then
    local old_UpdateTracker = UpdateTracker
    local function Reload(key, data)
        old_UpdateTracker(data.unit, key, data.amount)
    end
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:IsLoading() then
            managers.ehi:AddToLoadQueue(key, { unit = unit, amount = amount }, Reload)
            return
        end
        old_UpdateTracker(unit, key, amount)
    end
end

local original =
{
    init = AmmoBagBase.init,
    _set_visual_stage = AmmoBagBase._set_visual_stage,
    destroy = AmmoBagBase.destroy,

    custom_set_empty = CustomAmmoBagBase._set_empty
}

function AmmoBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._offset = 0
end

function AmmoBagBase:GetEHIKey()
    return self._ehi_key
end

function AmmoBagBase:GetRealAmount()
    return (self._ammo_amount or self._max_ammo_amount) - self._offset
end

function AmmoBagBase:SetOffset(offset)
    self._offset = offset
    if self._unit:interaction():active() and not self._ignore then
        UpdateTracker(self._unit, self._ehi_key, self:GetRealAmount())
    end
end

function AmmoBagBase:SetIgnore()
    self._ignore = true
    UpdateTracker(self._unit, self._ehi_key, 0)
end

function AmmoBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    if not self._ignore then
        UpdateTracker(self._unit, self._ehi_key, self:GetRealAmount())
    end
end

function AmmoBagBase:destroy(...)
    UpdateTracker(self._unit, self._ehi_key, 0)
    original.destroy(self, ...)
end

function CustomAmmoBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
    UpdateTracker(self._unit, self._ehi_key, 0)
end