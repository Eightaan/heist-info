local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local interact = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop } }
local element_sync_triggers = {}
for i = 100169, 100172, 1 do
    local element_id = EHI:GetInstanceElementID(i, 7750)
    element_sync_triggers[element_id] = deep_clone(interact)
    element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100168, 7750)
end
local escape_delay = 24 + 1
local triggers = {
    [100246] = { time = 60 + escape_delay, id = "HeliEscapeSlow", icons = Icon.HeliEscapeNoLoot, special_function = SF.ExecuteIfElementIsEnabled },
    [100247] = { time = escape_delay, id = "HeliEscapeFast", icons = Icon.HeliEscapeNoLoot, special_function = SF.ExecuteIfElementIsEnabled }
}
triggers[EHI:GetInstanceElementID(100118, 7750)] = { time = 1, id = "MethlabRestart", icons = { Icon.Methlab, Icon.Wait } }
triggers[EHI:GetInstanceElementID(100152, 7750)] = { time = 5, id = "MethlabPickUp", icons = { Icon.Methlab, Icon.Interact } }
if EHI:IsClient() then
    local random_time = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 } }
    triggers[EHI:GetInstanceElementID(100149, 7750)] = random_time
    triggers[EHI:GetInstanceElementID(100150, 7750)] = random_time
    triggers[EHI:GetInstanceElementID(100184, 7750)] = { id = "MethlabInteract", special_function = SF.RemoveTracker }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers({ mission = triggers })