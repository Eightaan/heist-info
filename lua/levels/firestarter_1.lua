local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Weapons = { 100817, 100818, 100657, 100659, 100663, 100664, 100673, 100715, 100712, 100704, 100705, 100749, 100751, 100681, 100819, 100821, 100823, 100950, 100962, 100967, 101193 } -- Hangar 01 + Hangar 4 (bag 03)
local n = 22
-- Hangar 2, Hangar 3 + Hangar 4 (Half)
for i = 102126, 102175, 1 do
    Weapons[n] = i
    n = n + 1
end
-- Hangar 4 (Second half)
for i = 103797, 103806, 1 do
    Weapons[n] = i
    n = n + 1
end
local function LordOfWarAchievement()
    local n_of_weapons = tweak_data.ehi.functions.GetNumberOfVisibleWeapons(Weapons)
    EHI:ShowAchievementLootCounter({
        achievement = "lord_of_war",
        max = n_of_weapons,
        triggers =
        {
            [103427] = { special_function = SF.SetAchievementFailed, trigger_times = 1 } -- Weapons destroyed
        },
        hook_triggers = true,
        add_to_counter = true
    })
    if EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
        EHI:ShowAchievementLootCounter({
            achievement = "ovk_10",
            max = n_of_weapons,
            triggers =
            {
                [103427] = { special_function = SF.IncreaseProgress } -- Weapons destroyed
            },
            hook_triggers = true,
            remove_after_reaching_target = false
        })
    end
    EHI:ShowLootCounter({
        max = n_of_weapons,
        additional_loot = 1, -- 1 bag of money
        triggers =
        {
            [103427] = { special_function = SF.DecreaseProgressMax }, -- Weapons destroyed
            [104470] = { special_function = SF.DecreaseProgressMax }, -- Money destroyed
            [104471] = { special_function = SF.DecreaseProgressMax }, -- Money destroyed
            [104472] = { special_function = SF.DecreaseProgressMax }, -- Money destroyed
            [104473] = { special_function = SF.DecreaseProgressMax } -- Money destroyed
        },
        hook_triggers = true
    })
end

local other =
{
    -- This needs to be delayed because the number of required weapons are decided upon spawn
    [103240] = { special_function = SF.CustomCodeDelayed, t = 5, f = LordOfWarAchievement },

    [100531] = EHI:AddAssaultDelay({ time = 30 })
}

EHI:ParseTriggers({
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        fs_secured_required_bags = 10000,
        fs_burned_required_bags = 8000,
        all_bags_secured = 6000
    },
    no_total_xp = true
})
--[[EHI:AddLoadSyncFunction(function(self)
    LordOfWarAchievement()
    if self:TrackerExists("lord_of_war") then
        self:SetTrackerProgress("lord_of_war", managers.loot:GetSecuredBagsTypeAmount("weapon"))
        if self:TrackerExists("LootCounter") then
            self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
        end
    else
        self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
    end
end)]]