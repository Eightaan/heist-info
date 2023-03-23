local EHI = EHI
local Icon = EHI.Icons
EHIHeliTracker = class(EHICountTracker)
EHIHeliTracker._forced_icons = { "enemy", { icon = Icon.Wait, visible = false } }
EHIHeliTracker.AnimateCompletion = EHITimerTracker.AnimateCompletion
function EHIHeliTracker:OverridePanel()
    self._time_text = self._time_bg_box:text({
        name = "time_text",
        text = EHIHeliTracker.super.super.Format(self),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self._time_text:set_left(self._time_bg_box:right())
    self._panel_override_w = self._time_bg_box:w() + self._icon_size_scaled
end

function EHIHeliTracker:update(t, dt)
    self._time = self._time - dt
    self._time_text:set_text(EHIHeliTracker.super.super.Format(self))
    if self._time <= 10 and not self._time_warning then
        self._time_warning = true
        self:AnimateCompletion()
    end
    if self._time <= 0 then
        self:ObjectiveComplete("time")
    end
end

function EHIHeliTracker:EnableUpdate()
    self._time = 600 -- See element ´heli_is_ready_timer´ MissionScriptElement 103869
    local new_w = self._panel:w() * 3
    self:SetPanelW(new_w)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self:FitTheText(self._time_text)
    self._parent_class:ChangeTrackerWidth(self._id, self:GetPanelSize())
    self:SetIconX(self._time_bg_box:w() + self._gap_scaled)
    if self._icon2 then
        self._icon2:set_x(self:GetPanelSize() - self._icon_size_scaled)
        self._icon2:set_visible(true)
    end
    self:AddTrackerToUpdate()
end

function EHIHeliTracker:GetPanelSize()
    local n = self._icon2 and 2 or 1
    return self._time_bg_box:w() + (self._icon_size_scaled * n)
end

function EHIHeliTracker:ObjectiveComplete(objective)
    if objective == "count" then
        self._text:set_color(Color.green)
    elseif objective == "time" then
        self:SetStatusText("done", self._time_text)
        self._time_text:stop()
        self._time_text:set_color(Color.green)
    else -- Assault end
        self._text:set_color(Color.green)
        self._time_text:stop()
        self._time_text:set_color(Color.green)
    end
    self:AnimateBG()
    self:RemoveTrackerFromUpdate()
end

function EHIHeliTracker:destroy()
    if self._time_text and alive(self._time_text) then
        self._time_text:stop()
    end
    EHIHeliTracker.super.destroy(self)
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local ExecuteIfElementIsEnabled = EHI:GetFreeCustomSpecialFunctionID()
local DelayExecution = EHI:GetFreeCustomSpecialFunctionID()
local kills = 7 -- Normal + Hard
if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
    -- Very Hard + OVERKILL
    kills = 10
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) then
    -- Mayhem+
    kills = 15
end
local triggers = {
    [100001] = { time = 30, id = "BileArrival", icons = { Icon.Heli, Icon.C4 } },
    [100182] = { id = "SniperDeath", special_function = SF.RemoveTracker },
    [104555] = { id = "SniperDeath", special_function = SF.IncreaseProgress },
    [100147] = { time = 18.2, id = "HeliWinchLoop", icons = { Icon.Heli, Icon.Winch, Icon.Loop }, special_function = ExecuteIfElementIsEnabled },
    [102181] = { id = "HeliWinchLoop", special_function = SF.RemoveTracker },

    [100068] = { max = kills, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = TT.Progress },
    [103446] = { time = 20 + 6 + 4, id = "HeliDropsC4", icons = { Icon.Heli, Icon.C4, Icon.Goto } },
    [100082] = { time = 40, id = "HeliComesWithMagnet", icons = { Icon.Heli, Icon.Winch } },

    [100206] = { time = 30, id = "LoweringTheWinch", icons = { Icon.Heli, Icon.Winch, Icon.Goto } },

    [102001] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },

    [100060] = { special_function = SF.Trigger, data = { 1000601, 1000602 } },
    [1000601] = { id = "PanicRoomTakeoff", flash_times = 1, class = "EHIHeliTracker" },
    [1000602] = { special_function = SF.CustomCode, f = function()
        local count = 0
        if EHI:IsPlayingFromStart() then
            local element_area_counter = managers.mission:get_element_by_id(103832) -- ´enemies alive in volume´ ElementCounter 103832
            if not element_area_counter then
                EHI:DelayCall("RemovePanicRoomTakeoff", 1, function()
                    managers.ehi:RemoveTracker("PanicRoomTakeoff")
                end)
                return
            end
            count = element_area_counter:counter_value()
        else
            local element_area = managers.mission:get_element_by_id(100216) -- ´on enter´ ElementAreaReportTrigger 100216
            if not element_area then
                EHI:DelayCall("RemovePanicRoomTakeoff", 1, function()
                    managers.ehi:RemoveTracker("PanicRoomTakeoff")
                end)
                return
            end
            local all_enemies = managers.enemy:all_enemies()
            for _, enemy_data in pairs(all_enemies) do
                if not enemy_data.death_t and enemy_data.unit and alive(enemy_data.unit) then
                    if element_area:_is_inside(enemy_data.unit:position()) then
                        count = count + 1
                    end
                end
            end
        end
        managers.ehi:SetTrackerCount("PanicRoomTakeoff", count)
        EHI:AddTriggers({
            [103700] = { special_function = SF.CustomCode, f = function()
                managers.ehi:IncreaseTrackerCount("PanicRoomTakeoff")
            end},
            [103701] = { special_function = SF.CustomCode, f = function()
                managers.ehi:DecreaseTrackerCount("PanicRoomTakeoff")
            end}
        }, "Trigger", {})
        EHI:HookElements({ [103700] = true, [103701] = true })
    end},
    [103869] = { special_function = SF.CustomCode, f = function()
        managers.ehi:CallFunction("PanicRoomTakeoff", "EnableUpdate")
    end},
    [1] = { special_function = SF.Trigger, data = { 2, 3 } },
    [2] = { special_function = SF.RemoveTrigger, data = { 103700, 103701 } },
    [3] = { id = "PanicRoomTakeoff", special_function = DelayExecution },
    [4] = { id = "PanicRoomTakeoff", special_function = SF.RemoveTracker },
    [103901] = { special_function = SF.CustomCode, f = function()
        managers.ehi:CallFunction("PanicRoomTakeoff", "ObjectiveComplete", "count")
    end },
    [104661] = { special_function = SF.CustomCode, f = function()
        managers.ehi:CallFunction("PanicRoomTakeoff", "ObjectiveComplete", "assault_end")
    end },
    [100405] = { time = 15, id = "HeliTakeoff", icons = { Icon.Heli, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } }
}

