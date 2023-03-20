local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Methlab = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop } }
local element_sync_triggers = {}
local MethlabIndex = { 7800, 8200, 8600 }
local Heli = 30 + 23 + 5
local Truck = 40
if EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    Heli = 3 + 60 + 23 + 5
    Truck = 60
end
local client = EHI:IsClient()
for _, index in ipairs(MethlabIndex) do
    -- Cooking restart
    for i = 100120, 100122, 1 do
        local element_id = EHI:GetInstanceElementID(i, index)
        element_sync_triggers[element_id] = deep_clone(Methlab)
        element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100119, index)
    end
    -- Cooking continuation
    for i = 100169, 100172, 1 do
        local element_id = EHI:GetInstanceElementID(i, index)
        element_sync_triggers[element_id] = deep_clone(Methlab)
        element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100168, index)
    end
end
local delay = 1.5
local triggers = {
    [102177] = { time = Heli, id = "Heli", icons = Icon.HeliDropBag }, -- Time before Bile arrives

    [106013] = { time = Truck, id = "Truck", icons = { Icon.Car }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [106017] = { id = "Truck", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100038, 1300)] = { time = 90 + delay, id = "reader", icons = { Icon.PCHack }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100039, 1300)] = { time = 120 + delay, id = "reader", icons = { Icon.PCHack }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100040, 1300)] = { time = 180 + delay, id = "reader", icons = { Icon.PCHack }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100045, 1300)] = { id = "reader", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100051, 1300)] = { id = "reader", special_function = SF.UnpauseTracker },

    [104299] = { time = 5, id = "C4GasStation", icons = { Icon.C4 } },

    -- Calls with Commissar
    [101388] = { time = 8.5 + 6, id = "FirstCall", icons = { Icon.Phone } },
    [101389] = { time = 10.5 + 8, id = "SecondCall", icons = { Icon.Phone } },
    [103385] = { time = 8.5 + 5, id = "LastCall", icons = { Icon.Phone } }
}
local random_time = { id = Methlab.id, icons = Methlab.icons, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 } }
for _, index in ipairs(MethlabIndex) do
    triggers[EHI:GetInstanceElementID(100152, index)] = { time = 5, id = "MethPickUp", icons = { Icon.Methlab, Icon.Interact } }
    if client then
        triggers[EHI:GetInstanceElementID(100118, index)] = { id = Methlab.id, icons = Methlab.icons, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 5, 25, 40 } }
        triggers[EHI:GetInstanceElementID(100149, index)] = random_time
        triggers[EHI:GetInstanceElementID(100150, index)] = random_time
        triggers[EHI:GetInstanceElementID(100184, index)] = { id = Methlab.id, special_function = SF.RemoveTracker }
    end
end
if client then
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local LootCounter = EHI:GetOption("show_loot_counter")
local money = 5
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    money = 4
elseif EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    money = 3
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) then
    money = 2
end
local function GetNumberOfMethBags()
    for _, index in ipairs(MethlabIndex) do
        local unit_id = EHI:GetInstanceUnitID(100068, index) -- Acid 3
        if managers.game_play_central:GetMissionEnabledUnit(unit_id) then
            -- Unit is enabled, return 3
            return 3
        end
    end
    for _, index in ipairs(MethlabIndex) do
        local unit_id = EHI:GetInstanceUnitID(100067, index) -- Acid 2
        if managers.game_play_central:GetMissionEnabledUnit(unit_id) then
            -- Unit is enabled, return 2
            return 2
        end
    end
    -- If third or second acid is not found in either methlab instance, return one possible bag
    -- No need to check Caustic Soda and Hydrogen Chloride, they spawn with Muriatic Acid
    return 1
