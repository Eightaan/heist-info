local EHI = EHI
if EHI:CheckHook("ExperienceManager") then
    return
end

---@class ExperienceManager
---@field cash_string fun(self: self, cash: number, cash_string: string?): string
---@field experience_string fun(self: self, xp: number): string
---@field total fun(self: self): number
---@field current_level fun(self: self): number
---@field reached_level_cap fun(self: self): boolean
---@field get_max_prestige_xp fun(self: self): number
---@field get_current_prestige_xp fun(self: self): number
---@field next_level_data_points fun(self: self): number
---@field next_level_data_current_points fun(self: self): number

function ExperienceManager:GetRemainingXPToMaxLevel()
    local totalXpTo100 = 0
    for _, level in ipairs(tweak_data.experience_manager.levels) do
        totalXpTo100 = totalXpTo100 + Application:digest_value(level.points, false)
    end
    return math.max(totalXpTo100 - self:total(), 0)
end

function ExperienceManager:GetRemainingPrestigeXP()
    return self:get_max_prestige_xp() - self:get_current_prestige_xp()
end

if EHI:CheckNotLoad() or EHI:IsXPTrackerDisabled() then
    return
end

local original =
{
    init = ExperienceManager.init
}

local Show = function(...) end
local BaseXP = 0
local TotalXP = 0
local OldTotalXP = 0
local xp_format = EHI:GetOption("xp_format")
local xp_panel = EHI:GetOption("xp_panel")
local EXPERIENCE = ""
local EXPERIENCE_GAINED = ""
local EXPERIENCE_TOTAL = ""

function ExperienceManager:init(...)
    original.init(self, ...)
    self._ehi_xp =
    {
        mutator_xp_reduction = 0,
        level_to_stars = math.clamp(math.ceil((self:current_level() + 1) / 10), 1, 10), -- Can't call the function directly because they didn't use "self"
        in_custody = false,
        alive_players = Global.game_settings.single_player and 1 or 0,
        gage_bonus = 1,
        stealth = true,
        bonus_xp = 0,
        skill_xp_multiplier = 1, -- Recalculated in ExperienceManager:RecalculateSkillXPMultiplier()
        difficulty_multiplier = 1
    }
    if xp_format == 3 then -- Multiply
        EHI:AddOnAlarmCallback(function()
            self._ehi_xp.stealth = false
            self:RecalculateSkillXPMultiplier()
        end)
        EHI:AddOnCustodyCallback(function(state)
            self:SetInCustody(state)
        end)
        EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(self, self, "RecalculateSkillXPMultiplier"))
    end
    EXPERIENCE = managers.localization:text("ehi_popup_experience")
    local gained = xp_format == 1 and "ehi_popup_experience_base_gained" or "ehi_popup_experience_gained"
    if xp_panel == 4 then
        gained = "ehi_popup_experience_gained"
    end
    EXPERIENCE_GAINED = managers.localization:text(gained)
    EXPERIENCE_TOTAL = managers.localization:text("ehi_popup_experience_total")
    EHI:AddCallback(EHI.CallbackMessage.InitManagers, callback(self, self, "LoadData"))
    if not EHI:GetOption("show_xp_in_mission_briefing_only") then
        EHI:AddCallback(EHI.CallbackMessage.InitFinalize, callback(self, self, "HookAwardXP"))
    end
end

