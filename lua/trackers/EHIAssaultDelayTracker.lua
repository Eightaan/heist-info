local lerp = math.lerp
local Color = Color
local Control = Color.white
local Anticipation = Color(255, 186, 204, 28) / 255
local assault_values = tweak_data.group_ai[tweak_data.levels:GetGroupAIState()].assault
local tweak_values = assault_values.delay
local hostage_values = assault_values.hostage_hesitation_delay
---@class EHIAssaultDelayTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIAssaultDelayTracker = class(EHIWarningTracker)
EHIAssaultDelayTracker._forced_icons = { { icon = "assaultbox", color = Control } }
EHIAssaultDelayTracker._show_completion_color = true
if type(tweak_values) ~= "table" then -- If for some reason the assault delay is not a table, use the value directly
    EHIAssaultDelayTracker._assault_delay = tonumber(tweak_values) or 30
else
    local first_value = tweak_values[1] or 0
    local match = true
    for _, value in pairs(tweak_values) do
        if first_value ~= value then
            match = false
            break
        end
    end
    if match then -- All numbers are the same, use it and avoid computation because it is expensive
        EHIAssaultDelayTracker._assault_delay = first_value
    end
end
if type(hostage_values) ~= "table"  then -- If for some reason the hesitation delay is not a table, use the value directly
    EHIAssaultDelayTracker._precomputed_hostage_delay = true
    EHIAssaultDelayTracker._hostage_delay = tonumber(hostage_values) or 30
else
    local first_value = hostage_values[1] or 0
    local match = true
    for _, value in pairs(hostage_values) do
        if first_value ~= value then
            match = false
            break
        end
    end
    if match then -- All numbers are the same, use it and avoid computation because it is expensive
        EHIAssaultDelayTracker._precomputed_hostage_delay = true
        EHIAssaultDelayTracker._hostage_delay = first_value
    end
end
---@param panel Panel
---@param params EHITracker_params
function EHIAssaultDelayTracker:init(panel, params)
    if not params.time then
        params.time = self:CalculateBreakTime(params.diff) + (2 * math.random())
    end
    self:ComputeHostageDelay(params.diff or 0)
    EHIAssaultDelayTracker.super.init(self, panel, params)
    self._update = not params.stop_counting
    self.update_normal = self.update
    self:CheckIfHostageIsPresent()
end

---@param diff number
function EHIAssaultDelayTracker:ComputeHostageDelay(diff)
    if self._precomputed_hostage_delay then
        return
    end
    local ramp = tweak_data.group_ai.difficulty_curve_points
    local i = 1
    while (ramp[i] or 1) < diff do
        i = i + 1
    end
    local difficulty_point_index = i
    local difficulty_ramp = (diff - (ramp[i - 1] or 0)) / ((ramp[i] or 1) - (ramp[i - 1] or 0))
    self._hostage_delay = lerp(hostage_values[difficulty_point_index], hostage_values[difficulty_point_index + 1], difficulty_ramp)
end

---@param t any Unused
---@param dt number
function EHIAssaultDelayTracker:update_negative(t, dt)
    self._time = self._time + dt
    self._text:set_text("+" .. self:Format())
end

function EHIAssaultDelayTracker:SyncAnticipationColor()
    self._text:stop()
    self:SetTextColor(Color.white)
    self:SetIconColor(Anticipation)
    self._time_warning = nil
    self.update = self.update_normal
    self._hostage_delay_disabled = true
end

---@param t number
function EHIAssaultDelayTracker:SyncAnticipation(t)
    self._time = t - (2 * math.random())
    self:SyncAnticipationColor()
end

function EHIAssaultDelayTracker:CheckIfHostageIsPresent()
    local group_ai = managers.groupai:state()
    if not group_ai._hostage_headcount or group_ai._hostage_headcount == 0 then
        return
    end
    self:UpdateTime(self._hostage_delay)
    self._hostages_found = true
end

---@param diff number
function EHIAssaultDelayTracker:CalculateBreakTime(diff)
    if self._assault_delay then
        return self._assault_delay + 30
    end
    local ramp = tweak_data.group_ai.difficulty_curve_points
    local i = 1
    while (ramp[i] or 1) < diff do
        i = i + 1
    end
    local difficulty_point_index = i
    local difficulty_ramp = (diff - (ramp[i - 1] or 0)) / ((ramp[i] or 1) - (ramp[i - 1] or 0))
    local base_delay = lerp(tweak_values[difficulty_point_index], tweak_values[difficulty_point_index + 1], difficulty_ramp)
    return base_delay + 30
end

---@param has_hostages boolean
function EHIAssaultDelayTracker:SetHostages(has_hostages)
    if self._hostage_delay_disabled then
        return
    end
    if has_hostages and not self._hostages_found then
        self._hostages_found = true
        self:UpdateTime(self._hostage_delay)
    elseif self._hostages_found and not has_hostages then
        self._hostages_found = false
        self:UpdateTime(-self._hostage_delay)
    end
end

---@param t number
function EHIAssaultDelayTracker:UpdateTime(t)
    self._time = self._time + t
    if not self._update then
        self._text:set_text(self:Format())
    end
end

---@param t number
function EHIAssaultDelayTracker:StartAnticipation(t)
    self._hostage_delay_disabled = true
    self._time = t
    if not self._update then
        self:AddTrackerToUpdate()
    end
end

---@param time number
function EHIAssaultDelayTracker:SetTime(time)
    if self._hostage_delay_disabled then
        return
    end
    self._hostages_found = false
    EHIAssaultDelayTracker.super.SetTime(self, time)
    self:CheckIfHostageIsPresent()
end

---@param diff number
function EHIAssaultDelayTracker:UpdateDiff(diff)
    if self._hostage_delay_disabled or self._precomputed_hostage_delay then
        return
    end
    self:SetHostages(false)
    self:ComputeHostageDelay(diff)
    self:CheckIfHostageIsPresent()
    --[[if diff > 0 then
        self._time = self:CalculateBreakTime(diff)
        self:AddTrackerToUpdate()
    else
        self:RemoveTrackerFromUpdate()
        self._text:stop()
        self:SetTextColor(Color.white)
    end]]
end

function EHIAssaultDelayTracker:PoliceActivityBlocked()
    self._hide_on_delete = nil
    self._time = 1
    EHIAssaultDelayTracker.super.delete(self)
end

function EHIAssaultDelayTracker:delete()
    if self._time <= 0 then
        self.update = self.update_negative
        self._time = -self._time
        self._text:stop()
        self:SetTextColor(Color.white)
        self:AnimateColor()
        return
    end
    EHIAssaultDelayTracker.super.delete(self)
end

---@class EHIInaccurateAssaultDelayTracker : EHIAssaultDelayTracker
---@field super EHIAssaultDelayTracker
EHIInaccurateAssaultDelayTracker = class(EHIAssaultDelayTracker)
EHIInaccurateAssaultDelayTracker._text_color = EHI:GetTWColor("inaccurate")
---@param t number
function EHIInaccurateAssaultDelayTracker:StartAnticipation(t)
    self:SetTextColor(Color.white)
    self._text_color = Color.white
    EHIInaccurateAssaultDelayTracker.super.StartAnticipation(self, t)
end

---@param t number
function EHIInaccurateAssaultDelayTracker:SyncAnticipation(t)
    EHIInaccurateAssaultDelayTracker.super.SyncAnticipation(self, t)
    self._text_color = Color.white
end