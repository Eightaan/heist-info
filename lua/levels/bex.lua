local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers =
{
    [102290] = { id = "VaultGas", icons = { Icon.Teargas }, hook_element = 102157 }
}
local hack_start = EHI:GetInstanceElementID(100015, 20450)
local triggers = {
    [EHI:GetInstanceElementID(100108, 35450)] = { time = 4.8, id = "SuprisePull", icons = { Icon.Wait } },
    [103919] = { time = 25 + 1 + 13, random_time = 5, id = "Van", icons = Icon.CarEscape, trigger_times = 1 },
    [100840] = { time = 1 + 13, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTrackerAccurate },

    [101818] = { time = 50 + 9.3, random_time = 30, id = "HeliDropLance", icons = Icon.HeliDropDrill, class = TT.Inaccurate },
    [hack_start] = { id = "ServerHack", icons = { Icon.PCHack }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = EHI:GetInstanceElementID(100014, 20450) },
    [EHI:GetInstanceElementID(100016, 20450)] = { id = "ServerHack", special_function = SF.PauseTracker },

    [102302] = { time = 28.05 + 418/30, id = "Suprise", icons = { "pd2_question" } },

    [101820] = { time = 9.3, id = "HeliDropLance", icons = Icon.HeliDropDrill, special_function = SF.SetTrackerAccurate }
}
-- levels/instances/unique/bex/bex_computer
for i = 7250, 9050, 150 do
    local id = "PCHack" .. i
    triggers[EHI:GetInstanceElementID(100006, i)] = { time = 30, id = id, icons = { Icon.PCHack }, waypoint = { position_by_unit = EHI:GetInstanceElementID(100000, i) } }
    triggers[EHI:GetInstanceElementID(100138, i)] = { id = id, special_function = SF.RemoveTracker } -- Alarm
end
if EHI:IsClient() then
    triggers[hack_start].time = 90
    triggers[hack_start].random_time = 10
    triggers[hack_start].special_function = SF.UnpauseTrackerIfExists
    triggers[hack_start].delay_only = true
    triggers[hack_start].class = TT.InaccuratePausable
    triggers[hack_start].synced = { class = TT.Pausable }
    EHI:AddSyncTrigger(hack_start, triggers[hack_start])
    triggers[EHI:GetInstanceElementID(100011, 20450)] = { id = "ServerHack", special_function = SF.RemoveTracker }
    triggers[102157] = { time = 60, random_time = 15, id = "VaultGas", icons = { Icon.Teargas }, class = TT.Inaccurate, special_function = SF.AddTrackerIfDoesNotExist }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local achievements =
{
    bex_10 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [103701] = { status = "defend", special_function = SF.SetAchievementStatus },
            [103702] = { special_function = SF.SetAchievementFailed },
            [103704] = { special_function = SF.SetAchievementFailed },
            [102602] = { special_function = SF.SetAchievementComplete },
            [100107] = { status = "loud", class = TT.AchievementStatus },
        }
    }
}

local tbl =
{
    [100000] = { remove_vanilla_waypoint = true, waypoint_id = 100005 }
}
EHI:UpdateInstanceUnits(tbl, 22450)

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowLootCounter({ max = 11 })