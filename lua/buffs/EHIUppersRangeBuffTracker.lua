local pm
local mvector3_distance = mvector3.distance
local math_floor = math.floor
local string_format = string.format
EHIUppersRangeBuffTracker = class(EHIGaugeBuffTracker)
EHIUppersRangeBuffTracker._refresh_time = 1 / EHI:GetBuffOption("uppers_range_refresh")
function EHIUppersRangeBuffTracker:PreUpdate()
    pm = managers.player
    local function Check(...)
        if self._in_custody then
            return
        end
        local list = FirstAidKitBase.List
        if table.size(list) == 0 then
            self:Deactivate()
        else
            self:Activate()
        end
    end
    EHI:HookWithID(FirstAidKitBase, "Add", "UppersRangeBuff_Add", Check)
    EHI:HookWithID(FirstAidKitBase, "Remove", "UppersRangeBuff_Remove", Check)
    local function f(state)
        self:CustodyState(state)
    end
    EHI:AddOnCustodyCallback(f)
end

function EHIUppersRangeBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._parent_class:AddBuffToUpdate(self._id, self)
end

function EHIUppersRangeBuffTracker:CustodyState(state)
    if state then
        self:Deactivate()
    else
        local list = FirstAidKitBase.List
        if next(list) then
            self:Activate()
        end
    end
    self._in_custody = state
end

function EHIUppersRangeBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:DeactivateSoft()
    self._parent_class:RemoveBuffFromUpdate(self._id)
    self._active = false
end

function EHIUppersRangeBuffTracker:ActivateSoft()
    if self._visible then
        return
    end
    self._panel:stop()
    self._panel:animate(self._show)
    self._parent_class:AddVisibleBuff(self._id)
    self._visible = true
end

function EHIUppersRangeBuffTracker:DeactivateSoft()
    if not self._visible then
        return
    end
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
    self._panel:stop()
    self._panel:animate(self._hide)
    self._visible = false
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

function EHIUppersRangeBuffTracker:GetFirstAidKit(pos)
	for _, o in pairs(FirstAidKitBase.List) do
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

function EHIUppersRangeBuffTracker:SetRatio(ratio)
    if self._ratio == ratio then
        return
    end
    EHIUppersRangeBuffTracker.super.SetRatio(self, ratio)
end