local EHI = EHI
local Icon = EHI.Icons
if EHI:GetOption("show_mission_trackers") then
    for _, pc_id in ipairs({ 104170, 104175, 104349, 104350, 104351, 104352, 104354, 101455 }) do
        managers.mission:add_runned_unit_sequence_trigger(pc_id, "interact", function(unit)
            managers.ehi:AddTracker({
                id = tostring(pc_id),
                time = 13,
                icons = { Icon.PCHack }
            })
        end)
    end
end

local MissionDoorPositions =
{
    -- Security doors
    [1] = Vector3(-2357.87, -3621.42, 489.107),
    [2] = Vector3(1221.42, -2957.87, 489.107),
    [3] = Vector3(1342.13, -2621.42, 89.1069), --101867
    [4] = Vector3(-2830.08, 341.886, 492.443) --102199
}
local MissionDoorIndex =
{
    [1] = { w_id = 101899 },
    [2] = { w_id = 101834 },
    [3] = { w_id = 101782 },
    [4] = { w_id = 101783 }
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)
local Weapons = { 101473, 102717, 102718, 102720 }
local OtherLoot = { 100739, 101779, 101804, 102711, 102712, 102713, 102714, 102715, 102716, 102721, 102723, 102725 }
local FilterIsOk = EHI:GetFreeCustomSpecialFunctionID()
local other =
{
    [107124] = EHI:AddLootCounter(function()
        local ef = tweak_data.ehi.functions
        local max = EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) and 2 or 1
        local goat = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) and 1 or 0
        local random_loot = ef.GetNumberOfVisibleWeapons(Weapons) + ef.GetNumberOfVisibleOtherLoot(OtherLoot)
        EHI:ShowLootCounterNoCheck({
            max = max,
            -- Random Loot + Goat
            additional_loot = random_loot + goat,
            triggers =
            {
                [100249] = { special_function = FilterIsOk }, -- N-OVK
                [100251] = { special_function = FilterIsOk } -- MH+
            },
            hook_triggers = true,
            offset = true,
            client_from_start = true
        })
    end),

    [104618] = EHI:AddAssaultDelay({ time = 30 + 1 + 5 + 30 + 30 })
}
EHI:RegisterCustomSpecialFunction(FilterIsOk, function(trigger, element, ...)
    if element:_check_difficulty() then
        managers.ehi:CallFunction("LootCounter", "SecuredMissionLoot") -- Server secured
    end
end)
EHI:ParseTriggers({
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 6000, stealth = true, timer = 180 },
            { amount = 12000, stealth = true },
            { amount = 10000, loud = true }
        }
    },
    loot_all = 1000
})