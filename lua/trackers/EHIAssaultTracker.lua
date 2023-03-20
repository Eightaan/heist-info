local lerp = math.lerp
local Color = Color
local Captain = Color(255, 255, 128, 0) / 255
local Control = Color.white
local Anticipation = Color(255, 186, 204, 28) / 255
local Build = Color.yellow
local Sustain = Color(255, 237, 127, 127) / 255
local Fade = Color(255, 0, 255, 255) / 255
if BAI then
    Captain = BAI:GetRightColor("captain")
    Control = BAI:GetColor("control")
    Anticipation = BAI:GetColor("anticipation")
    Build = BAI:GetColor("build")
    Sustain = BAI:GetColor("sustain")
    Fade = BAI:GetColor("fade")
    BAI:AddEvent(BAI.EventList.Update, function()
        Captain = BAI:GetRightColor("captain")
        Control = BAI:GetColor("control")
        Anticipation = BAI:GetColor("anticipation")
        Build = BAI:GetColor("build")
        Sustain = BAI:GetColor("sustain")
        Fade = BAI:GetColor("fade")
        EHIAssaultTracker._forced_icons[1].color = Control
    end)
end
local State =
{
    control = 1,
    anticipation = 2,
    build = 3,
    sustain = 4,
    fade = 5
}
local assault_values = tweak_data.group_ai[tweak_data.levels:get_group_ai_state()].assault
local tweak_values = assault_values.delay
local hostage_values = assault_values.hostage_hesitation_delay
EHIAssaultTracker = class(EHIWarningTracker)
EHIAssaultTracker._forced_icons = { { icon = "assaultbox", color = Control } }
EHIAssaultTracker._is_client = EHI:IsClient()
EHIAssaultTracker.AnimateNegative = EHITimerTracker.AnimateCompletion
if type(hostage_values) ~= "table"  then -- If for some reason the hesitation delay is not a table, use the value directly
    EHIAssaultTracker._precomputed_hostage_delay = true
    EHIAssaultTracker._hostage_delay = tonumber(hostage_values) or 30
else
    local first_value = hostage_values[1] or 0
    local match = true
    for _, value in pairs(hostage_values) do
        if first_value ~= value then
            match = false
            break
        end
    end
    if match then -- All numbers the same, use it and avoid computation because it is expensive
        EHIAssaultTracker._precomputed_hostage_delay = true
        EHIAssaultTracker._hostage_delay = first_value
    end
end
function EHIAssaultTracker:init(panel, params)
    self._diff = params.diff or 0
    self:CalculateDifficultyRamp()
    self.update_break = self.update
    if params.assault then
        self._assault = true
        self._original_time = self:CalculateAssaultTime()
        params.time = self._original_time
        self._forced_icons[1].color = Build
        self.update = self.update_assault
    elseif not params.time then
        params.time = self:CalculateBreakTime() + (2 * math.random())
        self:ComputeHostageDelay()
        self:CheckIfHostageIsPresent()
        self._forced_icons[1].color = Control
    end
    EHIAssaultTracker.super.init(self, panel, params)
    self._update = not params.stop_counting
end

function EHIAssaultTracker:update_negative(t, dt)
    self._time = self._time + dt
    self._text:set_text("+" .. self:Format())
end

function EHIAssaultTracker:update_assault(t, dt)
    EHIAssaultTracker.super.update(self, t, dt)
    if self._to_sustain_t then
        self._to_sustain_t = self._to_sustain_t - dt
        if self._to_sustain_t <= 0 then
            self._to_sustain_t = nil
            self._state = State.sustain
            self:SetIconColor(Sustain)
        end
    end
    if self._to_fade_t then
        self._to_fade_t = self._to_fade_t - dt
        if self._to_fade_t <= 0 then
            self._to_fade_t = nil
            self._state = State.fade
            self:SetIconColor(Fade)
        end
    end
end

function EHIAssaultTracker:AnimateWarning()
    if self._assault then
        self:AnimateNegative()
    else
        EHIAssaultTracker.super.AnimateWarning(self)
    end
end

function EHIAssaultTracker:CalculateDifficultyRamp()
    local ramp = tweak_data.group_ai.difficulty_curve_points
    local i = 1
    while (ramp[i] or 1) < self._diff do
        i = i + 1
    end
    self._difficulty_point_index = i
    self._difficulty_ramp = (self._diff - (ramp[i - 1] or 0)) / ((ramp[i] or 1) - (ramp[i - 1] or 0))
