local EHI = EHI
local Icons = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local escape = "Heli"
---@type ParseTriggerTable
local triggers = {
    --heli_escape_OFF
    [200534] = { special_function = SF.CustomCode, f = function()
        escape = "Van"
    end },
    [200148] = { id = "Escape", special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, ...)
        if not EHI:IsPlayingFromStart() then -- Not playing from the start, try to determine the escape vehicle
            if self:IsMissionElementDisabled(200171) then -- Heli show sequence is disabled, Van escape it is
                escape = "Van"
            end
        end
        if escape == "Heli" then
            local t = 50 + 25 + 6
            self._trackers:AddTracker({
                id = trigger.id,
                time = t,
                icons = Icons.HeliEscape
            })
            if trigger.waypoint then
                trigger.waypoint.time = t
                trigger.waypoint.icon = Icons.Heli
                trigger.waypoint.position = EHI:GetElementPosition(200179) or Vector3()
            end
        else -- Van
            self._trackers:AddTracker({
                id = trigger.id,
                time = 80,
                icons = Icons.CarEscape
            })
            if trigger.waypoint then
                trigger.waypoint.time = 80
                trigger.waypoint.icon = Icons.Car
                trigger.waypoint.position = EHI:GetElementPosition(200178) or Vector3()
            end
        end
        if trigger.waypoint then
            self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
        end
    end), waypoint = {} }
}

---@type ParseAchievementTable
local achievements =
{
    os_powerup =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200134] = { status = "defend", class = TT.Achievement.Status },
            [100604] = { special_function = SF.SetAchievementComplete },
            [100621] = { special_function = SF.SetAchievementFailed }
        }
    },
    os_terroristswin =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200106] = { status = "defend", class = TT.Achievement.Status },
            [100606] = { special_function = SF.SetAchievementComplete },
            [100630] = { special_function = SF.SetAchievementFailed }
        }
    },
    os_clearedout =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200106] = { max = 18, class = TT.Achievement.Progress, special_function = SF.AddAchievementToCounter, data = {
                counter =
                {
                    check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                    loot_type = "money"
                }
            }}
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
if EHI:IsLootCounterVisible() then
    other[200106] = EHI:AddLootCounter2(function()
        local servers = EHI:IsMayhemOrAbove() and 2 or 1
        EHI:ShowLootCounterNoChecks({ max = servers + 18 })
    end)
    for i = 200502, 200519, 1 do
        other[i] = { id = "LootCounter", special_function = SF.DecreaseProgressMax }
    end
    other[100092] = { max = 5, id = "LootCounter", special_function = SF.IncreaseProgressMax2 }
end

local tbl =
{
    [100241] = { remove_vanilla_waypoint = 200163 },
    [102736] = { remove_vanilla_waypoint = 200175 },
    [103138] = { remove_vanilla_waypoint = 200306 },
    [102770] = { remove_vanilla_waypoint = 200307 },
    [102774] = { remove_vanilla_waypoint = 200308 },
    [102775] = { remove_vanilla_waypoint = 200309 },
    [102776] = { remove_vanilla_waypoint = 200310 }
}
EHI:UpdateUnits(tbl)

---@type MissionDoorTable
local MissionDoor =
{
    [Vector3(945.08, 3403.11, 92.4429)] = 200160
}
EHI:SetMissionDoorData(MissionDoor)

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 16000
    },
    loot =
    {
        master_server = 2500,
        money = 850
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    master_server = { min_max = EHI:IsMayhemOrAbove() and 2 or 1 },
                    money = { max = 15 } -- 3 always and 3 random
                }
            }
        }
    }
})