end
local Methbags = 0
local MethbagsCooked = 0
local MethbagsPossibleToSpawn = 19
local MethlabExploded = false
local other =
{
    [101937] = EHI:AddAssaultDelay({ time = 10 + 1 + 40 + 30, special_function = SF.AddTimeByPreplanning, data = { id = 100191, yes = 75, no = 45 } }),

    [101218] = EHI:AddLootCounter(function()
        Methbags = GetNumberOfMethBags()
        EHI:ShowLootCounterNoCheck({
            max = money + Methbags,
             -- 19 + 2 // 19 boxes of contrabant, that can spawn chemicals (up to 4); 2 cars with possible loot
            max_random = 19 + 2
        })
    end, LootCounter)
}
if LootCounter then
    -- Basement
    local function IncreaseMaximum()
        managers.ehi:IncreaseTrackerProgressMax("LootCounter", 1)
    end
    local IncreaseMaximumTrigger = { special_function = SF.CustomCode, f = IncreaseMaximum }
    -- Coke
    for i = 102832, 102841, 1 do
        other[i] = IncreaseMaximumTrigger
    end
    -- Weapons
    for i = 104498, 104506, 1 do
        other[i] = IncreaseMaximumTrigger
    end
    local function IncreaseMaximum2()
        if MethlabExploded then
            return
        end
        Methbags = Methbags + 1
        MethbagsPossibleToSpawn = MethbagsPossibleToSpawn - 1
        managers.ehi:CallFunction("LootCounter", "RandomLootSpawned")
    end
    local function DecreaseMaximum()
        if MethlabExploded then
            return
        end
        MethbagsPossibleToSpawn = MethbagsPossibleToSpawn - 1
        managers.ehi:CallFunction("LootCounter", "RandomLootDeclined")
    end
    local IncreaseMaximumTrigger2 = { special_function = SF.CustomCode, f = IncreaseMaximum2 }
    local DecreaseMaximumTrigger = { special_function = SF.CustomCode, f = DecreaseMaximum }
    for i = 9000, 16200, 400 do
        other[EHI:GetInstanceElementID(100007, i)] = DecreaseMaximumTrigger -- Empty
        other[EHI:GetInstanceElementID(100011, i)] = DecreaseMaximumTrigger -- Missiles
        other[EHI:GetInstanceElementID(100012, i)] = DecreaseMaximumTrigger -- Vodka
        other[EHI:GetInstanceElementID(100013, i)] = DecreaseMaximumTrigger -- Coats
        other[EHI:GetInstanceElementID(100014, i)] = DecreaseMaximumTrigger -- Cigars
        other[EHI:GetInstanceElementID(100015, i)] = IncreaseMaximumTrigger2 -- Chemicals for meth
    end

    -- Methlab exploded
    local function BlockMeth()
        if Methbags == 0 then -- Dropin; impossible to tell how many bags were cooked
            return
        end
        managers.ehi:DecreaseTrackerProgressMax("LootCounter", Methbags - MethbagsCooked)
        managers.ehi:CallFunction("LootCounter", "DecreaseMaxRandom", MethbagsPossibleToSpawn)
        MethlabExploded = true
    end
    local function CookingDone()
        MethbagsCooked = MethbagsCooked + 1
    end
    for _, index in ipairs(MethlabIndex) do
        other[EHI:GetInstanceElementID(100158, index)] = { special_function = SF.CustomCode, f = BlockMeth }
        other[EHI:GetInstanceElementID(100159, index)] = { special_function = SF.CustomCode, f = CookingDone }
    end

    -- Cars
    local CarLootBlocked = false
    other[100724] = { special_function = SF.CustomCode, f = function()
        CarLootBlocked = true
    end }
    local function DecreaseMaximum2()
        if CarLootBlocked then
            return
        end
        managers.ehi:CallFunction("LootCounter", "RandomLootDeclined")
    end
    local DecreaseMaximumTrigger2 = { special_function = SF.CustomCode, f = DecreaseMaximum2 }
    -- All cars; does not get triggered when maximum has been reached
    other[100721] = { special_function = SF.CustomCode, f = function()
        managers.ehi:CallFunction("LootCounter", "RandomLootSpawned")
    end }
    -- units/payday2/vehicles/str_vehicle_car_sedan_2_burned/str_vehicle_car_sedan_2_burned/001
    other[100523] = DecreaseMaximumTrigger2 -- Empty money bundle, taken weapons or body spawned
    -- units/payday2/vehicles/str_vehicle_car_crossover_burned/str_vehicle_car_crossover_burned/001
    other[100849] = DecreaseMaximumTrigger2 -- Money should spawn, but ElementEnableUnit does not have any unit to spawn and bag counter goes up by 1
    -- units/payday2/vehicles/str_vehicle_car_sedan_2_burned/str_vehicle_car_sedan_2_burned/006
    other[100918] = DecreaseMaximumTrigger2 -- Nothing spawned
    other[100912] = DecreaseMaximumTrigger2 -- Empty money bundle, taken weapons or body spawned
end

EHI:ParseTriggers({
    mission = triggers,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        hm1_mobsters_killed = 4000,
        hm1_cars_destroyed = 4000,
        hm1_gas_station_destroyed = 4000,
        hm1_hatch_open = 4000,
        hm1_correct_barcode_scanned = 6000,
        hm1_meth_cooked = 500,
        escape = 4000
    },
    loot_all = 1000
})