local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [102685] = { id = "Refueling", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.SetTimeIfLoudOrStealth, data = { yes = 121, no = 91 }, trigger_times = 1 },
    [102678] = { id = "Refueling", special_function = SF.UnpauseTracker },
    [102684] = { id = "Refueling", special_function = SF.PauseTracker },
    [101983] = { time = 15, id = "C4Trap", icons = { Icon.C4 }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled },
    [101722] = { id = "C4Trap", special_function = SF.RemoveTracker },
}
local achievements =
{
    mex_9 =
    {
        elements =
        {
            [100107] = { max = 4, class = TT.AchievementProgress }
        }
    }
}
for i = 101502, 101509, 1 do
    achievements.mex_9.elements[i] = { special_function = SF.IncreaseProgress }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})

local tbl =
{
    --levels/instances/unique/mex/mex_vault
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100003, 26850)] = { icons = { Icon.Vault }, remove_on_pause = true }
}
for i = 7950, 8550, 300 do
    --levels/instances/unique/mex/mex_explosives
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    tbl[EHI:GetInstanceUnitID(100032, i)] = { icons = { Icon.C4 } }
end
EHI:UpdateUnits(tbl)