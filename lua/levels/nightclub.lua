local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local AssetLootDropOff = { Icon.Car, Icon.LootDrop }
if EHI:GetOption("show_one_icon") then
    AssetLootDropOff = { Icon.LootDrop }
end
local preload =
{
    {} -- Escape
}
local triggers = {
    -- Time before escape is available
    [102808] = { run = { time = 65 } },
    [102811] = { run = { time = 80 } },
    [103591] = { run = { time = 126 } },
    [102813] = { run = { time = 186 } },
    [100797] = { run = { time = 240 } },
    [100832] = { run = { time = 270 } },

    -- Fire
    [101412] = { time = 300, id = "Fire1", icons = { Icon.Fire }, class = TT.Warning },
    [101453] = { time = 300, id = "Fire2", icons = { Icon.Fire }, class = TT.Warning },

    -- Asset
    [103094] = { time = 20 + (40/3), id = "AssetLootDropOff", icons = AssetLootDropOff }
    -- 20: Base Delay
    -- 40/3: Animation finish delay
    -- Total 33.33 s
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        -- Civilian kills do not count towards escape chance
        -- Reported in: https://steamcommunity.com/app/218620/discussions/14/5487063042655462839/
        managers.ehi:AddEscapeChanceTracker(false, 25, 0)
    end)
end

local BaseAssaultDelay = 3.5 + 2.5 + 3 + 2 + 30
local other =
{
    [101159] = EHI:AddAssaultDelay({ time = 12 + BaseAssaultDelay }),
    [101166] = EHI:AddAssaultDelay({ time = 10 + BaseAssaultDelay }),
    [101167] = EHI:AddAssaultDelay({ time = 15 + BaseAssaultDelay }),
    [104285] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}

EHI:ParseTriggers({
    mission = triggers,
    other = other,
    preload = preload
}, "Escape", Icon.CarEscape)
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 10000, stealth = true },
            { amount = 8000, loud = true },
            { amount = 4000, loud = true, c4_used = true }
        }
    },
    loot_all = 1000
})