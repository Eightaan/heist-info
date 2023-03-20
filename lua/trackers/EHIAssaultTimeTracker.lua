local EHI = EHI
local lerp = math.lerp
local Color = Color
local Captain = Color(255, 255, 128, 0) / 255
local Build = Color.yellow
local Sustain = Color(255, 237, 127, 127) / 255
local Fade = Color(255, 0, 255, 255) / 255
if BAI then
    Captain = BAI:GetRightColor("captain")
    Build = BAI:GetColor("build")
    Sustain = BAI:GetColor("sustain")
    Fade = BAI:GetColor("fade")
    BAI:AddEvent(BAI.EventList.Update, function()
        Captain = BAI:GetRightColor("captain")
        Build = BAI:GetColor("build")
        Sustain = BAI:GetColor("sustain")
        Fade = BAI:GetColor("fade")
        EHIAssaultTimeTracker._forced_icons[1].color = Build
    end)
end
local State =
{
    build = 1,
    sustain = 2,
    fade = 3
}
local assault_values = tweak_data.group_ai[tweak_data.levels:get_group_ai_state()].assault
EHIAssaultTimeTracker = class(EHIWarningTracker)
EHIAssaultTimeTracker._forced_icons = { { icon = "assaultbox", color = Build } }
EHIAssaultTimeTracker._is_client = EHI:IsClient()
EHIAssaultTimeTracker.AnimateWarning = EHITimerTracker.AnimateCompletion
function EHIAssaultTimeTracker:init(panel, params)
    self:CalculateDifficultyRamp(params.diff)
    self._original_time = self:CalculateAssaultTime()
    params.time = self._original_time
    EHIAssaultTimeTracker.super.init(self, panel, params)
    self.update_normal = self.update
    self._state = State.build
    if self._cs_assault_extender then
        self:SetHook()
        self.update = self.update_cs
    end
end

function EHIAssaultTimeTracker:update(t, dt)
    EHIAssaultTimeTracker.super.update(self, t, dt)
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

function EHIAssaultTimeTracker:update_cs(t, dt)
    EHIAssaultTimeTracker.super.update(self, t, dt)
    self._assault_t = self._assault_t - dt
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

function EHIAssaultTimeTracker:update_negative(t, dt)
    self._time = self._time + dt
    self._text:set_text("+" .. self:Format())
end

function EHIAssaultTimeTracker:CalculateDifficultyRamp(diff)
    local ramp = tweak_data.group_ai.difficulty_curve_points
    local i = 1
    while (ramp[i] or 1) < diff do
        i = i + 1
    end
    self._difficulty_point_index = i
    self._difficulty_ramp = (diff - (ramp[i - 1] or 0)) / ((ramp[i] or 1) - (ramp[i - 1] or 0))
end

function EHIAssaultTimeTracker:CalculateDifficultyDependentValue(values)
    return lerp(values[self._difficulty_point_index], values[self._difficulty_point_index + 1], self._difficulty_ramp)
end

function EHIAssaultTimeTracker:CalculateAssaultTime()
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

function EHIAssaultTimeTracker:CalculateCSSustainTime(sustain, n_of_hostages)
    n_of_hostages = n_of_hostages or managers.groupai:state():hostage_count()
    local n_of_jokers = managers.groupai:state():get_amount_enemies_converted_to_criminals()
    local n = math.min(n_of_hostages + n_of_jokers, self._cs_max_hostages)
    local new_sustain = sustain + self._sustain_original_t * (self._cs_duration - (self._cs_deduction * n))
    return new_sustain
end

function EHIAssaultTimeTracker:OnMinionCountChanged()
    if self._state ~= State.fade then
        self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t))
    end
end

function EHIAssaultTimeTracker:UpdateSustainTime(new_sustain)
    if new_sustain ~= self._time then
        local time_diff = new_sustain - self._time
        self._to_fade_t = self._to_fade_t + time_diff
        self._time = self._time + time_diff
    end
end

function EHIAssaultTimeTracker:SetHook()
    EHI:HookWithID(HUDManager, "set_control_info", "EHI_AssaultTime_set_control_info", function(hud, data)
        if self._state ~= State.fade then
            self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t, data.nr_hostages))
        end
    end)
end

function EHIAssaultTimeTracker:SetTime(t)
end

function EHIAssaultTimeTracker:UpdateDiff(diff)
    if self._state == State.build then
        self:CalculateDifficultyRamp(diff)
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
end

function EHIAssaultTimeTracker:OnEnterSustain()
    self._state = State.sustain
    self:SetIconColor(Sustain)
    if self._cs_assault_extender then
        self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t))
    end
end

function EHIAssaultTimeTracker:CaptainArrived()
    self:RemoveTrackerFromUpdate()
    self._text:stop()
    self:SetTextColor(Color.red)
    self:SetIconColor(Captain)
    self._time_warning = false
end

function EHIAssaultTimeTracker:CaptainDefeated()
    self._time = 5
    self:SetTextColor(Color.white)
    self:SetIconColor(Fade)
    self:AddTrackerToUpdate()
end

function EHIAssaultTimeTracker:delete()
    if self._time <= 0 then
        self.update = self.update_negative
        self._time = -self._time
        return
    end
    EHI:Unhook("AssaultTime_set_control_info")
    EHIAssaultTimeTracker.super.delete(self)
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
        managers.ehi:CallFunction("AssaultTime", "OnMinionCountChanged")
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
                    EHIAssaultTimeTracker._cs_duration = modifier:value("duration") * 0.01
                    EHIAssaultTimeTracker._cs_deduction = modifier:value("deduction") * 0.01
                    EHIAssaultTimeTracker._cs_max_hostages = modifier:value("max_hostages")
                    EHIAssaultTimeTracker._cs_assault_extender = true
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
    managers.ehi:CallFunction("AssaultTime", "OnEnterSustain")
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