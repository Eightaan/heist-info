local EHI = EHI
local Icon = EHI.Icons
local car = { { icon = Icon.Car, color = Color("1E90FF") } }
local move = { time = 10, id = "MoveVehicle", icons = { Icon.Wait } }
local RoadBlockVehicleIndex1 = 550
local RoadBlockVehicleIndex2 = 950
if managers.job:is_level_christmas("hox_1") then
    RoadBlockVehicleIndex1 = 7150
    RoadBlockVehicleIndex2 = 7350
end
local triggers = {
    [100562] = { time = 1 + 5, id = "C4", icons = { Icon.C4 } },

    [101595] = { time = 6, id = "Wait", icons = { Icon.Wait } },

    [102191] = move, -- First Police Car
    [EHI:GetInstanceElementID(100000, RoadBlockVehicleIndex1)] = move, -- Police Car
    [EHI:GetInstanceElementID(100000, RoadBlockVehicleIndex2)] = move, -- Police Car
    [EHI:GetInstanceElementID(100056, RoadBlockVehicleIndex1)] = move, -- SWAT Van
    [EHI:GetInstanceElementID(100056, RoadBlockVehicleIndex2)] = move, -- SWAT Van

    -- Time for animated car (nothing in the mission script, time was debugged with custom code => using rounded number, which should be accurate enough)
    [102626] = { time = 36.2, id = "CarMoveForward", icons = car },
    [102627] = { time = 34.5, id = "CarMoveLeft", icons = car },
    [102628] = { time = 34.5, id = "CarMoveRight", icons = car },
    -- In Garage
    [101383] = { time = 44.3, id = "CarGoingIntoGarage", icons = car },
    [101397] = { time = 22.6, id = "CarMoveRightFinal", icons = car }
}

EHI:ParseTriggers({ mission = triggers })

local tbl =
{
    --levels/instances/unique/hox_breakout_road001
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small
    [EHI:GetInstanceUnitID(100058, RoadBlockVehicleIndex1)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100090, RoadBlockVehicleIndex1) },
    [EHI:GetInstanceUnitID(100058, RoadBlockVehicleIndex2)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100090, RoadBlockVehicleIndex2) },

    --units/payday2/vehicles/anim_vehicle_pickup_sportcab_armored/anim_vehicle_pickup_sportcab_armored/the_car
    [102482] = { f = function(id, unit_data, unit)
        if not EHI:GetOption("show_waypoints") then
            return
        end
        local t = { unit = unit }
        EHI:AddWaypointToTrigger(102626, t)
        EHI:AddWaypointToTrigger(102627, t)
        EHI:AddWaypointToTrigger(102628, t)
        EHI:AddWaypointToTrigger(101383, t)
        EHI:AddWaypointToTrigger(101397, t)
        unit:unit_data():add_destroy_listener("EHIDestroy", function(...)
            managers.ehi_waypoint:RemoveWaypoint("CarMoveForward")
            managers.ehi_waypoint:RemoveWaypoint("CarMoveLeft")
            managers.ehi_waypoint:RemoveWaypoint("CarMoveRight")
            managers.ehi_waypoint:RemoveWaypoint("CarGoingIntoGarage")
            managers.ehi_waypoint:RemoveWaypoint("CarMoveRightFinal")
        end)
    end}
}
for i = 1350, 4950, 400 do
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    tbl[EHI:GetInstanceElementID(100025, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100072, i), restore_waypoint_on_done = true }
end
EHI:UpdateUnits(tbl)
EHI._cache.diff = 1
EHI:AddXPBreakdown({
    objective =
    {
        hox1_first_corner = 3000,
        hox1_second_corner = 4000,
        hox1_blockade_cleared = 200,
        hox1_parking_gate_open = 2000,
        hox1_parking_car_reached_garages = 4000,
        pc_hack = 3000,
        escape = 2000
    },
    total_xp_override =
    {
        objective =
        {
            hox1_blockade_cleared = { times = 2 }
        }
    }
})