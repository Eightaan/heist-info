EHIcorp12Tracker = class(EHIAchievementTracker)
function EHIcorp12Tracker:SetMPState()
    self._time = self._time - 180
    self._check_anim_progress = self._time <= 10
end

local EHI = EHI
EHI.AchievementTrackers.EHIcorp12Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers =
{
    [102406] = { additional_time = 22 + 6, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.GetElementTimerAccurate, element = 102401 },

    [EHI:GetInstanceElementID(100018, 12190)] = { time = 10, id = "Thermite", icons = { Icon.Fire } }
}
if EHI:IsClient() then
    local escape_time = 15
    if OVKorAbove then
        escape_time = 30
    end
    triggers[102406].time = escape_time
    triggers[102406].random_time = 15
    triggers[102406].delay_only = true
    EHI:AddSyncTrigger(102406, triggers[102406])
end

local corp_11_Start = EHI:GetFreeCustomSpecialFunctionID()
local corp_11_SetFailed = EHI:GetFreeCustomSpecialFunctionID()
local corp_11_StartVariable = true
local achievements =
{
    corp_10 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [103043] = { max = 50, class = TT.AchievementProgress },
            [103482] = { special_function = SF.IncreaseProgress },
            [103487] = { special_function = SF.SetAchievementFailed }
        }
    },
    corp_11 =
    {
        elements =
        {
            [102728] = { icons = EHI:GetAchievementIcon("corp_11"), special_function = corp_11_Start },
            [102683] = { special_function = corp_11_SetFailed },
            [102741] = { special_function = SF.SetAchievementComplete }
        }
    },
    corp_12 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            -- SP (MP has 240s)
            [100107] = { time = 420, class = "EHIcorp12Tracker" },
            [102739] = { special_function = SF.CustomCode, f = function()
                managers.ehi:CallFunction("corp_12", "SetMPState")
            end },
            [102014] = { special_function = SF.SetAchievementFailed }, -- Alarm
            [102736] = { special_function = SF.SetAchievementFailed }, -- Civilian killed
            [102740] = { special_function = SF.SetAchievementComplete }
        },
        cleanup_callback = function()
            EHIcorp12Tracker = nil
        end
    }
}
for i = 102699, 102712, 1 do
    achievements.corp_11.elements[i] = { special_function = corp_11_SetFailed }
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 45 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:RegisterCustomSpecialFunction(corp_11_Start, function(trigger, ...)
    if corp_11_StartVariable then
        managers.ehi:AddTracker({
            id = "corp_11",
            time = 60,
            icons = trigger.icons,
            class = TT.Achievement
        })
    end
end)
EHI:RegisterCustomSpecialFunction(corp_11_SetFailed, function(trigger, element, enabled)
    if enabled then
        managers.ehi:SetAchievementFailed("corp_11")
        corp_11_StartVariable = false
    end
end)

local tbl =
{
    [EHI:GetInstanceUnitID(100023, 12190)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100050, 12190) }
}
EHI:UpdateUnits(tbl)

local DisableWaypoints =
{
    [EHI:GetInstanceElementID(100031, 12610)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 12610)] = true, -- Fix
    [EHI:GetInstanceElementID(100031, 12710)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 12710)] = true, -- Fix
}
EHI:DisableWaypoints(DisableWaypoints)