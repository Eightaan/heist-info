local EHI = EHI
local Icons = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local escape = "Heli"
local triggers = {
    --heli_escape_OFF
    [200534] = { special_function = SF.CustomCode, f = function()
        escape = "Van"
    end },
    [200148] = { special_function = SF.CustomCode, f = function()
        if not EHI:IsPlayingFromStart() then -- Not playing from the start, try to determine the escape vehicle
            if managers.ehi:IsMissionElementDisabled(200171) then -- Heli show sequence is disabled, Van escape it is
                escape = "Van"
            end
        end
        if escape == "Heli" then
            managers.ehi:AddTracker({
                id = "Escape",
                time = 50 + 25 + 6,
                icons = Icons.HeliEscape
            })
        else -- Van
            managers.ehi:AddTracker({
                id = "Escape",
                time = 80,
                icons = Icons.CarEscape
            })
        end
    end}
}

local achievements =
{
    os_powerup =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200134] = { status = "defend", class = TT.AchievementStatus },
            [100604] = { special_function = SF.SetAchievementComplete },
            [100621] = { special_function = SF.SetAchievementFailed }
        }
    },
    os_terroristswin =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200106] = { status = "defend", class = TT.AchievementStatus },
            [100606] = { special_function = SF.SetAchievementComplete },
            [100630] = { special_function = SF.SetAchievementFailed }
        }
    },
    os_clearedout =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [1] = { max = 18, class = TT.AchievementProgress },
            [2] = { special_function = SF.CustomCode, f = function()
                EHI:AddAchievementToCounter({
                    achievement = "os_clearedout",
                    counter =
                    {
                        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                        loot_type = "money"
                    }
                })
            end },
            [200106] = { special_function = SF.Trigger, data = { 1, 2 } }
        }
    }
}
for i = 200502, 200519, 1 do
    achievements.os_clearedout.elements[i] = { special_function = SF.DecreaseProgressMax }
end
EHI:PreparseBeardlibAchievements(achievements, "os_achievements")

local other =
{
    [200018] = EHI:AddAssaultDelay({ time = 5 + 30 })
}

local tbl =
{
    [100241] = { remove_vanilla_waypoint = true, waypoint_id = 200163 },
    [102736] = { remove_vanilla_waypoint = true, waypoint_id = 200175 },
    [103138] = { remove_vanilla_waypoint = true, waypoint_id = 200306 },
    [102770] = { remove_vanilla_waypoint = true, waypoint_id = 200307 },
    [102774] = { remove_vanilla_waypoint = true, waypoint_id = 200308 },
    [102775] = { remove_vanilla_waypoint = true, waypoint_id = 200309 },
    [102776] = { remove_vanilla_waypoint = true, waypoint_id = 200310 }
}
EHI:UpdateUnits(tbl)

local MissionDoorPositions =
{
    [1] = Vector3(945.08, 3403.11, 92.4429)
}
local MissionDoorIndex =
{
    [1] = { w_id = 200160 }
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})