local EHI = EHI
local TT = EHI.Trackers
local ObjectiveWait = { time = 90, id = "ObjectiveWait", icons = { EHI.Icons.Wait } }
local triggers = {
    [100271] = ObjectiveWait,
    [100269] = ObjectiveWait
}

---@type ParseAchievementTable
local achievements =
{
    RC_Achieve_speedrun =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            --[100824] = { time = 360, class = TT.Achievement.Base }
            --[100756] = { special_function = SF.SetAchievementComplete },
            -- Apparently there is a bug in the mission script which causes to unlock this achievement even when the time runs out
            [100824] = { time = 360, class = TT.Achievement.Unlock }
        },
        load_sync = function(self)
            local t = 360 - self._trackers._t
            if t <= 0 then
                return
            end
            self._trackers:AddTracker({
                id = "RC_Achieve_speedrun",
                time = t,
                icons = { "ehi_RC_Achieve_speedrun" },
                class = TT.Achievement.Unlock
            })
        end
    }
}
EHI:PreparseBeardlibAchievements(achievements, "Rogue_Company")

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})