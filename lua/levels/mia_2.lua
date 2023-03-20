local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local element_sync_triggers =
{
    [100428] = { time = 24, id = "HeliDropDrill", icons = Icon.HeliDropDrill, hook_element = 100427 }, -- 20s
    [100430] = { time = 24, id = "HeliDropDrill", icons = Icon.HeliDropDrill, hook_element = 100427 } -- 30s
}
local triggers = {
    [100225] = { time = 5 + 5 + 22, id = Icon.Heli, icons = Icon.HeliEscape },
    -- 5 = Base Delay
    -- 5 = Delay when executed
    -- 22 = Heli door anim delay
    -- Total: 32 s
    [100224] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 100926 } },
    [101858] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 101854 } },

    -- Bugged because of retarted use of ENABLED in ElementTimer and ElementTimerTrigger
    [101240] = { time = 540, id = "CokeTimer", icons = { { icon = Icon.Loot, color = Color.red } }, class = TT.Warning },
    [101282] = { id = "CokeTimer", special_function = SF.RemoveTracker }
}
local achievements =
{
    pig_2 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101228] = { time = 210, class = TT.Achievement },
            [100788] = { special_function = SF.SetAchievementComplete }
        }
    }
}
local start_index = { 3500, 3750, 3900, 4450, 4900, 6100, 17600, 17650 }
if EHI:CanShowAchievement("pig_7") then
    achievements.pig_7 = { elements = {} }
    for _, index in ipairs(start_index) do
        achievements.pig_7.elements[EHI:GetInstanceElementID(100024, index)] = { time = 5, class = TT.Achievement }
        achievements.pig_7.elements[EHI:GetInstanceElementID(100039, index)] = { special_function = SF.SetAchievementFailed } -- Hostage blew out
        achievements.pig_7.elements[EHI:GetInstanceElementID(100027, index)] = { special_function = SF.SetAchievementComplete } -- Hostage saved
    end
else
    for _, index in ipairs(start_index) do
        triggers[EHI:GetInstanceElementID(100024, index)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning }
        triggers[EHI:GetInstanceElementID(100039, index)] = { id = "HostageBomb", special_function = SF.RemoveTracker } -- Hostage blew out
        triggers[EHI:GetInstanceElementID(100027, index)] = { id = "HostageBomb", special_function = SF.RemoveTracker } -- Hostage saved
    end
end

if EHI:IsClient() then
    triggers[100426] = { id = "HeliDropDrill", icons = Icon.HeliDropDrill, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 44, 54 } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local LootCounter = EHI:GetOption("show_loot_counter")
local other =
{
    [100043] = EHI:AddLootCounter(function()
        --[[if EHI:IsHost() then
        else
        end]]
    end, LootCounter)
}
if LootCounter then
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        hm2_enter_building = 2000,
        hm2_hostage_rescued = 2000,
        hm2_yellow_gate_open = 2000,
        hm2_magnetic_door_open = 2000,
        hm2_enter_apartment = 2000,
        vault_open = 2000,
        hm2_commissar_dead = 2000,
        escape = 2000
    },
    loot_all = { amount = 1000, times = 10 }
})