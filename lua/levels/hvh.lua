local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local other = {
    [100181] = { special_function = SF.CustomCode, f = function()
        EHI:CallCallback("hvhCleanUp")
    end}
}

local achievements =
{
    cac_21 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard),
        elements =
        {
            [100212] = { max = 6, class = TT.AchievementProgress, special_function = SF.ShowAchievementFromStart },
            [100224] = { special_function = SF.IncreaseProgress },
            [100181] = { special_function = SF.CustomCodeDelayed, t = 2, f = function()
                managers.ehi:SetAchievementFailed("cac_21")
            end}
        }
    }
}
EHI:ParseTriggers({
    achievement = achievements,
    other = other
})

local tbl =
{
    --units/pd2_dlc_chill/props/chl_prop_timer_large/chl_prop_timer_large
    [100007] = { ignore = true },
    [100827] = { ignore = true },
    [100888] = { ignore = true },
    [100889] = { ignore = true },
    [100891] = { ignore = true },
    [100892] = { ignore = true },
    [100176] = { ignore = true },
    [100177] = { ignore = true },

    --units/pd2_dlc_chill/props/chl_prop_timer_small/chl_prop_timer_small
    [100029] = { ignore = true },
    [100878] = { icons = { Icon.Wait }, custom_callback = { id = "hvhCleanUp", f = "remove" } }
}
--levels/instances/unique/hvh/hvh_event
for i = 9794, 11794, 500 do
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    for u = 100027, 100029, 1 do
        if u == 100029 then
            tbl[EHI:GetInstanceUnitID(u, i)] = { icons = { Icon.Vault }, completion = true }
        else
            tbl[EHI:GetInstanceUnitID(u, i)] = { ignore = true }
        end
    end
end
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 2000
    },
    loot_all = 1000,
    no_gage = true
})