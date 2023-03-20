local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local triggers =
{
    [100391] = { id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.SetTimeByPreplanning, data = { id = 100486, yes = 60 + 25, no = 120 + 25 }, waypoint = { icon = Icon.Escape, position_by_element = 100420 } }
}
if EHI:IsClient() then
    triggers[100414] = { time = 25, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { icon = Icon.Escape, position_by_element = 100420 } }
end

local other =
{
    [100032] = EHI:AddAssaultDelay({ time = 60 })
}

EHI:ParseTriggers({
    mission = triggers,
    other = other
})

EHI:ShowLootCounter({
    max = 8,
    offset = managers.job:current_job_id() ~= "constantine_butcher_nar"
})

local tbl =
{
    --levels/instances/unique/sand/sand_computer_hackable
    --units/pd2_dlc_sand/equipment/sand_interactable_hack_computer/sand_interactable_hack_computer
    [EHI:GetInstanceUnitID(100140, 8000)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100034, 8000) },

    [EHI:GetInstanceUnitID(100037, 3750)] = { f = function(unit_id, unit_data, unit)
        EHI:HookWithID(unit:timer_gui(), "set_jammed", "EHI_100037_3750_unjammed", function(self, jammed, ...)
            if jammed == false then
                self:_HideWaypoint(EHI:GetInstanceElementID(100017, 3750)) -- Interact (Computer Icon)
            end
        end)
    end}
}
EHI:UpdateUnits(tbl)

local DisableWaypoints =
{
    --levels/instances/unique/sand/sand_server_hack
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceElementID(100018, 3750)] = true -- Defend
}
-- levels/instances/unique/rvd/rvd_hackbox
for i = 8250, 9000, 250 do
    DisableWaypoints[EHI:GetInstanceElementID(100034, i)] = true -- Defend Hackbox
    DisableWaypoints[EHI:GetInstanceElementID(100031, i)] = true -- Fix Hackbox
end
EHI:DisableWaypoints(DisableWaypoints)