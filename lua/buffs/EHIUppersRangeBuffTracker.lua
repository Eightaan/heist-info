local pm
local mvector3_distance = mvector3.distance
local math_floor = math.floor
local string_format = string.format
---@class EHIUppersRangeBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIUppersRangeBuffTracker = class(EHIGaugeBuffTracker)
EHIUppersRangeBuffTracker._refresh_time = 1 / EHI:GetBuffOption("uppers_range_refresh")
function EHIUppersRangeBuffTracker:PreUpdate()
    pm = managers.player
    local function Check(...)
        if self._in_custody then
            return
        end
        if table.size(FirstAidKitBase.List) == 0 then
            self:Deactivate()
        else
            self:Activate()
        end
    end
    EHI:HookWithID(FirstAidKitBase, "Add", "EHI_UppersRangeBuff_Add", Check)
    EHI:HookWithID(FirstAidKitBase, "Remove", "EHI_UppersRangeBuff_Remove", Check)
    EHI:AddOnCustodyCallback(function(state)
        self:CustodyState(state)
    end)
end

function EHIUppersRangeBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self:AddBuffToUpdate()
end

function EHIUppersRangeBuffTracker:CustodyState(state)
    if state then
        self:Deactivate()
    elseif next(FirstAidKitBase.List) then
        self:Activate()
    end
    self._in_custody = state
end

function EHIUppersRangeBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:DeactivateSoft()
    self:RemoveBuffFromUpdate()
    self._active = false
end

function EHIUppersRangeBuffTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self._time = self._refresh_time
        local player_unit = pm:player_unit()
        if alive(player_unit) then
            local found, distance, min_distance = self:GetFirstAidKit(player_unit:position())
            if found then
                local ratio = 1 - (distance / min_distance)
                self._distance = distance / 100
                self:ActivateSoft()
                self:SetRatio(ratio)
            else
                self:DeactivateSoft()
            end
        end
    end
end

---@param pos Vector3
---@return boolean
---@return number?
---@return number?
function EHIUppersRangeBuffTracker:GetFirstAidKit(pos)
	for _, o in ipairs(FirstAidKitBase.List) do
		local dst = mvector3_distance(pos, o.pos)
		if dst <= o.min_distance then
			return true, dst, o.min_distance
		end
	end
	return false
end

function EHIUppersRangeBuffTracker:Format()
    return string_format("%dm", math_floor(self._distance))
end