function ExperienceManager:LoadData(managers)
    -- Job
    local job = managers.job
    local difficulty_stars = job:current_difficulty_stars()
    self._ehi_xp.job_stars = job:current_job_stars()
    self._ehi_xp.stealth_bonus = job:get_ghost_bonus()
    self._ehi_xp.projob_multiplier = 1
    if job:is_current_job_professional() then
        self._ehi_xp.projob_multiplier = tweak_data:get_value("experience_manager", "pro_job_multiplier") or 1
    end
    local heat = job:get_job_heat_multipliers(job:current_job_id())
    self._ehi_xp.heat = heat and heat ~= 0 and heat or 1
    self._ehi_xp.is_level_limited = self._ehi_xp.level_to_stars < self._ehi_xp.job_stars
    if xp_format ~= 1 then
        self._ehi_xp.difficulty_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", difficulty_stars) or 1
    end
    -- Player
    local player = managers.player
    self._ehi_xp.infamy_bonus = player:get_infamy_exp_multiplier()
    local multiplier = tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1
    if tweak_data.levels:IsLevelChristmas() then
        multiplier = multiplier + (tweak_data:get_value("experience_manager", "limited_xmas_bonus_multiplier") or 1) - 1
    end
    self._ehi_xp.limited_xp_bonus = multiplier
    -- Mutators
    local mutator = managers.mutators
    if mutator:can_mutators_be_active() then
        self._ehi_xp.mutator_xp_reduction = mutator:get_experience_reduction() * -1
        self._ehi_xp.MutatorPiggyRevenge = mutator:is_mutator_active(MutatorPiggyRevenge)
        self._ehi_xp.MutatorPiggyBank = mutator:is_mutator_active(MutatorPiggyBank)
        self._ehi_xp.MutatorCG22 = mutator:is_mutator_active(MutatorCG22)
    end
end

function ExperienceManager:HookAwardXP()
    if EHI:IsOneXPElementHeist(Global.game_settings.level_id) and xp_panel == 2 then
        xp_panel = 1 -- Force one XP panel when the heist gives you the XP at the escape zone -> less screen clutter
    end
    if xp_panel == 1 then
        Show = function(self, diff)
            if managers.ehi_tracker:TrackerExists("XP") then
                managers.ehi_tracker:AddXPToTracker("XP", diff)
            else
                managers.ehi_tracker:AddTracker({
                    id = "XP",
                    amount = diff,
                    class = "EHIXPTracker"
                })
            end
        end
    elseif xp_panel == 3 then
        Show = function(self, diff)
            if managers.hud then
                managers.hud:custom_ingame_popup_text(EXPERIENCE, EXPERIENCE_GAINED .. self:cash_string(diff, diff >= 0 and "+" or "") .. "\n" .. EXPERIENCE_TOTAL .. self:cash_string(TotalXP, "+"), "EHI_XP")
            end
        end
    elseif xp_panel == 4 then
        Show = function(self, diff)
            if managers.hud and managers.hud._hud_hint then
                managers.hud:show_hint({ text = EXPERIENCE_GAINED .. self:cash_string(diff, diff >= 0 and "+" or "") .. " XP; ".. EXPERIENCE_TOTAL .. self:cash_string(TotalXP, "+") .. " XP" })
            end
        end
    end
    local f
    if xp_panel == 2 then
        if xp_format == 1 then
            f = function(self, amount)
                if amount > 0 then
                    managers.ehi_tracker:AddXPToTracker("XPTotal", amount)
                end
            end
        elseif xp_format == 2 then
            f = function(self, amount)
                if amount > 0 then
                    managers.ehi_tracker:AddXPToTracker("XPTotal", amount * self._ehi_xp.difficulty_multiplier)
                end
            end
        else
            f = function(self, amount)
                if amount > 0 then
                    BaseXP = BaseXP + amount
                    managers.ehi_tracker:SetXPInTracker("XPTotal", self:MultiplyXPWithAllBonuses(BaseXP))
                end
            end
        end
    elseif xp_format == 1 then
        f = function(self, amount)
            if amount > 0 then
                self:ShowGainedXP(amount, amount)
            end
        end
    elseif xp_format == 2 then
        f = function(self, amount)
            if amount > 0 then
                self:ShowGainedXP(amount, amount * self._ehi_xp.difficulty_multiplier)
            end
        end
    else
        f = function(self, amount)
            if amount > 0 then
                self:ShowGainedXP(amount)
            end
        end
    end
    EHI:Hook(self, "mission_xp_award", f)
    original.on_loot_drop_xp = self.on_loot_drop_xp
    self.on_loot_drop_xp = function(self, value_id, ...)
        original.on_loot_drop_xp(self, value_id, ...)
        local amount = tweak_data:get_value("experience_manager", "loot_drop_value", value_id) or 0
        if amount <= 0 then
            return
        end
        self._ehi_xp.bonus_xp = self._ehi_xp.bonus_xp + amount
        self:RecalculateXP()
    end
