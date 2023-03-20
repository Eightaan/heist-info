local EHI = EHI
if EHI:CheckLoadHook("ExperienceManager") or EHI:IsXPTrackerDisabled() then
    return
end

local original =
{
    init = ExperienceManager.init
}

local BaseXP = 0
local TotalXP = 0
local OldTotalXP = 0
local xp_format = EHI:GetOption("xp_format")
local xp_panel = EHI:GetOption("xp_panel")
local EXPERIENCE = ""
local EXPERIENCE_GAINED = ""
local EXPERIENCE_TOTAL = ""
if EHI:IsOneXPElementHeist(Global.game_settings.level_id) and xp_panel == 2 then
    xp_panel = 1 -- Force one XP panel when the heist gives you the XP at the escape zone -> less screen clutter
end

function ExperienceManager:init(...)
    original.init(self, ...)
    self._xp =
    {
        mutator_xp_reduction = 0,
        level_to_stars = math.clamp(math.ceil((self:current_level() + 1) / 10), 1, 10), -- Can't call the function directly because they didn't use "self"
        in_custody = false,
        alive_players = Global.game_settings.single_player and 1 or 0,
        gage_bonus = 1,
        stealth = true,
        bonus_xp = 0,
        skill_xp_multiplier = 1 -- Recalculated in ExperienceManager:RecalculateSkillXPMultiplier()
    }
    if xp_format == 3 then -- Multiply
        local function f()
            self._xp.stealth = false
            self:RecalculateSkillXPMultiplier()
        end
        EHI:AddOnAlarmCallback(f)
        local function f2(state)
            self:SetInCustody(state)
        end
        EHI:AddOnCustodyCallback(f2)
    end
    EXPERIENCE = managers.localization:text("ehi_popup_experience")
    local gained = xp_format == 1 and "ehi_popup_experience_base_gained" or "ehi_popup_experience_gained"
    if xp_panel == 4 then
        gained = "ehi_popup_experience_gained"
    end
    EXPERIENCE_GAINED = managers.localization:text(gained)
    EXPERIENCE_TOTAL = managers.localization:text("ehi_popup_experience_total")
    EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(self, self, "RecalculateSkillXPMultiplier"))
    EHI:AddCallback(EHI.CallbackMessage.InitManagers, callback(self, self, "SetJobData"))
    EHI:AddCallback(EHI.CallbackMessage.InitManagers, callback(self, self, "SetPlayerData"))
    EHI:AddCallback(EHI.CallbackMessage.InitManagers, callback(self, self, "SetMutatorData"))
end

function ExperienceManager:SetJobData(managers)
    local job = managers.job
    local difficulty_stars = job:current_difficulty_stars()
    self._xp.job_stars = job:current_job_stars()
    self._xp.stealth_bonus = job:get_ghost_bonus()
    self._xp.projob_multiplier = 1
    if job:is_current_job_professional() then
        self._xp.projob_multiplier = tweak_data:get_value("experience_manager", "pro_job_multiplier") or 1
    end
    local heat = job:get_job_heat_multipliers(job:current_job_id())
    self._xp.heat = heat and heat ~= 0 and heat or 1
    self._xp.contract_difficulty_multiplier = self:get_contract_difficulty_multiplier(difficulty_stars)
    self._xp.is_level_limited = self._xp.level_to_stars < self._xp.job_stars
    if xp_format ~= 1 then
        self._xp.difficulty_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", difficulty_stars) or 1
    end
end

function ExperienceManager:SetPlayerData(managers)
    local player = managers.player
    self._xp.infamy_bonus = player:get_infamy_exp_multiplier()
	local multiplier = tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1
    local level_data = tweak_data.levels[Global.game_settings.level_id] or {}
	if level_data.is_christmas_heist then
		multiplier = multiplier + (tweak_data:get_value("experience_manager", "limited_xmas_bonus_multiplier") or 1) - 1
	end
	self._xp.limited_xp_bonus = multiplier
end

function ExperienceManager:SetMutatorData(managers)
    local mutator = managers.mutators
    if not mutator:can_mutators_be_active() then
        return
    end
    self._xp.mutator_xp_reduction = mutator:get_experience_reduction() * -1
    --self._xp.MutatorPiggyBank = mutator:is_mutator_active(MutatorPiggyBank)
    --self._xp.MutatorCG22 = mutator:is_mutator_active(MutatorCG22)
end

function ExperienceManager:UpdateSkillXPMultiplier(multiplier)
    self._xp.skill_xp_multiplier = multiplier
    self:RecalculateXP()
end

function ExperienceManager:RecalculateSkillXPMultiplier()
    self:UpdateSkillXPMultiplier(managers.player:get_skill_exp_multiplier(self._xp.stealth))
end

function ExperienceManager:SetGagePackageBonus(bonus)
    self._xp.gage_bonus = bonus
    self:RecalculateXP()
end

function ExperienceManager:SetInCustody(in_custody)
    self._xp.in_custody = in_custody
    if in_custody then
        self._xp.alive_players = math.max(self._xp.alive_players - 1, 0)
    else
        self._xp.alive_players = self._xp.alive_players + 1
    end
    self:RecalculateXP()
end

function ExperienceManager:IncreaseAlivePlayers()
    self._xp.alive_players = self._xp.alive_players + 1
    self:RecalculateXP()
end

function ExperienceManager:QueryAmountOfAlivePlayers()
    self._xp.alive_players = managers.network:session() and managers.network:session():amount_of_alive_players() or 0
    self:RecalculateSkillXPMultiplier()
end

