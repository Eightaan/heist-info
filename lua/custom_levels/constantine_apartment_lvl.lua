local EHI = EHI

local other =
{
    [100122] = EHI:AddAssaultDelay({ time = 30 + 30, trigger_times = 1 })
}
EHI:ParseTriggers({
    other = other
})

local DisableWaypoints =
{
    -- PC Hack
    [EHI:GetInstanceElementID(100018, 6750)] = true, -- Defend

    -- Drill on black vault
    [EHI:GetInstanceElementID(100029, 750)] = true, -- Defend
    [EHI:GetInstanceElementID(100022, 750)] = true -- Fix
}

EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    [EHI:GetInstanceUnitID(100037, 6750)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100017, 6750) }
}
EHI:UpdateUnits(tbl)
EHI:ShowLootCounter({
    max = 5,
    offset = managers.job:current_job_id() ~= "constantine_apartment_nar"
})