end

function EHIAssaultTracker:ComputeHostageDelay()
    if self._precomputed_hostage_delay then
        return
    end
    self._hostage_delay = lerp(hostage_values[self._difficulty_point_index], hostage_values[self._difficulty_point_index + 1], self._difficulty_ramp)
end

function EHIAssaultTracker:SyncAnticipationColor()
    self._text:stop()
    self:SetTextColor(Color.white)
    self:SetIconColor(Anticipation)
    self._time_warning = nil
    self.update = self.update_break
    self._hostage_delay_disabled = true
    self._state = State.anticipation
end

function EHIAssaultTracker:SyncAnticipation(t)
    self._time = t - (2 * math.random())
    self:SyncAnticipationColor()
end

function EHIAssaultTracker:CheckIfHostageIsPresent()
    local group_ai = managers.groupai:state()
    if not group_ai._hostage_headcount or group_ai._hostage_headcount == 0 then
        return
    end
    self:UpdateTime(self._hostage_delay)
    self._hostages_found = true
end

function EHIAssaultTracker:CalculateBreakTime()
    local base_delay = lerp(tweak_values[self._difficulty_point_index], tweak_values[self._difficulty_point_index + 1], self._difficulty_ramp)
    return base_delay + 30
end

function EHIAssaultTracker:SetHostages(has_hostages)
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

function EHIAssaultTracker:UpdateTime(t)
    self._time = self._time + t
    if not self._update then
        self._text:set_text(self:Format())
    end
end

function EHIAssaultTracker:StartAnticipation(t)
    self._hostage_delay_disabled = true
    self._time = t
    self._state = State.anticipation
    if not self._update then
        self:AddTrackerToUpdate()
    end
end

function EHIAssaultTracker:SetTime(time)
    if self._hostage_delay_disabled or self._assault then
        return
    end
    self._hostages_found = false
    EHIAssaultTracker.super.SetTime(self, time)
    self:CheckIfHostageIsPresent()
end

function EHIAssaultTracker:UpdateDiff(diff)
    if self._diff == diff then
        return
    end
    self._diff = diff
    if self._assault then
        if self._state == State.build then
            self:CalculateDifficultyRamp()
            local new_time = self:CalculateAssaultTime()
            if new_time ~= self._original_time then
                local time_diff = new_time - self._original_time
                self._time = self._time + time_diff
                self._original_time = new_time
                self._to_fade_t = self._to_fade_t + time_diff
                if self._to_sustain_t then
                    self._to_sustain_t = self._to_sustain_t + time_diff
                end
            end
        end
    elseif self._hostage_delay_disabled or self._precomputed_hostage_delay then
        return
    else
        self:CalculateDifficultyRamp()
        self:SetHostages(false)
        self:ComputeHostageDelay()
        self:CheckIfHostageIsPresent()
    end
    --[[if diff > 0 then
        self._time = self:CalculateBreakTime(diff)
        self:AddTrackerToUpdate()
    else
        self:RemoveTrackerFromUpdate()
        self._text:stop()
        self:SetTextColor(Color.white)
    end]]
end

function EHIAssaultTracker:AssaultStart(diff)
    if self._diff ~= diff then
        self._diff = diff
        self:CalculateDifficultyRamp()
    end
    self:AnimateBG()
    self:StopTextAnim()
    self._time = self:CalculateAssaultTime()
    self:SetIconColor(Build)
    self._state = State.build
    self._assault = true
    self.update = self.update_assault
    if self._cs_assault_extender then
        self:SetHook()
    end
end

function EHIAssaultTracker:CalculateDifficultyDependentValue(values)
    return lerp(values[self._difficulty_point_index], values[self._difficulty_point_index + 1], self._difficulty_ramp)
end

function EHIAssaultTracker:CalculateAssaultTime()
    local build = assault_values.build_duration
    local sustain = lerp(self:CalculateDifficultyDependentValue(assault_values.sustain_duration_min), self:CalculateDifficultyDependentValue(assault_values.sustain_duration_max), math.random()) * managers.groupai:state():_get_balancing_multiplier(assault_values.sustain_duration_balance_mul)
    local fade = assault_values.fade_duration
    if self._is_client then
        self._to_sustain_t = build
    end
    self._assault_t = build + sustain
    self._sustain_original_t = sustain
    if self._cs_assault_extender then
        sustain = self:CalculateCSSustainTime(sustain)
    end
    self._to_fade_t = build + sustain
    return build + sustain + fade
