local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local drill_spawn_delay = { time = 30, id = "DrillSpawnDelay", icons = { Icon.Drill, Icon.Goto } }
local CrashIcons = { Icon.PCHack, Icon.Fix, "pd2_question" }
if EHI:GetOption("show_one_icon") then
    CrashIcons = { Icon.Fix }
end
local triggers = {
    [101284] = { chance = 50, id = "CrashChance", icons = { Icon.PCHack, Icon.Fix }, class = TT.Chance },
    [103568] = { time = 60, id = "Hack", icons = { Icon.PCHack } },
    [103585] = { id = "Hack", special_function = SF.RemoveTracker },
    [103579] = { amount = 25, id = "CrashChance", special_function = SF.DecreaseChance },
    [100741] = { id = "CrashChance", special_function = SF.RemoveTracker },
    [103572] = { time = 50, id = "CrashChanceTime", icons = CrashIcons },
    [103573] = { time = 40, id = "CrashChanceTime", icons = CrashIcons },
    [103574] = { time = 30, id = "CrashChanceTime", icons = CrashIcons },
    [103478] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
    [103169] = drill_spawn_delay,
    [103179] = drill_spawn_delay,
    [103190] = drill_spawn_delay,
    [103195] = drill_spawn_delay,

    [103535] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } }
}

EHI:ParseTriggers({ mission = triggers })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 20000
    }
})