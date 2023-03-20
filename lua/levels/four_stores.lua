local function LootSafeIsVisible()
    local unit = managers.worlddefinition:get_unit(101153)
    if not unit then
        return false
    end
    if not unit:damage() then
        return false
    end
    if unit:damage()._state then
        local group = unit:damage()._state.graphic_group
        return not group.safe -- If the "safe" group does not exist, the safe is visible
    else
        return false
    end
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_anim_delay = 320 / 30
local preload =
{
    {} -- Escape
}
local triggers = {
    [101890] = { special_function = SF.CustomCodeDelayed, t = 4, f = function()
        if LootSafeIsVisible() then
            EHI:ShowLootCounter({ max = 1 })
        end
    end},
    -- Time before escape vehicle arrives
    [102492] = { run = { time = 40 + van_anim_delay } },
    [102493] = { run = { time = 30 + van_anim_delay } },
    [102494] = { run = { time = 20 + van_anim_delay } },
    [102495] = { run = { time = 50 + van_anim_delay } },
    [102496] = { run = { time = 60 + van_anim_delay } },
    [102497] = { run = { time = 70 + van_anim_delay } },
    [102498] = { run = { time = 100 + van_anim_delay } },
    [102499] = { run = { time = 90 + van_anim_delay } },
    [102511] = { run = { time = 80 + van_anim_delay } },
    [102512] = { run = { time = 110 + van_anim_delay } },
    [102513] = { run = { time = 120 + van_anim_delay } },
    [102526] = { run = { time = 130 + van_anim_delay } },
    [103592] = { run = { time = 160 + van_anim_delay } },
    [103593] = { run = { time = 180 + van_anim_delay } },
    [103594] = { run = { time = 200 + van_anim_delay } },

    [102505] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101006 } },
    [103200] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103234 } }
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 30)
    end)
end

local CopArrivalDelay = 30 -- Normal
if EHI:IsDifficulty(EHI.Difficulties.Hard) then
    CopArrivalDelay = 20
elseif EHI:IsDifficulty(EHI.Difficulties.VeryHard) then
    CopArrivalDelay = 10
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    CopArrivalDelay = 0
end
local FirstAssaultBreak = 15 + 2.5 + 3 + 2 + 30 + 20 + 30
local other =
{
    [103501] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },
    [103278] = EHI:AddAssaultDelay({ time = FirstAssaultBreak + CopArrivalDelay, trigger_times = 1 }), -- Full assault break; 15s (55s delay)
    [101167] = EHI:AddAssaultDelay({ time = FirstAssaultBreak, special_function = SF.AddTrackerIfDoesNotExist }), -- 15s (55s delay)
    [101166] = EHI:AddAssaultDelay({ time = FirstAssaultBreak - 5, special_function = SF.SetTimeOrCreateTracker }), -- 10s (65s delay)
    [101159] = EHI:AddAssaultDelay({ time = FirstAssaultBreak - 2, special_function = SF.SetTimeOrCreateTracker }) -- 13s (60s delay)
}
EHI:ParseTriggers({ mission = triggers, other = other, preload = preload }, "Escape", Icon.CarEscape)
EHI:AddLoadSyncFunction(function(self)
    if LootSafeIsVisible() then
        local secured = managers.loot:GetSecuredBagsAmount()
        if secured == 0 then
            EHI:ShowLootCounter({ max = 1 })
        end
    end
end)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 6000
    }
})