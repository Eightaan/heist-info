EHIcac10Tracker = class(EHIAchievementTracker)
EHIcac10Tracker._update = false
EHIcac10Tracker.FormatProgress = EHIProgressTracker.Format
EHIcac10Tracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIcac10Tracker.IncreaseProgressMax = EHIProgressTracker.IncreaseProgressMax
function EHIcac10Tracker:init(panel, params)
    self._max = 0
    self._progress = 0
    EHIcac10Tracker.super.init(self, panel, params)
end

function EHIcac10Tracker:OverridePanel()
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._progress_text = self._time_bg_box:text({
        name = "text2",
        text = self:FormatProgress(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self:FitTheText(self._progress_text)
    self._progress_text:set_left(0)
    self._text:set_left(self._progress_text:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIcac10Tracker:AnimateWarning()
    if self._text and alive(self._text) then
        local progress = self._progress_text
        self._text:animate(function(o)
            while true do
                local t = 0
                while t < 1 do
                    t = t + coroutine.yield()
                    local n = 1 - sin(t * 180)
                    --local r = lerp(1, 0, n)
                    local g = lerp(1, 0, n)
                    local c = Color(1, g, g)
                    o:set_color(c)
                    progress:set_color(c)
                end
            end
        end)
    end
end

function EHIcac10Tracker:SetProgressMax(max)
    self._max = max
    self._progress_text:set_text(self:FormatProgress())
end

function EHIcac10Tracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_text:set_text(self:FormatProgress())
        self:FitTheText(self._progress_text)
        self:AnimateBG()
    end
end

function EHIcac10Tracker:SetCompleted(force)
    if (self._progress == self._max and not self._status) or force then
        self._status = "completed"
        self._text:stop()
        self:SetTextColor(Color.green)
        self.update = self.update_fade
        self._disable_counting = true
        self._achieved_popup_showed = true
    end
end

function EHIcac10Tracker:SetTextColor(color)
    EHIcac10Tracker.super.SetTextColor(self, color)
    self._progress_text:set_color(color)
end

EHIgreen1Tracker = class(EHIProgressTracker)
function EHIgreen1Tracker:SetCompleted(force)
    EHIgreen1Tracker.super.SetCompleted(self, force)
    self._disable_counting = false
end

function EHIgreen1Tracker:SetProgress(progress)
    EHIgreen1Tracker.super.SetProgress(self, progress)
    EHI:Log("green_1 -> Progress: " .. tostring(progress))
end

local EHI = EHI
EHI.AchievementTrackers.EHIgreen1Tracker = true
EHI.AchievementTrackers.EHIcac10Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [101299] = { time = 300, id = "Thermite", icons = { Icon.Fire }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1012991 } },
    [1012991] = { time = 90, id = "ThermiteShorterTime", icons = { Icon.Fire, Icon.Wait }, class = TT.Warning }, -- Triggered by 101299
    [101325] = { special_function = SF.TriggerIfEnabled, data = { 1013251, 1013252 } },
    [1013251] = { time = 180, id = "Thermite", icons = { Icon.Fire }, special_function = SF.SetTimeOrCreateTracker },
    [1013252] = { id = "ThermiteShorterTime", special_function = SF.RemoveTracker },
    [101684] = { time = 5.1, id = "C4", icons = { Icon.C4 } },
    [100211] = { chance = 10, id = "PCChance", icons = { Icon.PCHack }, class = TT.Chance },
    [101226] = { id = "PCChance", special_function = SF.IncreaseChanceFromElement }, -- +17%
    [106680] = { id = "PCChance", special_function = SF.RemoveTracker },
    [102567] = { id = "PCChance", special_function = SF.RemoveTracker } -- Loud started
}
local DisableWaypoints = {}
for i = 0, 300, 100 do
    -- Hacking PC (repair icon)
    DisableWaypoints[EHI:GetInstanceElementID(100024, i)] = true
end

local StartAchievementCountdown = EHI:GetFreeCustomSpecialFunctionID()
local achievements =
{
    green_1 =
    {
        difficulty_pass = false, -- TODO: Finish; remove after that
        elements =
        {
            [103373] = { max = 6, class = "EHIgreen1Tracker", remove_after_reaching_target = false },
            [102153] = { special_function = SF.IncreaseProgress },
            [102333] = { special_function = SF.DecreaseProgress },
            [102539] = { special_function = SF.DecreaseProgress }
        }
    },
    green_3 =
    {
        elements =
        {
            [103373] = { time = 817, class = TT.Achievement },
            [102567] = { special_function = SF.SetAchievementFailed },
            [103491] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            if EHI.ConditionFunctions.IsStealth() then
                self:AddTimedAchievementTracker("green_3", 817)
            end
        end
    },
    cac_10 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101341] = { time = 30, class = "EHIcac10Tracker", condition_function = CF.IsLoud },
            [107072] = { special_function = SF.SetAchievementComplete },
            [101544] = { special_function = StartAchievementCountdown, trigger_times = 1 },
            [107066] = { special_function = SF.IncreaseProgressMax },
            [107067] = { special_function = SF.IncreaseProgress },
        }
    }
}

--[[local other =
{
    [106046] = EHI:AddAssaultDelay({ time = 5 + 40 + 17 }),
    [102213] = EHI:AddAssaultDelay({ time = 0, special_function = SF.SetTimeOrCreateTracker })
}

if EHI:IsClient() then
    other[102212] = EHI:AddAssaultDelay({ time = 17 })
end]]

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:DisableWaypoints(DisableWaypoints)
EHI:RegisterCustomSpecialFunction(StartAchievementCountdown, function(...)
    managers.ehi:StartTrackerCountdown("cac_10")
end)
EHI:ShowLootCounter({
    max = 14,
    triggers =
    {
        [106684] = { max = 70, special_function = SF.IncreaseProgressMax }
    }
})

local tbl = {}
for i = 0, 300, 100 do
    --levels/instances/unique/red/red_hacking_computer
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    tbl[EHI:GetInstanceUnitID(100000, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100018, i) }
end
for i = 6000, 6200, 200 do
    --levels/instances/unique/red/red_gates
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    tbl[EHI:GetInstanceUnitID(100006, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100014, i) }
end
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        fwb_server_room_open = 2000,
        fwb_rewired_circuit_box = { amount = 1500, stealth = true },
        fwb_found_code = { amount = 1000, stealth = true },
        pc_hack = { amount = 2000, loud = true },
        fwb_gates_open_stealth = 2000,
        fwb_gates_open_loud = 4000,
        vault_open = { amount = 2000, stealth = true },
        thermite_done = 6000,
        fwb_c4_escape = { amount = 2000, loud = true },
        fwb_overdrill = 40000,
        escape = 2000,
        loud_escape = 2000
    },
    loot =
    {
        money = 1000
    }
})