end

function ExperienceManager:UpdateSkillXPMultiplier(multiplier)
    self._ehi_xp.skill_xp_multiplier = multiplier
    self:RecalculateXP()
end

function ExperienceManager:RecalculateSkillXPMultiplier()
    self:UpdateSkillXPMultiplier(managers.player:get_skill_exp_multiplier(self._ehi_xp.stealth))
end

function ExperienceManager:SetGagePackageBonus(bonus)
    self._ehi_xp.gage_bonus = bonus
    self:RecalculateXP()
end

function ExperienceManager:SetInCustody(in_custody)
    self._ehi_xp.in_custody = in_custody
    if in_custody then
        self._ehi_xp.alive_players = math.max(self._ehi_xp.alive_players - 1, 0)
    else
        self._ehi_xp.alive_players = self._ehi_xp.alive_players + 1
    end
    self:RecalculateXP()
end

function ExperienceManager:IncreaseAlivePlayers()
    self._ehi_xp.alive_players = self._ehi_xp.alive_players + 1
    self:RecalculateXP()
end

function ExperienceManager:QueryAmountOfAllPlayers()
    local previous_value = self._ehi_xp.alive_players
    local human_players = managers.network:session() and managers.network:session():amount_of_alive_players() or 0
    local bots = managers.criminals:nr_AI_criminals()
    self._ehi_xp.alive_players = math.clamp(human_players + bots, 0, 4)
    if previous_value ~= self._ehi_xp.alive_players then
        self:RecalculateSkillXPMultiplier()
    end
end

function ExperienceManager:QueryAmountOfAlivePlayers()
    self._ehi_xp.alive_players = managers.network:session() and managers.network:session():amount_of_alive_players() or 0
    self:RecalculateSkillXPMultiplier()
end

function ExperienceManager:DecreaseAlivePlayers(human_player)
    self._ehi_xp.alive_players = math.max(self._ehi_xp.alive_players - 1, 0)
    if human_player then
        self:RecalculateSkillXPMultiplier()
    else
        self:RecalculateXP()
    end
end

function ExperienceManager:ShowGainedXP(base_xp, xp_gained)
    BaseXP = BaseXP + base_xp
    TotalXP = xp_gained and (TotalXP + xp_gained) or self:MultiplyXPWithAllBonuses(BaseXP)
    if OldTotalXP ~= TotalXP then
        local diff = TotalXP - OldTotalXP
        OldTotalXP = TotalXP
        Show(self, diff)
    end
end

