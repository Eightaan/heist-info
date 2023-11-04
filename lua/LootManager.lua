local EHI = EHI
if EHI:CheckLoadHook("LootManager") then
    return
end

---@class LootManager
---@field GetSecuredBagsAmount fun(self: self): integer
---@field GetSecuredBagsTypeAmount fun(self: self, t: string|string[]): integer
---@field GetSecuredBagsValueAmount fun(self: self): number
---@field EHIReportProgress fun(self: self, tracker_id: string, check_type: integer, loot_type: string|string[], f: fun(loot: self, tracker_id: string))

local check_types = EHI.LootCounter.CheckType
local original =
{
    sync_secure_loot = LootManager.sync_secure_loot,
    sync_load = LootManager.sync_load
}

function LootManager:sync_secure_loot(...)
    original.sync_secure_loot(self, ...)
    EHI:CallCallback(EHI.CallbackMessage.LootSecured, self)
end

function LootManager:sync_load(...)
    original.sync_load(self, ...)
    EHI:CallCallbackOnce(EHI.CallbackMessage.LootLoadSync, self)
end

function LootManager:GetSecuredBagsAmount()
    local mandatory = self:get_secured_mandatory_bags_amount()
    local bonus = self:get_secured_bonus_bags_amount()
    local total = (mandatory or 0) + (bonus or 0)
    return total
end

---@param t string|string[]
function LootManager:GetSecuredBagsTypeAmount(t)
    local secured = 0
    if type(t) == "string" then
        for _, data in ipairs(self._global.secured) do
            if data.carry_id == t then
                secured = secured + 1
            end
        end
    elseif type(t) == "table" then
        for _, carry_id in ipairs(t) do
            for _, data in ipairs(self._global.secured) do
                if data.carry_id == carry_id then
                    secured = secured + 1
                end
            end
        end
    end
    return secured
end

function LootManager:GetSecuredBagsValueAmount()
    local value = 0
    for _, data in ipairs(self._global.secured) do
        if not tweak_data.carry.small_loot[data.carry_id] then
            value = value + managers.money:get_secured_bonus_bag_value(data.carry_id, data.multiplier)
        end
    end
    return value
end

---@param tracker_id string
---@param check_type integer
---@param loot_type string|string[]
---@param f fun(loot: self, tracker_id: string)?
function LootManager:EHIReportProgress(tracker_id, check_type, loot_type, f)
    if check_type == check_types.AllLoot then
        local bags = self:GetSecuredBagsValueAmount()
        local small_loot = self:get_real_total_small_loot_value()
        managers.ehi_tracker:SetTrackerProgress(tracker_id, bags + small_loot)
    elseif check_type == check_types.BagsOnly then
        managers.ehi_tracker:SetTrackerProgress(tracker_id, self:GetSecuredBagsAmount())
    elseif check_type == check_types.ValueOfBags then
        managers.ehi_tracker:SetTrackerProgress(tracker_id, self:GetSecuredBagsValueAmount())
    elseif check_type == check_types.SmallLootOnly then
    elseif check_type == check_types.ValueOfSmallLoot then
        managers.ehi_tracker:SetTrackerProgress(tracker_id, self:get_real_total_small_loot_value())
    elseif check_type == check_types.OneTypeOfLoot then
        managers.ehi_tracker:SetTrackerProgress(tracker_id, self:GetSecuredBagsTypeAmount(loot_type))
    elseif check_type == check_types.CustomCheck then
        if f then
            f(self, tracker_id)
        end
    elseif check_type == check_types.Debug then
        local tweak = tweak_data.carry
        local loot_name = "<Unknown>"
        if tweak[loot_type] then
            loot_name = tweak[loot_type].name_id and managers.localization:text(tweak[loot_type].name_id) or "<Unknown Bag>"
        elseif tweak.small_loot[loot_type] then
            loot_name = "Small Loot"
        end
        managers.chat:_receive_message(1, "[EHI]", "Secured: " .. loot_name .. "; Carry ID: " .. tostring(loot_type))
    end
end

if EHI.debug.loot_manager_escape then
    original.init = LootManager.init
    function LootManager:init(...)
        original.init(self, ...)
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "money", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "money", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "money", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "money", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
    end
end