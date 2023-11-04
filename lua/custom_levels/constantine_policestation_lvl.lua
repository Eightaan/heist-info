local EHI = EHI

local other =
{
    [100193] = EHI:AddAssaultDelay({ time = 30 + 30 })
}

EHI:ParseTriggers({
    other = other
})

EHI:ShowLootCounter({
    max = 10,
    offset = managers.job:current_job_id() ~= "constantine_policestation_nar"
})

local tbl =
{
    --levels/instances/unique/sand/sand_computer_hackable
    --units/pd2_dlc_sand/equipment/sand_interactable_hack_computer/sand_interactable_hack_computer
    [EHI:GetInstanceUnitID(100140, 2750)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100034, 2750) },

    [EHI:GetInstanceUnitID(100037, 5750)] = { f = function(unit_id, unit_data, unit)
        EHI:HookWithID(unit:timer_gui(), "set_jammed", "EHI_100037_5750_unjammed", function(self, jammed, ...)
            if jammed == false then
                self:_HideWaypoint(EHI:GetInstanceElementID(100017, 5750)) -- Interact (Computer Icon)
            end
        end)
    end},

    [EHI:GetInstanceUnitID(100037, 6000)] = { f = function(unit_id, unit_data, unit)
        EHI:HookWithID(unit:timer_gui(), "set_jammed", "EHI_100037_6000_unjammed", function(self, jammed, ...)
            if jammed == false then
                self:_HideWaypoint(EHI:GetInstanceElementID(100017, 6000)) -- Interact (Computer Icon)
            end
        end)
    end}
}
EHI:UpdateUnits(tbl)

local DisableWaypoints =
{
    --levels/instances/unique/sand/sand_server_hack
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceElementID(100018, 5750)] = true, -- Defend
    [EHI:GetInstanceElementID(100018, 6000)] = true -- Defend
}
EHI:DisableWaypoints(DisableWaypoints)