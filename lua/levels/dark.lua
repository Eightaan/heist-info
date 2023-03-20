EHIdark5Tracker = class(EHIProgressTracker)
function EHIdark5Tracker:init(panel, params)
    self._bodies = {}
    EHIdark5Tracker.super.init(self, panel, params)
end

function EHIdark5Tracker:SetProgress(progress)
    self:SetTextColor(Color.white)
    EHIdark5Tracker.super.SetProgress(self, progress)
end

function EHIdark5Tracker:GetTotalProgress()
    local total = 0
    for _, value in pairs(self._bodies or {}) do
        if value == 1 then -- Mission Script expects exactly 1 body bag in dumpster
            total = total + 1
        end
    end
    return total
end

function EHIdark5Tracker:IncreaseProgress(element)
    self._bodies[element] = (self._bodies[element] or 0) + 1
    self:SetProgress(self:GetTotalProgress())
end

function EHIdark5Tracker:DecreaseProgress(element)
    self._bodies[element] = (self._bodies[element] or 1) - 1
    self:SetProgress(self:GetTotalProgress())
end

function EHIdark5Tracker:SetCompleted(force)
    EHIdark5Tracker.super.SetCompleted(self, force)
    self._disable_counting = false
    self._status = nil
end

local EHI = EHI
local Icon = EHI.Icons
EHI.AchievementTrackers.EHIdark5Tracker = true

for _, index in ipairs({ 8750, 17750, 33525, 36525 }) do
    local unit_index = EHI:GetInstanceUnitID(100334, index)
    managers.mission:add_runned_unit_sequence_trigger(unit_index, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(unit_index),
            time = 10,
            icons = { Icon.Fire }
        })
    end)
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [106026] = { time = 10, id = "Van", icons = Icon.CarEscape },

    [106036] = { time = 410/30, id = "Boat", icons = Icon.BoatEscape }
}

local achievements =
{
    dark_2 =
    {
        elements =
        {
            [100296] = { time = 420, class = TT.Achievement },
            [100290] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("dark_2", 420)
        end
    },
    dark_3 =
    {
        elements =
        {
            [100296] = { class = TT.AchievementStatus },
            [100470] = { special_function = SF.SetAchievementFailed }
        }
    },
    dark_5 =
    {
        elements =
        {
            [100296] = { max = 4, class = "EHIdark5Tracker", remove_after_reaching_target = false },
        }
    },
    voff_3 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100296] = { special_function = SF.Trigger, data = { 1, 2 } },
            [1] = { max = 16, class = TT.AchievementProgress, remove_after_reaching_target = false },
            [2] = { special_function = SF.CustomCode, f = function()
                EHI:AddAchievementToCounter({ achievement = "voff_3" })
            end },
            [100470] = { special_function = SF.SetAchievementFailed },
        }
    }
}
local AddBodyBag = EHI:GetFreeCustomSpecialFunctionID()
local RemoveBodyBag = EHI:GetFreeCustomSpecialFunctionID()
for i = 12850, 13600, 250 do
    local inc = EHI:GetInstanceElementID(100011, i)
    achievements.dark_5.elements[inc] = { special_function = AddBodyBag, element = i }
    achievements.dark_5.elements[inc + 1] = { special_function = RemoveBodyBag, element = i }
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowLootCounter({ max = 16 })
EHI:RegisterCustomSpecialFunction(AddBodyBag, function(trigger, ...)
    managers.ehi:CallFunction(trigger.id, "IncreaseProgress", trigger.element)
end)
EHI:RegisterCustomSpecialFunction(RemoveBodyBag, function(trigger, ...)
    managers.ehi:CallFunction(trigger.id, "DecreaseProgress", trigger.element)
end)
EHI:AddXPBreakdown({
    objective =
    {
        murky_station_equipment_found = { amount = 1000, times = 1 },
        murky_station_found_emp_part = 2000,
        escape = 2000
    },
    loot =
    {
        weapon = 1000,
        weapon_glock = 1000,
        weapon_scar = 1000,
        drk_bomb_part = { amount = 3000, times = 2 }
    }
})