end

function EHIAssaultTracker:CalculateCSSustainTime(sustain, n_of_hostages)
    n_of_hostages = n_of_hostages or managers.groupai:state():hostage_count()
    local n_of_jokers = managers.groupai:state():get_amount_enemies_converted_to_criminals()
    local n = math.min(n_of_hostages + n_of_jokers, self._cs_max_hostages)
    local new_sustain = sustain + self._sustain_original_t * (self._cs_duration - (self._cs_deduction * n))
    return new_sustain
end

function EHIAssaultTracker:OnMinionCountChanged()
    if self._state ~= State.fade then
        self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t))
    end
end

function EHIAssaultTracker:UpdateSustainTime(new_sustain)
    if new_sustain ~= self._time then
        local time_diff = new_sustain - self._time
        self._to_fade_t = self._to_fade_t + time_diff
        self._time = self._time + time_diff
    end
end

function EHIAssaultTracker:OnEnterSustain()
    self._state = State.sustain
    self:SetIconColor(Sustain)
    if self._cs_assault_extender then
        self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t))
    end
end

function EHIAssaultTracker:SetHook()
    EHI:HookWithID(HUDManager, "set_control_info", "EHI_AssaultTime_set_control_info", function(hud, data)
        if self._state ~= State.fade then
            self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t, data.nr_hostages))
        end
    end)
end

function EHIAssaultTracker:AssaultEnd(diff)
    if self._diff ~= diff then
        self._diff = diff
        self:CalculateDifficultyRamp()
    end
    self:AnimateBG()
    self:StopTextAnim()
    self._hostage_delay_disabled = nil
    self._time = self:CalculateBreakTime() + (2 * math.random())
    self:ComputeHostageDelay()
    self:CheckIfHostageIsPresent()
    self:SetIconColor(Control)
    self._state = State.control
    self._assault = nil
    self.update = self.update_break
end

function EHIAssaultTracker:StopTextAnim()
    self._text:stop()
    self:SetTextColor(Color.white)
end

function EHIAssaultTracker:CaptainArrived()
    self:RemoveTrackerFromUpdate()
    self._text:stop()
    self:SetTextColor(Color.red)
    self:SetIconColor(Captain)
    self._time_warning = false
end

function EHIAssaultTracker:CaptainDefeated()
    self._time = 5
    self:SetTextColor(Color.white)
    self:SetIconColor(Fade)
    self:AddTrackerToUpdate()
end

function EHIAssaultTracker:delete()
    if self._time <= 0 then
        self.update = self.update_negative
        self._time = -self._time
        if not self._assault then
            self:StopTextAnim()
            self:AnimateNegative()
        end
        return
    end
    EHIAssaultTracker.super.delete(self)
end

EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
    if mode == "phalanx" then
        managers.ehi:CallFunction("AssaultTime", "CaptainArrived")
    else
        managers.ehi:CallFunction("AssaultTime", "CaptainDefeated")
    end
end)

local _Active = false
local function ActivateHooks()
    local function f()
        managers.ehi:CallFunction("Assault", "OnMinionCountChanged")
    end
    EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, f)
    EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, f)
end
local function CheckIfModifierIsActive()
    if _Active then
        return
    end
    local mod = managers.modifiers
    for category, data in pairs(mod._modifiers) do
        if category == "crime_spree" then
            for _, modifier in ipairs(data) do
                if modifier._type == "ModifierAssaultExtender" then
                    EHIAssaultTracker._cs_duration = modifier:value("duration") * 0.01
                    EHIAssaultTracker._cs_deduction = modifier:value("deduction") * 0.01
                    EHIAssaultTracker._cs_max_hostages = modifier:value("max_hostages")
                    EHIAssaultTracker._cs_assault_extender = true
                    ActivateHooks()
                    _Active = true
                    break
                end
            end
        end
    end
end
local ListenerModifier = class(BaseModifier)
function ListenerModifier:OnEnterSustainPhase(...)
    managers.ehi:CallFunction("Assault", "OnEnterSustain")
end
EHI:AddCallback(EHI.CallbackMessage.InitFinalize, function()
    managers.modifiers:add_modifier(ListenerModifier, "EHI")
    CheckIfModifierIsActive()
end)
if EHI:IsClient() then
    EHI:HookWithID(CrimeSpreeManager, "on_finalize_modifiers", "EHI_CrimeSpree_on_finalize_modifiers", function(...)
        CheckIfModifierIsActive()
    end)
end