local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local DestructionTrigger = { id = "Destruction", special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, ...)
    self._trackers:IncreaseTrackerProgress(trigger.id, element._values.amount)
end) }
---@type ParseTriggerTable
local triggers =
{
    --editor_name="CounterDamages" id="100082"
    [100397] = { max = 1000000, short_format = true, id = "Destruction", class = TT.NeededValue, icons = { Icon.Destruction }, flash_times = 1 },
    [100066] = DestructionTrigger, -- +5000
    [100077] = DestructionTrigger, -- +300000
    [100015] = DestructionTrigger, -- +200000
    [100079] = DestructionTrigger, -- +10000
    [100113] = DestructionTrigger, -- +500
    [100127] = DestructionTrigger, -- +500
    [100135] = DestructionTrigger, -- +1000
    [100207] = DestructionTrigger, -- +1000
    [100226] = DestructionTrigger, -- +10000

    [100460] = { time = 24, id = "Reinforcements1", icons = { Icon.Kill } },
    [100501] = { time = 20 + 24, id = "Reinforcements2", icons = { Icon.Kill } },

    [100518] = { time = 70 + 26, id = "Escape", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Heli, position_by_element = 100515 } }
}
if EHI:IsClient() then
    triggers[100513] = { time = 26, id = "Escape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { icon = Icon.Heli, position_by_element = 100515 } }
end
if EHI:MissionTrackersAndWaypointEnabled() then
    triggers[100460].waypoint = { position_by_element = 100507 }
    triggers[100501].waypoint = { position_by_element = 100508 }
    local DisableWaypoints =
    {
        [100507] = true,
        [100508] = true
    }
    EHI:DisableWaypoints(DisableWaypoints)
end

EHI:ParseTriggers({ mission = triggers })