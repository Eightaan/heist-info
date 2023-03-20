local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100128] = { time = 38, id = "WinchDropTrainA", icons = { Icon.Winch, Icon.Goto } },
    [100164] = { time = 38, id = "WinchDropTrainB", icons = { Icon.Winch, Icon.Goto } },

    [100654] = { time = 120, id = "Winch", icons = { Icon.Winch }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [100655] = { id = "Winch", special_function = SF.PauseTracker },
    [100656] = { id = "Winch", special_function = SF.UnpauseTracker },
    [EHI:GetInstanceElementID(100077, 2900)] = { time = 90, id = "Cutter", icons = { Icon.Glasscutter }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100078, 2900)] = { id = "Cutter", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100103, 2900)] = { time = 5, id = "C4OfficeFloor", icons = { Icon.C4 } },

    [100124] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } },

    [100275] = { time = 20, id = "Van", icons = Icon.CarEscape },

    [100142] = { time = 5, id = "C4Vault", icons = { Icon.C4 } }
}

for _, index in ipairs({ 1900, 2400 }) do
    for _, unit_id in ipairs({ 100010, 100039, 100004, 100034 }) do
        local fixed_unit_id = EHI:GetInstanceUnitID(unit_id, index)
        managers.mission:add_runned_unit_sequence_trigger(fixed_unit_id, "interact", function(...)
            managers.ehi:AddTracker({
                id = tostring(fixed_unit_id),
                time = 50 + math.rand(10),
                icons = { Icon.Fire },
                class = TT.Inaccurate
            })
        end)
    end
end

local achievements =
{
    brb_8 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard),
        elements =
        {
            [101136] = { special_function = SF.CustomCode, f = function()
                EHI:ShowAchievementLootCounter({
                    achievement = "brb_8",
                    max = 12,
                    remove_after_reaching_target = false,
                    counter =
                    {
                        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                        loot_type = "gold"
                    }
                })
            end }
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})

local tbl =
{
    --levels/instances/unique/brb/brb_vault
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    [EHI:GetInstanceUnitID(100058, 1900)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100003, 1900) },
    [EHI:GetInstanceUnitID(100058, 2400)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100003, 2400) }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        vault_found = 4000,
        vault_open = 8000,
        brb_medallion_taken = 4000
    },
    loot_all = 400
})