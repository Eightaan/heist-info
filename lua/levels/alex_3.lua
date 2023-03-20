local EHI = EHI
local SF = EHI.SpecialFunctions
local delay = 2
local triggers = {
    [1] = { special_function = SF.RemoveTrigger, data = { 100668, 100669, 100670 } },
    [100668] = { time = 240 + delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [100669] = { time = 180 + delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [100670] = { time = 120 + delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } }
}

local other =
{
    [100782] = EHI:AddAssaultDelay({ time = 20 + 10 + 30 })
}

EHI:ParseTriggers({ mission = triggers, other = other }, "HeliLootDrop", EHI.Icons.HeliLootDrop)
local Money = 0
local MoneyTaken = 0
local Exploded = false
local function MoneySpawned(bag)
    if Exploded then
        return
    end
    Money = Money + 1
    managers.ehi:CallFunction("LootCounter", "RandomLootSpawned2", bag, true)
end
local function MoneyTakenFromLuggage(...)
    if Exploded then
        return
    end
    MoneyTaken = MoneyTaken + 1
end
local function DelayRejection(bag)
    if Exploded then
        return
    end
    EHI:DelayCall(tostring(bag), 2, function()
        managers.ehi:CallFunction("LootCounter", "RandomLootDeclined2", bag)
    end)
end
local function Explosion() -- Someone forgot to defuse...
    Exploded = true
    managers.ehi:CallFunction("LootCounter", "SetMaxRandom", 0)
    if Money == MoneyTaken then
        return
    end
    managers.ehi:DecreaseTrackerProgressMax("LootCounter", Money - MoneyTaken) -- Someone forgot money in the luggage, too bad, it is lost now for good
end
local loot_triggers =
{
    [100118] = { special_function = SF.CustomCode, f = Explosion, trigger_times = 1 }, -- Bus explosion, removes all random loot
    [101520] = { special_function = SF.DecreaseProgressMax } -- Loot burned, triggers for every bag if it satisfies condition
}
local Luggage =
{
    [100399] = 100531,
    [100434] = 100534,
    [100435] = 100535,
    [100436] = 100536,
    [100455] = 100541,
    [100456] = 100543,
    [100458] = 100546,
    [100459] = 100544,
    [100465] = 100542,
    [100471] = 100540,
    [100475] = 100539,
    [100497] = 100538,
    [101484] = 100537,
    [101485] = 100521
}
for element, unit in pairs({
    [101488] = 100456,
    [101491] = 100455,
    [101496] = 100436,
    [101497] = 100435,
    [101498] = 100434,
    [101499] = 100399,
    [101508] = 101485,
    [101509] = 101484,
    [101510] = 100497,
    [101511] = 100475,
    [101512] = 100471,
    [101513] = 100465,
    [101514] = 100459,
    [101515] = 100458
}) do
    loot_triggers[element] = { special_function = SF.CustomCode, f = MoneySpawned, arg = unit }
    managers.mission:add_runned_unit_sequence_trigger(unit, "load", MoneyTakenFromLuggage)
    managers.mission:add_runned_unit_sequence_trigger(Luggage[unit], "open", function(...)
        DelayRejection(unit)
    end)
end
EHI:ShowLootCounter({
    max_random = 14,
    triggers = loot_triggers,
    offset = true
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 2000,
        all_bags_secured = 14000
    },
    no_total_xp = true
})