local math_round = math.round
function ExperienceManager:MultiplyXPWithAllBonuses(xp)
    local job_stars = self._ehi_xp.job_stars
    local num_winners = self._ehi_xp.alive_players
    local player_stars = self._ehi_xp.level_to_stars
    local pro_job_multiplier = self._ehi_xp.projob_multiplier or 1
    local ghost_multiplier = 1 + (self._ehi_xp.stealth_bonus or 0)
    local xp_multiplier = self._ehi_xp.difficulty_multiplier or 1
    local contract_xp = 0
    local total_xp = 0
    local stage_xp_dissect = 0
    local job_xp_dissect = 0
    local risk_dissect = 0
    local personal_win_dissect = 0
    local alive_crew_dissect = 0
    local skill_dissect = 0
    local base_xp = 0
    local job_heat_dissect = 0
    local ghost_dissect = 0
    local infamy_dissect = 0
    local extra_bonus_dissect = 0
    local gage_assignment_dissect = 0
    local mission_xp_dissect = xp
    local pro_job_xp_dissect = 0
    local bonus_xp = 0

    base_xp = job_xp_dissect + stage_xp_dissect + mission_xp_dissect
    pro_job_xp_dissect = math_round(base_xp * pro_job_multiplier - base_xp)
    base_xp = base_xp + pro_job_xp_dissect

    if self._ehi_xp.is_level_limited then
        local diff_in_stars = job_stars - player_stars
        local tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", diff_in_stars) or 0
        base_xp = math_round(base_xp * tweak_multiplier)
    end

    contract_xp = base_xp
    risk_dissect = math_round(contract_xp * xp_multiplier)
    contract_xp = contract_xp + risk_dissect

    if self._ehi_xp.in_custody then
        local multiplier = tweak_data:get_value("experience_manager", "in_custody_multiplier") or 1
        personal_win_dissect = math_round(contract_xp * multiplier - contract_xp)
        contract_xp = contract_xp + personal_win_dissect
    end

    total_xp = contract_xp
    local total_contract_xp = total_xp
    bonus_xp = self._ehi_xp.skill_xp_multiplier or 1
    skill_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
    total_xp = total_xp + skill_dissect
    bonus_xp = self._ehi_xp.infamy_bonus
    infamy_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
    total_xp = total_xp + infamy_dissect

    local num_players_bonus = num_winners and tweak_data:get_value("experience_manager", "alive_humans_multiplier", num_winners) or 1
    alive_crew_dissect = math_round(total_contract_xp * num_players_bonus - total_contract_xp)
    total_xp = total_xp + alive_crew_dissect

    bonus_xp = self._ehi_xp.gage_bonus
    gage_assignment_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
    total_xp = total_xp + gage_assignment_dissect
    ghost_dissect = math_round(total_xp * ghost_multiplier - total_xp)
    total_xp = total_xp + ghost_dissect
    local heat_xp_mul = self._ehi_xp.heat
    job_heat_dissect = math_round(total_xp * heat_xp_mul - total_xp)
    total_xp = total_xp + job_heat_dissect
    bonus_xp = self._ehi_xp.limited_xp_bonus
    extra_bonus_dissect = math_round(total_xp * bonus_xp - total_xp)
    total_xp = total_xp + extra_bonus_dissect

    -- pda10 event
	--[[if self._ehi_xp.MutatorPiggyBank then
	    local pig_level = self._ehi_xp.piggy_event_exploded_level or false
        local bonus_piggybank_dissect = math_round(pig_level and (self._ehi_xp.pda9_rewards[self._ehi_xp.current_difficulty] or self._ehi_xp.pda9_rewards.default) * tweak_data.mutators.piggybank.pig_levels[pig_level].bag_requirement or 0)
	    total_xp = total_xp + bonus_piggybank_dissect
	end

	if self._ehi_xp.MutatorCG22 then
        local bonus_cg22_dissect = self._ehi_xp.cg22_xp_collected or 0
        total_xp = total_xp + bonus_cg22_dissect
	end

	if self._ehi_xp.MutatorPiggyRevenge and self._ehi_xp.piggy_event_exploded_level then
        local piggyrevenge_level = math.clamp(self._ehi_xp.piggy_event_exploded_level, 1, #self._ehi_xp.pda10_rewards)
        local piggybank_rewards = piggyrevenge_level and self._ehi_xp.pda10_rewards[piggyrevenge_level].rewards
        local bonus_piggyrevenge_dissect = piggybank_rewards and total_xp * ((piggybank_rewards.xp_multiplier or 1) - 1) or 0
        total_xp = total_xp + bonus_piggyrevenge_dissect
	end]]

    local bonus_mutators_dissect = total_xp * self._ehi_xp.mutator_xp_reduction
    total_xp = total_xp + bonus_mutators_dissect

    --[[if self._ehi_xp.MutatorCG22 then
        total_xp = total_xp * 2
    end]]

    total_xp = total_xp + self._ehi_xp.bonus_xp
    return total_xp
end

function ExperienceManager:RecalculateXP()
    if BaseXP == 0 then
        return
    end
    if xp_format == 3 then
        if xp_panel == 2 then
            managers.ehi_tracker:SetXPInTracker("XPTotal", self:MultiplyXPWithAllBonuses(BaseXP))
        else
            self:ShowGainedXP(0)
        end
    end
end

function ExperienceManager:SetPiggyBankExplodedLevel(level)
    self._ehi_xp.piggy_event_exploded_level = level
    self:RecalculateXP()
end

function ExperienceManager:SetCG22EventXPCollected(xp)
    self._ehi_xp.cg22_xp_collected = xp
    self:RecalculateXP()
end