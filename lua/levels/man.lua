local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local deal = { Icon.Car, Icon.Goto }
local delay = 4 + 356/30
local start_chance = 15 -- Normal
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    -- Hard + Very Hard
    start_chance = 10
elseif ovk_and_up then
    -- OVERKILL+
    start_chance = 5
end
local CodeChance = { chance = start_chance, id = "CodeChance", icons = { Icon.Hostage, Icon.PCHack }, flash_times = 1, class = TT.Chance }
local triggers = {
    [101587] = { time = 30 + delay, id = "DealGoingDown", icons = deal },
    [101588] = { time = 40 + delay, id = "DealGoingDown", icons = deal },
    [101589] = { time = 50 + delay, id = "DealGoingDown", icons = deal },
    [101590] = { time = 60 + delay, id = "DealGoingDown", icons = deal },
    [101591] = { time = 70 + delay, id = "DealGoingDown", icons = deal },

    [102891] = { id = "CodeChance", special_function = SF.RemoveTracker },

    [101825] = CodeChance, -- First hack
    [102016] = CodeChance, -- Second and Third Hack
    [102121] = { time = 10, id = "Escape", icons = { Icon.Escape } },

    [103163] = { time = 1.5 + 25, random_time = 10, id = "Faint", icons = { "hostage", Icon.Wait } },

    [102866] = { time = 5, id = "GotCode", icons = { Icon.Wait } },

    [102887] = { amount = 5, id = "CodeChance", special_function = SF.IncreaseChance }
}

local achievements =
{
    man_2 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100698] = { status = "no_down", class = TT.AchievementStatus, trigger_times = 1 },
            [103963] = { special_function = SF.SetAchievementFailed },
        }
    },
    man_3 =
    {
        elements =
        {
            [100698] = { class = TT.AchievementStatus, trigger_times = 1 },
            [103957] = { special_function = SF.SetAchievementFailed }
        },
        load_sync = function(self)
            if EHI.ConditionFunctions.IsStealth() then
                self:AddAchievementStatusTracker("man_3")
            end
        end
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowAchievementLootCounter({
    achievement = "man_4",
    max = 10,
    triggers =
    {
        [103989] = { special_function = SF.IncreaseProgress }
    },
    load_sync = function(self)
        -- Achievement count used planks on windows, vents, ...
        -- There are total 49 positions and 10 planks
        self:SetTrackerProgress("man_4", 49 - self:CountInteractionAvailable("stash_planks"))
    end
})

local tbl =
{
    -- Saws
    [102034] = { remove_vanilla_waypoint = true, waypoint_id = 102303 },
    [102035] = { remove_vanilla_waypoint = true, waypoint_id = 102301 },
    [102040] = { remove_vanilla_waypoint = true, waypoint_id = 101837 },
    [102041] = { remove_vanilla_waypoint = true, waypoint_id = 101992 }
}

EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        undercover_deal_stealth = 2500,
        undercover_deal_loud = 500,
        undercover_limo_open = 4000,
        undercover_taxman_is_in_chair = 4000,
        pc_hack = { amount = 4000, times = 3 },
        undercover_hack_fixed = 1000,
        escape = 3000
    }
})