local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {}
local sync_triggers =
{
    [100558] = { id = "BileReturn", icons = Icon.HeliEscape }
}
if EHI:IsClient() then
    triggers[100558] = { time = 5, random_time = 5, id = "BileReturn", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    EHI:SetSyncTriggers(sync_triggers)
else
    EHI:AddHostTriggers(sync_triggers, nil, nil, "base")
end

local achievements =
{
    born_5 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100595] = { time = 120, class = TT.Achievement },
            [101170] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("born_5", 120)
        end
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowLootCounter({
    max = 9,
    offset = true
})
EHI:AddXPBreakdown({
    objective =
    {
        biker2_boss_dead = 6000,
        escape = 4000
    },
    loot_all = 500
})