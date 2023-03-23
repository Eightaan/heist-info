EHIcac33Tracker = class(EHIAchievementStatusTracker)
EHIcac33Tracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIcac33Tracker.FormatProgress = EHIProgressTracker.Format
function EHIcac33Tracker:init(panel, params)
    self._progress = 0
    self._max = 200
    EHIcac33Tracker.super.init(self, panel, params)
end

function EHIcac33Tracker:OverridePanel()
    self._progress_text = self._time_bg_box:text({
        name = "progress",
        text = self:FormatProgress(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = self._text_color,
        visible = false
    })
    self:FitTheText(self._progress_text)
end

function EHIcac33Tracker:Activate()
    self._progress_text:set_visible(true)
    self._text:set_visible(false)
end

function EHIcac33Tracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_text:set_text(self:FormatProgress())
        self:FitTheText(self._progress_text)
        self:AnimateBG(1)
        if self._progress == self._max then
            self:SetCompleted()
        end
    end
end

function EHIcac33Tracker:SetCompleted()
    EHIcac33Tracker.super.SetCompleted(self)
    self._disable_counting = true
    self._progress_text:set_color(Color.green)
    self._progress = 200
    self._progress_text:set_text(self:FormatProgress())
end

function EHIcac33Tracker:SetFailed()
    EHIcac33Tracker.super.SetFailed(self)
    self._disable_counting = true
    self._progress_text:set_color(Color.red)
end

local EHI = EHI
EHI.AchievementTrackers.EHIcac33Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Activate_cac_33 = EHI:GetFreeCustomSpecialFunctionID()
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local thermite = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } }
local triggers = {
    [101897] = { time = 60, id = "LockeSecureHeli", icons = { Icon.Heli, Icon.Winch } }, -- Time before Locke arrives with heli to pickup the money
    [101985] = thermite, -- First grate
    [101984] = thermite -- Second grate
}

local achievements =
{
    jerry_3 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102453] = { class = TT.AchievementStatus },
            [102816] = { special_function = SF.SetAchievementFailed },
            [101314] = { special_function = SF.SetAchievementComplete }
        }
    },
    jerry_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102453] = { time = 83, class = TT.Achievement },
            [102452] = { special_function = SF.SetAchievementComplete },
        }
    },
    cac_33 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [102504] = { status = "land", class = "EHIcac33Tracker" },
            [103486] = { status = "ok", special_function = SF.SetAchievementStatus },
            [103479] = { special_function = SF.SetAchievementComplete },
            [103475] = { special_function = SF.SetAchievementFailed },
            [103487] = { special_function = Activate_cac_33 },
            [103477] = { special_function = SF.IncreaseProgress },
        }
    }
}

local other =
{
    [100653] = EHI:AddAssaultDelay({ time = 2 + 15 + 30, trigger_times = 1 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
local ring = { special_function = SF.IncreaseProgress }
local voff_4_triggers =
{
    [103248] = ring
}
for i = 103252, 103339, 3 do
    voff_4_triggers[i] = ring
end
EHI:ShowAchievementLootCounter({
    achievement = "voff_4",
    max = 9,
    triggers = voff_4_triggers,
    load_sync = function(self)
        self:SetTrackerProgressRemaining("voff_4", self:CountInteractionAvailable("ring_band"))
    end
})
EHI:RegisterCustomSpecialFunction(Activate_cac_33, function(...)
    managers.ehi:CallFunction("cac_33", "Activate")
end)
EHI:AddXPBreakdown({
    objective =
    {
        bos_cargo_door_open = 3000,
        bos_money_released = 3000,
        bos_money_pallet_found = 2500,
        flare = 500,
        bos_found_scattered_money = 700,
        bos_heli_picked_up_money = 1500,
        escape = 6000
    },
    total_xp_override =
    {
        objective =
        {
            bos_money_pallet_found = { times = 2 },
            flare = { times = 3 },
            bos_found_scattered_money = { times = 8 },
            bos_heli_picked_up_money = { times = 3 }
        }
    }
})