local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local c4_drop = { time = 120 + 25 + 0.25 + 2, id = "C4Drop", icons = Icon.HeliDropC4 }
local HeliTimer = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    -- Why in the flying fuck, OVK, you decided to execute the timer AFTER the dialogue has finished ?
    -- You realize how much pain this is to account for ?
    -- I'm used to bullshit, but this is next level; 10/10 for effort
    -- I hope you are super happy with what you have pulled off
    -- And I'm fucking happy I have to check EVERY FUCKING DIALOG the pilot says TO STAY ACCURATE WITH THE TIMER
    --
    -- Reported in:
    -- https://steamcommunity.com/app/218620/discussions/14/3182362958583578588/
    [1] = {
        [1] = 5 + 8,
        [2] = 8
    },
    [101644] = { time = 60, id = "BainWait", icons = { Icon.Wait } },
    [EHI:GetInstanceElementID(100075, 21250)] = { time = 60 + 60 + 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = HeliTimer, dialog = 1 },
    [EHI:GetInstanceElementID(100076, 21250)] = { time = 60 + 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = HeliTimer, dialog = 2 },
    [EHI:GetInstanceElementID(100078, 21250)] = { time = 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.SetTimeOrCreateTracker },
    [100795] = { time = 5, id = "C4", icons = { Icon.C4 }, waypoint = { position_by_element = 100804 } },

    [101240] = c4_drop,
    [101241] = c4_drop,
    [101242] = c4_drop,
    [101243] = c4_drop,
    [101249] = c4_drop,
}
for i = 26550, 26950, 100 do
    local waypoint_id = EHI:GetInstanceElementID(100021, i)
    triggers[EHI:GetInstanceElementID(100003, i)] = { special_function = SF.ShowWaypoint, data = { icon = Icon.C4, position_by_element = waypoint_id } }
end

if EHI:IsClient() then
    triggers[EHI:GetInstanceElementID(100051, 21250)] = { time = 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
end

local other =
{
    -- Shorter by 20s for some reason
    --[100217] = EHI:AddAssaultDelay({ time = 30 + 30, trigger_times = 1 })
}

EHI:ParseTriggers({ mission = triggers, other = other })
EHI:RegisterCustomSpecialFunction(HeliTimer, function(trigger, element, enabled)
    if not managers.user:get_setting("mute_heist_vo") then
        local delay_fix = triggers[1][trigger.dialog] or 0
        trigger.time = trigger.time + delay_fix
    end
    if managers.ehi:TrackerExists(trigger.id) then
        managers.ehi:SetTrackerTimeNoAnim(trigger.id, trigger.time)
    else
        EHI:CheckCondition(trigger)
    end
end)

local tbl = {}
for i = 9175, 11175, 500 do
    --levels/instances/unique/holly_2/safe_van (1-5)
    --units/pd2_dlc_jolly/equipment/gen_interactable_saw/gen_interactable_saw
    tbl[EHI:GetInstanceUnitID(100019, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100070, i) }
end
for i = 12100, 16600, 500 do
    --levels/instances/unique/holly_2/safe_van (6-15)
    --units/pd2_dlc_jolly/equipment/gen_interactable_saw/gen_interactable_saw
    tbl[EHI:GetInstanceUnitID(100019, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100070, i) }
end
for i = 19150, 20650, 500 do
    --levels/instances/unique/holly_2/safe_van (16-19)
    --units/pd2_dlc_jolly/equipment/gen_interactable_saw/gen_interactable_saw
    tbl[EHI:GetInstanceUnitID(100019, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100070, i) }
end
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        van_open = 16000,
        c4_set_up = 6000, -- Wall blown up
        escape = 6000
    },
    loot_all = 500
})