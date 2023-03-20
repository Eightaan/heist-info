local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local MethlabStart = { Icon.Methlab, Icon.Wait }
local MethlabRestart = { Icon.Methlab, Icon.Loop }
local MethlabPickup = { Icon.Methlab, Icon.Interact }
local element_sync_triggers =
{
    [103575] = { id = "CookingStartDelay", icons = MethlabStart, hook_element = 103573 },
    [103576] = { id = "CookingStartDelay", icons = MethlabStart, hook_element = 103574 },
    [EHI:GetInstanceElementID(100078, 55850)] = { id = "NextIngredient", icons = MethlabRestart, hook_element = EHI:GetInstanceElementID(100173, 55850) },
    [EHI:GetInstanceElementID(100078, 56850)] = { id = "NextIngredient", icons = MethlabRestart, hook_element = EHI:GetInstanceElementID(100173, 56850) },
    [EHI:GetInstanceElementID(100157, 55850)] = { id = "MethReady", icons = MethlabPickup, hook_element = EHI:GetInstanceElementID(100174, 55850) },
    [EHI:GetInstanceElementID(100157, 56850)] = { id = "MethReady", icons = MethlabPickup, hook_element = EHI:GetInstanceElementID(100174, 56850) }
}
local triggers =
{
    -- Also handles next ingredient when meth is picked up
    [EHI:GetInstanceElementID(100056, 55850)] = { time = 15, id = "NextIngredient", icons = MethlabRestart, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100056, 56850)] = { time = 15, id = "NextIngredient", icons = MethlabRestart, special_function = SF.AddTrackerIfDoesNotExist }
}
if EHI:IsClient() then
    local cooking_start = { time = 30, delay = 10, id = "CookingStartDelay", icons = MethlabStart, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
    local meth_ready = { time = 10, delay = 5, id = "MethReady", icons = MethlabPickup, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
    local next_ingredient = { time = 40, delay = 5, id = "NextIngredient", icons = MethlabRestart, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
    triggers[103573] = cooking_start
    triggers[103574] = cooking_start
    triggers[EHI:GetInstanceElementID(100173, 55850)] = next_ingredient
    triggers[EHI:GetInstanceElementID(100173, 56850)] = next_ingredient
    triggers[EHI:GetInstanceElementID(100174, 55850)] = meth_ready
    triggers[EHI:GetInstanceElementID(100174, 56850)] = meth_ready
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers({ mission = triggers })
if EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    EHI:ShowAchievementLootCounter({
        achievement = "mex2_9",
        max = 25,
        remove_after_reaching_target = false
    })
end
EHI:ShowLootCounter({ max = 50 })