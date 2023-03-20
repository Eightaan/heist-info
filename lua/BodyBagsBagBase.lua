local EHI = EHI
if EHI:CheckLoadHook("BodyBagsBagBase") or not EHI:GetEquipmentOption("show_equipment_bodybags") then
    return
end

local UpdateTracker
if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("Deployables") then
            managers.ehi:AddAggregatedDeployablesTracker()
        end
        managers.ehi:CallFunction("Deployables", "UpdateAmount", "bodybags_bag", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("BodyBags") and managers.groupai:state():whisper_mode() then
            managers.ehi:CreateDeployableTracker("BodyBags")
        end
        managers.ehi:CallFunction("BodyBags", "UpdateAmount", unit, key, amount)
    end
    EHI:AddOnAlarmCallback(function()
        managers.ehi:RemoveTracker("BodyBags")
    end)
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
    init = BodyBagsBagBase.init,
    _set_visual_stage = BodyBagsBagBase._set_visual_stage,

    custom_set_empty = CustomBodyBagsBagBase._set_empty
}

function BodyBagsBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
end

function BodyBagsBagBase:GetEHIKey()
    return self._ehi_key
end

function BodyBagsBagBase:GetRealAmount()
    return self._bodybag_amount or self._max_bodybag_amount
end

function BodyBagsBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    UpdateTracker(self._unit, self._ehi_key, self._bodybag_amount)
end

function CustomBodyBagsBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
	UpdateTracker(self._unit, self._ehi_key, 0)
end