function ExperienceManager:DecreaseAlivePlayers(human_player)
    self._xp.alive_players = math.max(self._xp.alive_players - 1, 0)
    if human_player then
        self:RecalculateSkillXPMultiplier()
    else
        self:RecalculateXP()
    end
end

local Show = function() end
if xp_panel == 1 then
    Show = function(self, diff)
        if managers.ehi:TrackerExists("XP") then
            managers.ehi:AddXPToTracker("XP", diff)
        else
            managers.ehi:AddTracker({
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

function ExperienceManager:ShowGainedXP(base_xp, xp_gained)
    BaseXP = BaseXP + base_xp
    TotalXP = xp_gained and (TotalXP + xp_gained) or self:MultiplyXPWithAllBonuses(BaseXP)
    if OldTotalXP ~= TotalXP then
        local diff = TotalXP - OldTotalXP
        OldTotalXP = TotalXP
        Show(self, diff)
    end
end

if not EHI:GetOption("show_xp_in_mission_briefing_only") then
    local f
    if xp_panel == 2 then
        if xp_format == 1 then
            f = function(self, amount)
                if amount > 0 then
                    managers.ehi:AddXPToTracker("XPTotal", amount)
                end
            end
        elseif xp_format == 2 then
            f = function(self, amount)
                if amount > 0 then
                    managers.ehi:AddXPToTracker("XPTotal", amount * self._xp.difficulty_multiplier)
                end
            end
        else
            f = function(self, amount)
                if amount > 0 then
                    BaseXP = BaseXP + amount
                    managers.ehi:SetXPInTracker("XPTotal", self:MultiplyXPWithAllBonuses(BaseXP))
                end
            end
        end
    else
        if xp_format == 1 then
            f = function(self, amount)
                if amount > 0 then
                    self:ShowGainedXP(amount, amount)
                end
            end
        elseif xp_format == 2 then
            f = function(self, amount)
                if amount > 0 then
                    self:ShowGainedXP(amount, amount * self._xp.difficulty_multiplier)
                end
            end
        else
            f = function(self, amount)
                if amount > 0 then
                    self:ShowGainedXP(amount)
                end
            end
        end
    end
    EHI:Hook(ExperienceManager, "mission_xp_award", f)

    original.on_loot_drop_xp = ExperienceManager.on_loot_drop_xp
    function ExperienceManager:on_loot_drop_xp(value_id, ...)
        original.on_loot_drop_xp(self, value_id, ...)
        local amount = tweak_data:get_value("experience_manager", "loot_drop_value", value_id) or 0
        if amount <= 0 then
            return
        end
        self._xp.bonus_xp = self._xp.bonus_xp + amount
        self:RecalculateXP()
    end
end

local math_round = math.round
function ExperienceManager:MultiplyXPWithAllBonuses(xp)
	local job_stars = self._xp.job_stars
	local num_winners = self._xp.alive_players
	local player_stars = self._xp.level_to_stars
	local pro_job_multiplier = self._xp.projob_multiplier or 1
	local ghost_multiplier = 1 + (self._xp.stealth_bonus or 0)
	local xp_multiplier = self._xp.contract_difficulty_multiplier
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

	if self._xp.is_level_limited then
		local diff_in_stars = job_stars - player_stars
		local tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", diff_in_stars) or 0
		base_xp = math_round(base_xp * tweak_multiplier)
	end

	contract_xp = base_xp
	risk_dissect = math_round(contract_xp * xp_multiplier)
	contract_xp = contract_xp + risk_dissect

	if self._xp.in_custody then
		local multiplier = tweak_data:get_value("experience_manager", "in_custody_multiplier") or 1
		personal_win_dissect = math_round(contract_xp * multiplier - contract_xp)
		contract_xp = contract_xp + personal_win_dissect
	end

	total_xp = contract_xp
	local total_contract_xp = total_xp
	bonus_xp = self._xp.skill_xp_multiplier
	skill_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + skill_dissect
	bonus_xp = self._xp.infamy_bonus
	infamy_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + infamy_dissect

    local num_players_bonus = num_winners and tweak_data:get_value("experience_manager", "alive_humans_multiplier", num_winners) or 1
    alive_crew_dissect = math_round(total_contract_xp * num_players_bonus - total_contract_xp)
    total_xp = total_xp + alive_crew_dissect

	bonus_xp = self._xp.gage_bonus
	gage_assignment_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + gage_assignment_dissect
	ghost_dissect = math_round(total_xp * ghost_multiplier - total_xp)
	total_xp = total_xp + ghost_dissect
	local heat_xp_mul = self._xp.heat
	job_heat_dissect = math_round(total_xp * heat_xp_mul - total_xp)
	total_xp = total_xp + job_heat_dissect
	bonus_xp = self._xp.limited_xp_bonus
	extra_bonus_dissect = math_round(total_xp * bonus_xp - total_xp)
    total_xp = total_xp + extra_bonus_dissect
	local bonus_mutators_dissect = total_xp * self._xp.mutator_xp_reduction
	total_xp = total_xp + bonus_mutators_dissect
    total_xp = total_xp + self._xp.bonus_xp
	return total_xp
end

function ExperienceManager:RecalculateXP()
    if BaseXP == 0 then
        return
    end
    if xp_format == 3 then
        if xp_panel == 2 then
            managers.ehi:SetXPInTracker("XPTotal", self:MultiplyXPWithAllBonuses(BaseXP))
        else
            self:ShowGainedXP(0)
        end
    end
end

function ExperienceManager:SetPiggyBankExplodedLevel(level)
    self._xp.pda9_event_exploded_level = level
    self:RecalculateXP()
end

function ExperienceManager:SetCG22EventXPCollected(xp)
    self._xp.cg22_xp_collected = xp
    self:RecalculateXP()
end