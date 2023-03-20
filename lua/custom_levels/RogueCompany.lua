local EHI = EHI
local TT = EHI.Trackers
local ObjectiveWait = { time = 90, id = "ObjectiveWait", icons = { EHI.Icons.Wait } }
local triggers = {
    [100271] = ObjectiveWait,
    [100269] = ObjectiveWait
}

local achievements =
{
    RC_Achieve_speedrun =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            --[100824] = { time = 360, class = TT.Achievement }
            --[100756] = { special_function = SF.SetAchievementComplete },
            -- Apparently there is a bug in the mission script which causes to unlock this achievement even when the time runs out
            [100824] = { time = 360, class = TT.AchievementUnlock }
        },
        load_sync = function(self)
            local t = 360 - self._t
            if t <= 0 then
                return
            end
            self:AddTracker({
                id = "RC_Achieve_speedrun",
                time = t,
                icons = { "ehi_RC_Achieve_speedrun" },
                class = TT.AchievementUnlock
            })
        end
    }
}
EHI:PreparseBeardlibAchievements(achievements, "Rogue_Company")

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})