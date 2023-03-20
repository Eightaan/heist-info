local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local other = {
    [102064] = EHI:AddAssaultDelay({ time = 60 + 1 + 30, trigger_times = 1 })
}

local achievements =
{
    cac_24 =
    {
        elements =
        {
            [101282] = { time = 60, class = TT.Achievement },
            [101285] = { special_function = SF.SetAchievementComplete }
        }
    }
}

EHI:ParseTriggers({
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        big_oil_intel_pickup = { amount = 1500, times = 3 },
        big_oil_safe_open = 6000,
        escape = 6000
    },
    no_total_xp = true
})