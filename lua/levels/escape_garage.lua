local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local function bilbo_baggin()
    local bags_to_secure = managers.ehi:CountLootbagsOnTheGround()
    if bags_to_secure >= 8 then
        managers.ehi:AddTracker({
            id = "bilbo_baggin",
            icons = EHI:GetAchievementIcon("bilbo_baggin"),
            max = 8,
            remove_after_reaching_target = false,
            class = TT.AchievementProgress
        })
        EHI:AddAchievementToCounter({
            achievement = "bilbo_baggin"
        })
    end
end
local achievements =
{
    bilbo_baggin =
    {
        elements =
        {
            [102414] = { special_function = SF.CustomCode, f = bilbo_baggin }
        }
    }
}

local other =
{
    [102414] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround)
}

EHI:ParseTriggers({
    achievement = achievements,
    other = other
})
--[[EHI:AddLoadSyncFunction(function(self)
    bilbo_baggin()
    self:SetTrackerProgress("bilbo_baggin", managers.loot:GetSecuredBagsAmount())
end)]]
EHI:AddXPBreakdown({
    objective =
    {
        escape = 4000
    },
    no_total_xp = true
})