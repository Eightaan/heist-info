local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local heli_anim = 35
local heli_anim_full = 35 + 10 -- 10 seconds is hose lifting up animation when chopper goes refilling
local thermite_right = { time = 86, id = "Thermite", icons = { Icon.Fire } }
local thermite_left_top = { time = 90, id = "Thermite", icons = { Icon.Fire } }
local heli_20 = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, Icon.Goto }, special_function = SF.ExecuteIfElementIsEnabled }
local heli_65 = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, Icon.Goto }, special_function = SF.ExecuteIfElementIsEnabled }
local HeliWaterFill = { Icon.Heli, Icon.Water }
if EHI:GetOption("show_one_icon") then
    HeliWaterFill = { { icon = Icon.Heli, color = Color("D4F1F9") } }
end
local cow_4 = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101499] = { time = 155 + 25, id = "EscapeHeli", icons = Icon.HeliEscape },
    [101253] = heli_65,
    [101254] = heli_20,
    [101255] = heli_65,
    [101256] = heli_20,
    [101259] = heli_65,
    [101278] = heli_20,
    [101279] = heli_65,
    [101280] = heli_20,

    [101691] = { time = 10 + 700/30, id = "PlaneEscape", icons = Icon.HeliEscape },

    [102996] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },

    [102825] = { id = "WaterFill", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 160, no = 300 } },
    [102905] = { id = "WaterFill", special_function = SF.PauseTracker },
    [102920] = { id = "WaterFill", special_function = SF.UnpauseTracker },

    [1] = { id = "HeliWaterFill", special_function = SF.PauseTracker },
    [2] = { id = "HeliWaterReset", icons = { Icon.Heli, Icon.Water, Icon.Loop }, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 62 + heli_anim_full, no = 122 + heli_anim_full } },

    -- Right
    [100283] = thermite_right,
    [100284] = thermite_right,
    [100288] = thermite_right,

    -- Left
    [100285] = thermite_left_top,
    [100286] = thermite_left_top,
    [100560] = thermite_left_top,

    -- Top
    [100282] = thermite_left_top,
    [100287] = thermite_left_top,
    [100558] = thermite_left_top,
    [100559] = thermite_left_top
}
for _, index in ipairs({ 100, 150, 250, 300 }) do
    triggers[EHI:GetInstanceElementID(100032, index)] = { time = 240, id = "HeliWaterFill", icons = HeliWaterFill, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists }
    triggers[EHI:GetInstanceElementID(100030, index)] = { id = "HeliWaterFill", special_function = SF.PauseTracker }
    triggers[EHI:GetInstanceElementID(100037, index)] = { special_function = SF.Trigger, data = { 1, 2 } }
end

local achievements =
{
    cow_3 =
    {
        elements =
        {
            [103461] = { time = 5, class = TT.Achievement, trigger_times = 1 },
            [103458] = { special_function = SF.SetAchievementComplete }
        }
    },
    cow_4 =
    {
        elements =
        {
            [101031] = { status = "defend", class = TT.AchievementStatus, special_function = cow_4 },
            [103468] = { special_function = SF.SetAchievementFailed },
            [104357] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local LootCounter = EHI:GetOption("show_loot_counter")
local other =
{
    [101041] = EHI:AddLootCounter(function()
        local LootTrigger = {}
        local Trigger = { max = 1, special_function = SF.IncreaseProgressMax } -- Money spawned
        for _, index in ipairs({ 580, 830, 3120, 3370, 3620, 3870 }) do
            LootTrigger[EHI:GetInstanceElementID(100197, index)] = Trigger
            LootTrigger[EHI:GetInstanceElementID(100198, index)] = Trigger
            LootTrigger[EHI:GetInstanceElementID(100201, index)] = Trigger
            LootTrigger[EHI:GetInstanceElementID(100202, index)] = Trigger
        end
        EHI:ShowLootCounterNoCheck({
            max = 4,
            -- 1 flipped wagon crate; guaranteed to have gold or 2x money; 15% chance to spawn 2x money, otherwise gold
            -- If second money bundle spawns, the maximum is increased in the Trigger above
            additional_loot = 1,
            triggers = LootTrigger,
            hook_triggers = true
        })
    end, LootCounter),
    [101018] = EHI:AddAssaultDelay({ time = 30, special_function = SF.AddTimeByPreplanning, data = { id = 101024, yes = 90, no = 60 } })
}
if LootCounter then
    -- 1 random loot in train wagon, 35% chance to spawn
    -- Wagons are selected randomly; sometimes 2 with possible loot spawns, sometimes 1
    local IncreaseMaxRandomLoot = EHI:GetFreeCustomSpecialFunctionID()
    other[104274] = { special_function = IncreaseMaxRandomLoot, index = 500 }
    other[104275] = { special_function = IncreaseMaxRandomLoot, index = 520 }
    other[104276] = { special_function = IncreaseMaxRandomLoot, index = 1080 }
    other[104277] = { special_function = IncreaseMaxRandomLoot, index = 1100 }
    other[104278] = { special_function = IncreaseMaxRandomLoot, index = 1120 }
    other[104279] = { special_function = IncreaseMaxRandomLoot, index = 1140 }
    other[104280] = { special_function = IncreaseMaxRandomLoot, index = 1160 }
    other[104281] = { special_function = IncreaseMaxRandomLoot, index = 1300 }
    local function DelayRejection(crate)
        EHI:DelayCall(tostring(crate), 2, function()
            managers.ehi:CallFunction("LootCounter", "RandomLootDeclined2", crate)
        end)
    end
    local function LootSpawned(crate)
        managers.ehi:CallFunction("LootCounter", "RandomLootSpawned2", crate, true)
    end
    EHI:RegisterCustomSpecialFunction(IncreaseMaxRandomLoot, function(trigger, ...)
        local index = trigger.index
        local crate = EHI:GetInstanceUnitID(100000, index)
        local LootTrigger = {}
        LootTrigger[EHI:GetInstanceElementID(100009, index)] = { special_function = SF.CustomCode, f = LootSpawned, arg = crate }
        LootTrigger[EHI:GetInstanceElementID(100010, index)] = { special_function = SF.CustomCode, f = LootSpawned, arg = crate }
        managers.mission:add_runned_unit_sequence_trigger(crate, "interact", function(...)
            DelayRejection(crate)
        end)
        EHI:AddTriggers2(LootTrigger, nil, "LootCounter")
        EHI:HookElements(LootTrigger)
        managers.ehi:CallFunction("LootCounter", "IncreaseMaxRandom", 1)
    end)
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:RegisterCustomSpecialFunction(cow_4, function(trigger, element, enabled)
    if enabled then
        EHI:CheckCondition(trigger)
    end
end)
EHI:AddXPBreakdown({
    objective =
    {
        vault_found = 2000,
        the_bomb2_vault_filled = 12000,
        ggc_c4_taken = 6000,
        escape = 12000
    },
    loot_all = 1500
})