local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local escape_fly_in = 30 + 35 + 24
local fire_wait = { time = 20, id = "FireWait", icons = { Icon.Fire, Icon.Wait } }
local triggers = {
    [100201] = { time = 99, id = "AmbushWait", icons = { Icon.Wait } },
    [100218] = fire_wait,
    [100364] = fire_wait,
    [100417] = { time = 78 + 25 + escape_fly_in, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, class = TT.Pausable },
    [100422] = { time = escape_fly_in, id = "EscapeHeli", special_function = SF.PauseTrackerWithTime },
    [100423] = { time = escape_fly_in, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable }
}

---@type ParseAchievementTable
local achievements =
{
    hunter_party =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100045] = { status = "ok", class = TT.Achievement.Status, special_function = SF.ShowAchievementFromStart },
            [100679] = { special_function = SF.SetAchievementFailed }
        }
    }
}
EHI:PreparseBeardlibAchievements(achievements, "hunter_all")

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})