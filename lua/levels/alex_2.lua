local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local assault_delay = 15 + 1 + 30
local other =
{
    [104488] = EHI:AddAssaultDelay({ time = assault_delay, special_function = SF.SetTimeOrCreateTracker }),
    [104489] = EHI:AddAssaultDelay({ time = assault_delay, special_function = SF.AddTrackerIfDoesNotExist }),
    -- Police ambush
    [104535] = { special_function = SF.Trigger, data = { 1045351, 1045352 } },
    [1045351] = EHI:AddAssaultDelay({ time = 30, special_function = SF.SetTimeOrCreateTracker }),
    [1045352] = { special_function = SF.RemoveTrigger, data = { 104488, 104489 } },

    [103696] = EHI:AddLootCounter(function()
        local SafeTriggers =
        {
            -- gen_interactable_sec_safe_05x05 - 7
            -- gen_interactable_sec_safe_2x05 - 5
            -- gen_interactable_sec_safe_1x1 - 2
            -- gen_interactable_sec_safe_1x05 - 2
            loot =
            {
                "spawn_loot_money"
            },
            no_loot =
            {
                "spawn_loot_value_a",
                "spawn_loot_value_d",
                "spawn_loot_value_e",
                "spawn_loot_crap_b",
                "spawn_loot_crap_c",
                "spawn_loot_crap_d"
            }
        }
        local spawned = managers.ehi:CountLootbagsOnTheGround()
        local additional_loot = math.max(0, spawned - 3)
        EHI:ShowLootCounterNoCheck({
            max = spawned,
            additional_loot = additional_loot,
            max_random = 1,
            sequence_triggers =
            {
                [103640] = SafeTriggers,
                [103641] = SafeTriggers,
                [101741] = SafeTriggers,
                [101751] = SafeTriggers,
                [103645] = SafeTriggers,
                [103646] = SafeTriggers,
                [103647] = SafeTriggers,
                [103648] = SafeTriggers,
                [103649] = SafeTriggers,
                [103650] = SafeTriggers,
                [103651] = SafeTriggers,
                [103777] = SafeTriggers,
                [103643] = SafeTriggers,
                [101099] = SafeTriggers,
                [101031] = SafeTriggers,
                [101211] = SafeTriggers
            }
        })
    end)
}
if EHI:GetOption("show_escape_chance") then
    local ShowVanCrashChance = EHI:GetFreeCustomSpecialFunctionID()
    other[100342] = { special_function = ShowVanCrashChance }
    EHI:RegisterCustomSpecialFunction(ShowVanCrashChance, function(...)
        managers.ehi:AddEscapeChanceTracker(false, 25)
    end)
end

EHI:ParseTriggers({
    other = other
})
local ShowAssaultDelay = EHI:GetOption("show_assault_delay_tracker")
EHI:AddOnAlarmCallback(function(dropin)
    if dropin or not ShowAssaultDelay then
        return
    end
    managers.ehi:AddTracker({
        id = "AssaultDelay",
        time = 75 + 15 + 30,
        class = TT.AssaultDelay
    })
end)
EHI:AddXPBreakdown({
    objective =
    {
        rats2_info_destroyed = 4000,
        rats2_trade = 6000,
        rats2_trade_and_steal = 4000
    },
    no_total_xp = true
})