local achievements =
{
    flat_2 =
    {
        elements =
        {
            [104859] = { special_function = SF.SetAchievementComplete },
            [100049] = { time = 20, class = TT.Achievement }
        }
    },
    cac_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100809] = { time = 60, class = TT.Achievement, trigger_times = 1 },
            [100805] = { special_function = SF.SetAchievementComplete },
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:RegisterCustomSpecialFunction(ExecuteIfElementIsEnabled, function(trigger, element, enabled)
    if enabled then
        if managers.ehi:TrackerExists(trigger.id) then
            managers.ehi:SetTrackerTimeNoAnim(trigger.id, trigger.time)
        else
            EHI:CheckCondition(trigger)
        end
    end
end)
EHI:RegisterCustomSpecialFunction(DelayExecution, function(trigger, ...)
    EHI:DelayCall("Remove" .. trigger.id, 10, function()
        EHI:Trigger(4)
    end)
end)
EHI:AddXPBreakdown({
    objective =
    {
        panic_room_found = 2000,
        saws_done = 8000,
        panic_room_killed_all_snipers = 3000,
        c4_set_up = 2000,
        panic_room_roof_secured = 4000,
        panic_room_magnet_attached = 1000,
        panic_room_defended_heli = 3000,
        escape = 2000
    },
    loot =
    {
        meth = 500,
        coke = 500,
        toothbrush = 1000
    },
    no_total_xp = true
})