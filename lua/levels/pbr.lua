local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [EHI:GetInstanceElementID(100108, 3200)] = { time = 45, id = "LockOpen", icons = { Icon.Wait } },
    [EHI:GetInstanceElementID(100124, 3200)] = { id = "LockOpen", special_function = SF.RemoveTracker },

    [101774] = { time = 90, id = "EscapeHeli", icons = { Icon.Escape } }
}

local function berry_4_fail()
    managers.player:remove_listener("EHI_berry_4_fail")
    EHI:Unhook("berry_4_HuskPlayerMovement_sync_bleed_out")
    EHI:Unhook("berry_4_HuskPlayerMovement_sync_incapacitated")
    managers.ehi:SetAchievementFailed("berry_4")
end
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local achievements =
{
    berry_3 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102292] = { time = 600, class = TT.Achievement },
            [102290] = { special_function = SF.SetAchievementComplete }
        }
    },
    berry_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102292] = { special_function = SF.Trigger, data = { 1, 2 } },
            [1] = { status = "no_down", id = "berry_4", class = TT.AchievementStatus },
            [2] = { special_function = SF.CustomCode, f = function()
                -- Player (Local)
                managers.player:add_listener("EHI_berry_4_fail", { "bleed_out", "incapacitated" }, berry_4_fail)

                -- Clients
                EHI:HookWithID(HuskPlayerMovement, "_sync_movement_state_bleed_out", "EHI_berry_4_HuskPlayerMovement_sync_bleed_out", berry_4_fail)
                EHI:HookWithID(HuskPlayerMovement, "_sync_movement_state_incapacitated", "EHI_berry_4_HuskPlayerMovement_sync_incapacitated", berry_4_fail)
            end }
        }
    }
}

local other =
{
    [102292] = EHI:AddAssaultDelay({ time = 75 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowAchievementLootCounter({
    achievement = "berry_2",
    max = 10,
    show_loot_counter = true,
    triggers =
    {
        [EHI:GetInstanceElementID(100041, 20050)] = { special_function = SF.FinalizeAchievement }
    },
    add_to_counter = true
})

local tbl =
{
    [EHI:GetInstanceUnitID(100113, 0)] = { icons = { Icon.C4 } }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        btm_blasted_entrance = 2000,
        btm_used_keycard = 2500,
        btm_request_approved = 3000,
        btm_vault_open_loot = 1000,
        btm_destroyed_comm = 1500,
        btm_heli_refueled = 3000,
        escape = 4000
    },
    loot_all = 700,
    no_total_xp = true
})