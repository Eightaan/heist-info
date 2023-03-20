local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local SecurityTearGasRandomElement = EHI:GetInstanceElementID(100061, 6690)
local element_sync_triggers =
{
    [EHI:GetInstanceElementID(100062, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement }, -- 45s
    [EHI:GetInstanceElementID(100063, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement }, -- 55s
    [EHI:GetInstanceElementID(100064, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement } -- 65s
}
local request = { Icon.PCHack, Icon.Wait }
local hoxton_hack = { "hoxton_character" }
local CheckOkValueHostCheckOnly = EHI:GetFreeCustomSpecialFunctionID()
local PCHackWaypoint = { icon = Icon.Wait, position = Vector3(9, 4680, -2.2694) }
local triggers = {
    [102016] = { time = 7, id = "Endless", icons = Icon.EndlessAssault, class = TT.Warning },

    [104579] = { time = 15, id = "Request", icons = request, waypoint = deep_clone(PCHackWaypoint) },
    [104580] = { time = 25, id = "Request", icons = request, waypoint = deep_clone(PCHackWaypoint) },
    [104581] = { time = 20, id = "Request", icons = request, waypoint = deep_clone(PCHackWaypoint) },
    [104582] = { time = 30, id = "Request", icons = request, waypoint = deep_clone(PCHackWaypoint) }, -- Disabled in the mission script

    [104509] = { time = 30, id = "HackRestartWait", icons = { Icon.PCHack, Icon.Loop } },

    [104314] = { max = 4, id = "RequestCounter", icons = { Icon.PCHack }, class = TT.Progress, special_function = SF.AddTrackerIfDoesNotExist },

    [104599] = { id = "RequestCounter", special_function = SF.RemoveTracker },

    [104591] = { id = "RequestCounter", special_function = SF.IncreaseProgress },

    [104472] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress },
    [104478] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 1 } },
    [104480] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 2 } },
    [104481] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 3 } },
    [104482] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 4, dont_create = true } },

    [105113] = { chance = 25, id = "ForensicsMatchChance", icons = { "equipment_evidence" }, class = TT.Chance },
    [102257] = { amount = 25, id = "ForensicsMatchChance", special_function = SF.IncreaseChance },
    [105137] = { id = "ForensicsMatchChance", special_function = SF.RemoveTracker }
}
if EHI:IsClient() then
    triggers[EHI:GetInstanceElementID(100055, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 45, 55, 65 } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local achievements =
{
    slakt_3 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { class = TT.AchievementStatus },
            [100256] = { special_function = SF.SetAchievementFailed },
            [100258] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            if self:IsMissionElementEnabled(100270) then -- No keycard achievement
                self:AddAchievementStatusTracker("slakt_3")
            end
        end
    },
    cac_26 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { status = "objective", class = TT.AchievementStatus },
            [104485] = { status = "defend", special_function = SF.SetAchievementStatus },
            [104520] = { status = "objective", special_function = SF.SetAchievementStatus },
            [101884] = { status = "finish", special_function = SF.SetAchievementStatus },
            [100320] = { special_function = SF.SetAchievementComplete },
            [100322] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:RegisterCustomSpecialFunction(CheckOkValueHostCheckOnly, function(trigger, element, enabled)
    local continue = false
    if EHI:IsHost() then
        if element:_values_ok() then
            continue = true
        end
    else
        continue = true
    end
    if continue then
        if managers.ehi:TrackerExists(trigger.id) then
            managers.ehi:SetTrackerProgress(trigger.id, trigger.data.progress)
        elseif not trigger.data.dont_create then
            EHI:CheckCondition(trigger)
            managers.ehi:SetTrackerProgress(trigger.id, trigger.data.progress)
        end
    end
end)
EHI:AddLoadSyncFunction(function(self)
    local pc = managers.worlddefinition:get_unit(104418) -- 1
    local pc2 = managers.worlddefinition:get_unit(102413) -- 2
    local pc3 = managers.worlddefinition:get_unit(102414) -- 3
    local pc4 = managers.worlddefinition:get_unit(102415) -- 4
    if pc and pc2 and pc3 and pc4 then
        local timer = pc:timer_gui()
        local timer2 = pc2:timer_gui()
        local timer3 = pc3:timer_gui()
        local timer4 = pc4:timer_gui()
        if (timer._started or timer._done) and not (timer2._started or timer2._done) then
            EHI:Trigger(104478)
        elseif (timer2._started or timer2._done) and not (timer3._started or timer3._done) then
            EHI:Trigger(104480)
        elseif (timer3._started or timer3._done) and not (timer4._started or timer4._done) then
            EHI:Trigger(104481)
        end
        -- Pointless to query the last PC
    else -- Just in case, but the PCs should exist
        return
    end
end)

local tbl =
{
    --units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_director/stn_interactable_computer_director
    [102104] = { remove_vanilla_waypoint = true, waypoint_id = 104571, restore_waypoint_on_done = true },

    --levels/instances/unique/hox_fbi_forensic_device
    --units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_forensics/stn_interactable_computer_forensics
    [EHI:GetInstanceUnitID(100018, 2650)] = { icons = { "equipment_evidence" }, remove_vanilla_waypoint = true, waypoint_id = 101559, restore_waypoint_on_done = true },

    --levels/instances/unique/hox_fbi_security_office
    --units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_security/stn_interactable_computer_security
    [EHI:GetInstanceUnitID(100068, 6690)] = { icons = { "equipment_harddrive" }, remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100019, 6690) }
}
EHI:UpdateUnits(tbl)

local SecurityOffice = { w_id = EHI:GetInstanceElementID(100026, 6690) }
local MissionDoorPositions =
{
    -- Evidence
    [1] = Vector3(-1552.84, 816.472, -9.11819),

    -- Basement (Escape)
    [2] = Vector3(-744.305, 5042.19, -409.118),

    -- Archives
    [3] = Vector3(817.472, 2884.84, -809.118),

    -- Security Office
    [4] = Vector3(-1207.53, 4234.84, -409.118),
    [5] = Vector3(807.528, 4265.16, -9.11819)
}
local MissionDoorIndex =
{
    [1] = { w_id = 101562 },
    [2] = { w_id = 102017 },
    [3] = { w_id = 101345 },
    [4] = SecurityOffice,
    [5] = SecurityOffice
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)
EHI:AddXPBreakdown({
    objective =
    {
        hox2_reached_server_room = 4000,
        hox2_random_obj = 8000,
        escape = 6000,
        hox2_no_keycard_bonus_xp = 4000
    },
    no_total_xp = true
})