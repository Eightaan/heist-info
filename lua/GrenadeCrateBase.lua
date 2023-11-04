local EHI = EHI
if EHI:CheckLoadHook("GrenadeCrateBase") then
    return
end

if not EHI:GetEquipmentOption("show_equipment_grenadecases") then
    return
end

local UpdateTracker
if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_deployable:TrackerDoesNotExist("Deployables") and amount ~= 0 then
            managers.ehi_deployable:AddAggregatedDeployablesTracker()
        end
        managers.ehi_deployable:CallFunction("Deployables", "UpdateAmount", "grenade_crate", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_deployable:TrackerDoesNotExist("GrenadeCases") and amount ~= 0 then
            managers.ehi_deployable:AddTracker({
                id = "GrenadeCases",
                icons = { "frag_grenade" },
                class = "EHIEquipmentTracker"
            })
        end
        managers.ehi_deployable:CallFunction("GrenadeCases", "UpdateAmount", unit, key, amount)
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
    init = GrenadeCrateBase.init,
    _set_visual_stage = GrenadeCrateBase._set_visual_stage,
    destroy = GrenadeCrateBase.destroy,

    init_custom = CustomGrenadeCrateBase.init,
    _set_empty_custom = CustomGrenadeCrateBase._set_empty
}
function GrenadeCrateBase:init(unit, ...)
    self._ehi_key = tostring(unit:key())
    original.init(self, unit, ...)
end

function GrenadeCrateBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    if not self._ignore then
        UpdateTracker(self._unit, self._ehi_key, self:GetRealAmount())
    end
end

function GrenadeCrateBase:GetEHIKey()
    return self._ehi_key
end

function GrenadeCrateBase:GetRealAmount()
    return self._grenade_amount or self._max_grenade_amount
end

function GrenadeCrateBase:SetIgnore()
    if self._ignore_set_by_parent then
        return
    end
    self._ignore = true
    UpdateTracker(self._unit, self._ehi_key, 0)
end

function GrenadeCrateBase:SetIgnoreChild()
    if self._parent_done then
        return
    end
    self:SetIgnore()
    self._ignore_set_by_parent = true
end

function GrenadeCrateBase:SetCountThisUnit()
    self._ignore = nil
    self._ignore_set_by_parent = nil
    self._parent_done = true
    UpdateTracker(self._unit, self._ehi_key, self:GetRealAmount())
end

function GrenadeCrateBase:destroy(...)
    UpdateTracker(self._unit, self._ehi_key, 0)
    original.destroy(self, ...)
end

function CustomGrenadeCrateBase:init(unit, ...)
    self._ehi_key = tostring(unit:key())
    original.init_custom(self, unit, ...)
end

function CustomGrenadeCrateBase:_set_empty(...)
    original._set_empty_custom(self, ...)
    UpdateTracker(self._unit, self._ehi_key, 0)
end