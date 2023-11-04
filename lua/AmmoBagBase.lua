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
        if managers.ehi_deployable:TrackerDoesNotExist("Deployables") and amount ~= 0 then
            managers.ehi_deployable:AddAggregatedDeployablesTracker()
        end
        managers.ehi_deployable:CallFunction("Deployables", "UpdateAmount", "ammo_bag", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_deployable:TrackerDoesNotExist("AmmoBags") and amount ~= 0 then
            managers.ehi_deployable:CreateDeployableTracker("AmmoBags")
        end
        managers.ehi_deployable:CallFunction("AmmoBags", "UpdateAmount", unit, key, amount)
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
    init = AmmoBagBase.init,
    _set_visual_stage = AmmoBagBase._set_visual_stage,
    destroy = AmmoBagBase.destroy,

    custom_set_empty = CustomAmmoBagBase._set_empty
}

local ignored_pos = {}
---@param pos Vector3[]
function AmmoBagBase.SetIgnoredPos(pos)
    for _, _pos in ipairs(pos) do
        ignored_pos[tostring(_pos)] = true
    end
end

function AmmoBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._offset = 0
    if next(ignored_pos) and ignored_pos[tostring(unit:position())] then
        self._ignore = true
    end
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
    if self._ignore_set_by_parent then
        return
    end
    self._ignore = true
    UpdateTracker(self._unit, self._ehi_key, 0)
end

function AmmoBagBase:SetIgnoreChild()
    if self._parent_done then
        return
    end
    self:SetIgnore()
    self._ignore_set_by_parent = true
end

function AmmoBagBase:SetCountThisUnit()
    self._ignore = nil
    self._ignore_set_by_parent = nil
    self._parent_done = true
    self:SetOffset(self._offset)
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