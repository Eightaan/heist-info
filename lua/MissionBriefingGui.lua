local EHI = EHI
if EHI:CheckLoadHook("MissionBriefingGui") or EHI:IsXPTrackerDisabled() or not EHI:GetOption("show_mission_xp_overview") then
    return
end

local _params
local reloading_outfit = false
local function FormatTime(self, t)
    self._time = t
    local _t = tweak_data.ehi.functions.FormatMinutesAndSeconds(self)
    self._time = nil
    return _t
end
local xp_format = EHI:GetOption("xp_format")
local diff_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", EHI._cache.DifficultyIndex or 0) or 1

local original =
{
    init = MissionBriefingGui.init,
    set_slot_outfit = TeamLoadoutItem.set_slot_outfit
}

function MissionBriefingGui:init(...)
    original.init(self, ...)
    local w = self._fullscreen_panel:w() * 0.45
    self._ehi_panel = self._fullscreen_panel:panel({
		name = "ehi_panel",
		h = 100,
		layer = 9,
		w = w --0.35
	})
    self._ehi_panel_v2 = self._ehi_panel:panel({
        name = "panel",
		layer = 9,
    })
    self._ehi_panel:rect({
        name = "bg",
        halign = "grow",
		valign = "grow",
		layer = 1,
		color = Color(0.5, 0, 0, 0)
    })
    self._ehi_panel:set_rightbottom(40 + w, 144)
	self._ehi_panel:set_top(75) -- 100 - 10
    self._ehi_panel:set_visible(false)
    self._ehi_panel_v2:set_visible(false)
    self._lines = 0
    self._loc = managers.localization
    self._xp = managers.experience
    if xp_format == 1 then
        self._xp.FakeMultiplyXPWithAllBonuses = function(ex, xp)
            return xp
        end
    elseif xp_format == 2 then
        self._xp.FakeMultiplyXPWithAllBonuses = function(ex, xp)
            return xp * diff_multiplier
        end
    else
        self._xp.FakeMultiplyXPWithAllBonuses = function(ex, xp)
            local alive_original = ex._xp.alive_players
            local skill_original = ex._xp.skill_xp_multiplier
            local gage_original = ex._xp.gage_bonus
            ex._xp.alive_players = self._num_winners or 1
            ex._xp.skill_xp_multiplier = self._skill_bonus or 1
            ex._xp.gage_bonus = self._gage_bonus or 1
            local value = ex:MultiplyXPWithAllBonuses(xp)
            ex._xp.alive_players = alive_original
            ex._xp.skill_xp_multiplier = skill_original
            ex._xp.gage_bonus = gage_original
            return value
        end
    end
    self:ProcessXPBreakdown()
end

function MissionBriefingGui:ProcessXPBreakdown()
    if _params then
        self:AddXPBreakdown(_params)
    elseif tweak_data.levels:get_group_ai_state() == "skirmish" then
        -- Hardcoded in shared instance "obj_skm"
        local params =
        {
            wave =
            {
                8000,
                9200,
                10600,
                12200,
                14100,
                16300,
                18800,
                21700,
                25000
            }
        }
        self:AddXPBreakdown(params)
    else
        EHI:CallCallbackOnce("MissionBriefingGuiInit", self)
    end
end

local function GetTranslatedKey(self, key)
    local string_id = "ehi_experience_" .. key
    if self._loc:exists(string_id) then
        return self._loc:text(string_id)
    end
    return key
end
local function ProcessLoot(self, params, total_xp, gage)
    if params.loot_all then
        local data = params.loot_all
        local secured_bag = self._loc:text("ehi_experience_each_loot_secured")
        if type(data) == "table" then
            local value = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
            local xp = self._xp:cash_string(value, "+")
            local xp_with_gage
            if gage then
                xp_with_gage = self:FormatXPWithAllGagePackages(data.amount)
            end
            self:AddXPText(string.format("%s (%s): ", secured_bag, self._loc:text("ehi_experience_trigger_times", { times = data.times })), xp, xp_with_gage)
            --total_xp.total = total_xp.total + xp
            --total_xp.base = total_xp.base + data.amount
        else
            local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
            local xp = self._xp:cash_string(value, "+")
            local xp_with_gage
            if gage then
                xp_with_gage = self:FormatXPWithAllGagePackages(data)
            end
            self:AddXPText(string.format("%s: ", secured_bag), xp, xp_with_gage)
            total_xp.add = false
        end
    elseif params.loot then
        self:AddLootSecuredHeader()
        for loot, data in pairs(params.loot) do
            if type(data) == "table" then
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data.amount)
                end
                self:AddLootSecured(loot, data.times or 0, data.to_secure or 0, xp, xp_with_gage)
                total_xp.add = false
                --total_xp.total = total_xp.total + xp
                --total_xp.base = total_xp.base + data.amount
            else
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data)
                end
                self:AddLootSecured(loot, 0, 0, xp, xp_with_gage)
                total_xp.add = false
            end
        end
    end
end
local function ProcessEscape(self, str, params, total_xp, gage)
    if type(params) == "table" then
        for _, value in ipairs(params) do
            local s
            local _value = self._xp:FakeMultiplyXPWithAllBonuses(value.amount)
            local xp = self._xp:cash_string(_value, "+")
            local xp_with_gage
            if gage then
                xp_with_gage = self:FormatXPWithAllGagePackages(value.amount)
            end
            if value.stealth then
                s = self._loc:text("ehi_experience_stealth_escape")
                if value.timer then
                    s = s .. " (<" .. FormatTime(self, value.timer) .. ")"
                end
                s = s .. ": "
            else
                s = self._loc:text("ehi_experience_loud_escape")
                if value.c4_used then
                    s = s .. " (" .. self._loc:text("ehi_experience_c4_used") .. ")"
                end
                s = s .. ": "
            end
            self:AddXPText(s, xp, xp_with_gage)
        end
        if next(params) then
            total_xp.add = false
        end
    else
        local value = self._xp:FakeMultiplyXPWithAllBonuses(params)
        local xp = self._xp:cash_string(value, "+")
        local xp_with_gage
        if gage then
            xp_with_gage = self:FormatXPWithAllGagePackages(params)
        end
        self:AddXPText(str .. ": ", xp, xp_with_gage)
        --total_xp.total = total_xp.total + xp
        --total_xp.base = total_xp.base + params
    end
end
local function ProcessRandomObjectives(self, random, total_xp, gage)
    if type(random) ~= "table" then
        return
    end
    total_xp.add = false
    self:AddRandomObjectivesHeader(random.max)
    local separate = false
    local dot = utf8.char(1012)
    for obj, data in pairs(random) do
        if obj ~= "max" then
            if type(data) == "table" then
                if separate then
                    self:AddSeparator()
                end
                for _, xp in ipairs(data) do
                    local str = GetTranslatedKey(self, xp.name)
                    local value = self._xp:FakeMultiplyXPWithAllBonuses(xp.amount)
                    local _xp = self._xp:cash_string(value, "+")
                    local xp_with_gage
                    if gage then
                        xp_with_gage = self:FormatXPWithAllGagePackages(xp.amount)
                    end
                    if data.times then
                        self:AddXPText(dot .. " " .. str .. " (" .. tostring(data.times) .. "): ", _xp, xp_with_gage)
                    else
                        self:AddXPText(dot .. " " .. str .. ": ", _xp, xp_with_gage)
                    end
                end
                separate = true
            else
                local str = "- " .. GetTranslatedKey(self, obj)
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
                local _xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data)
                end
                self:AddXPText(str .. ": ", _xp, xp_with_gage)
                separate = false
            end
        end
    end
end
function MissionBriefingGui:AddXPBreakdown(params)
    if type(params) ~= "table" or not next(params) then
        return
    end
    local gage = xp_format == 3 and not params.no_gage
    self:AddXPOverviewText()
    self:FakeExperienceMultipliers()
    if params.wave_all then
        local data = params.wave_all
        if type(data) == "table" then
            local xp_multiplied = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
            local total_xp = self._xp:cash_string(xp_multiplied, "+")
            self:AddXPText(string.format("%s (%s): ", self._loc:text("ehi_experience_each_wave_survived"), self._loc:text("ehi_experience_trigger_times", { times = data.times })), total_xp)
            self:AddTotalXP(self._xp:cash_string(xp_multiplied * data.times, "+"))
        else
            local total_xp = self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(data), "+")
            self:AddXPText(string.format("%s: ", self._loc:text("ehi_experience_each_wave_survived")), total_xp)
        end
    elseif params.wave then
        local total_xp = 0
        for wave, xp in ipairs(params.wave) do
            local xp_computed = self._xp:FakeMultiplyXPWithAllBonuses(xp)
            total_xp = total_xp + xp_computed
            self:AddXPText(self._loc:text("ehi_experience_wave_survived", { wave = wave }), self._xp:cash_string(xp_computed, "+"))
        end
        self:AddTotalXP(self._xp:cash_string(total_xp, "+"))
    elseif params.objective then
        local total_xp = { base = 0, total = 0, add = not params.no_total_xp, total_xp_override = params.total_xp_override }
        for key, data in pairs(params.objective) do
            local str = GetTranslatedKey(self, key)
            if key == "escape" then
                ProcessEscape(self, str, data, total_xp, gage)
            elseif key == "random" then
                ProcessRandomObjectives(self, data, total_xp, gage)
            elseif type(data) == "table" then
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data.amount)
                end
                if data.times then
                    local times_formatted = self._loc:text("ehi_experience_trigger_times", { times = data.times })
                    local s
                    if data.stealth then
                        s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_stealth") .. ")"
                    elseif data.loud then
                        s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_loud") .. ")"
                    else
                        s = str .. " (" .. times_formatted .. ")"
                    end
                    self:AddXPText(s .. ": ", xp, xp_with_gage)
                elseif data.stealth then
                    self:AddXPText(str .. " (" .. self._loc:text("ehi_experience_stealth") .. "): ", xp, xp_with_gage)
                elseif data.loud then
                    self:AddXPText(str .. " (" .. self._loc:text("ehi_experience_loud") .. "): ", xp, xp_with_gage)
                else
                    self:AddXPText(str .. ": ", xp, xp_with_gage)
                end
            else
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data)
                end
                self:AddXPText(str .. ": ", xp, xp_with_gage)
            end
        end
        ProcessLoot(self, params, total_xp, gage)
        --[[if total_xp.add and total_xp.total > 0 then
            self:AddTotalXP(total_xp.total)
        elseif total_xp.total_xp_override then
        end]]
    elseif params.loot_all or params.loot then
        ProcessLoot(self, params, { total = 0, base = 0 }, gage)
    else
        for key, _ in pairs(params) do
            EHI:Log("[MissionBriefingGui] Unknown key! " .. tostring(key))
        end
    end
    if self._lines > 0 then
        local h = 10 + (self._lines * 22)
        self._ehi_panel:set_h(h)
        self._ehi_panel:set_visible(true)
        self._ehi_panel_v2:set_h(h)
        self._ehi_panel_v2:set_visible(true)
    end
    _params = params
end

function MissionBriefingGui:AddXPText(txt, value, value_with_gage)
    local text
    if value_with_gage then
        text = string.format("%s%s-%s XP", txt, value, value_with_gage)
    else
        text = string.format("%s%s XP", txt, value)
    end
    self._ehi_panel_v2:text({
        name = tostring(self._lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (self._lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        text = text,
        layer = 10
    })
    self._lines = self._lines + 1
end

function MissionBriefingGui:AddXPOverviewText()
    self._ehi_panel_v2:text({
        name = "0",
        blend_mode = "add",
        x = 10,
        y = 10,
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        text = self._loc:text("ehi_experience_xp_overview"),
        layer = 10
    })
    self._lines = self._lines + 1
end

function MissionBriefingGui:AddTotalXP(total)
    self._ehi_panel_v2:text({
        name = tostring(self._lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (self._lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        text = string.format("%s%s XP", self._loc:text("ehi_experience_total_xp"), total),
        layer = 10
    })
    self._lines = self._lines + 1
end

function MissionBriefingGui:AddLootSecuredHeader()
    self._ehi_panel_v2:text({
        name = tostring(self._lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (self._lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        text = self._loc:text("ehi_experience_loot_secured"),
        layer = 10
    })
    self._lines = self._lines + 1
end

function MissionBriefingGui:AddLootSecured(loot, times, to_secure, value, value_with_gage)
    local loot_name
    if loot == "_else" then
        loot_name = self._loc:text("ehi_experience_loot_else")
    elseif loot == "xp_bonus" then
        loot_name = self._loc:text("ehi_experience_xp_bonus")
    else
        local carry_data = tweak_data.carry[loot] or {}
        loot_name = carry_data.name_id and self._loc:text(carry_data.name_id) or loot
    end
    local str = "- " .. loot_name
    if times > 0 then
        local postfix = to_secure > 0 and "" or ")"
        str = str .. " (" .. self._loc:text("ehi_experience_trigger_times", { times = times }) .. postfix
    end
    if to_secure > 0 then
        local prefix = times > 0 and "; " or " ("
        str = str .. prefix .. self._loc:text("ehi_experience_to_secure", { amount = to_secure }) .. ")"
    end
    if value_with_gage then
        str = str .. ": " .. tostring(value) .. "-" .. tostring(value_with_gage) .. " XP"
    else
        str = str .. ": " .. tostring(value) .. " XP"
    end
    self._ehi_panel_v2:text({
        name = tostring(self._lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (self._lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        text = str,
        layer = 10
    })
    self._lines = self._lines + 1
end

function MissionBriefingGui:AddRandomObjectivesHeader(max)
    self._ehi_panel_v2:text({
        name = tostring(self._lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (self._lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        text = self._loc:text("ehi_experience_random_objectives", { count = max }),
        layer = 10
    })
    self._lines = self._lines + 1
end

function MissionBriefingGui:AddSeparator()
    self._ehi_panel_v2:text({
        name = tostring(self._lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (self._lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        text = "",
        layer = 10
    })
    self._lines = self._lines + 1
end

function MissionBriefingGui:FakeExperienceMultipliers()
    if BB and BB.grace_period and Global.game_settings.single_player and Global.game_settings.team_ai then
        self._num_winners = 4
    end
    if Global.block_update_outfit_information then -- Outfit update is late when "managers.player:get_skill_exp_multiplier(true)" is called, update it now to stay accurate
        local outfit_string = managers.blackmarket:outfit_string()
        local local_peer = managers.network:session():local_peer()
        reloading_outfit = true -- Fix for Beardlib stack overflow crash
        local_peer:set_outfit_string(outfit_string)
        reloading_outfit = false
    end
    self._skill_bonus = managers.player:get_skill_exp_multiplier(true)
end

function MissionBriefingGui:FormatXPWithAllGagePackages(base_xp)
    self._gage_bonus = 1.05
    local value = self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(base_xp), "")
    self._gage_bonus = 1
    return value
end

function MissionBriefingGui:RefreshXPOverview()
    self._num_winners = managers.network:session() and managers.network:session():amount_of_players() or 1
    self._ehi_panel_v2:clear()
    self._lines = 0
    self:ProcessXPBreakdown()
end

function TeamLoadoutItem:set_slot_outfit(slot, ...)
    original.set_slot_outfit(self, slot, ...)
	local player_slot = self._player_slots[slot]
	if not player_slot or reloading_outfit then
		return
	end
    local mcm = managers.menu_component
    if mcm and mcm._mission_briefing_gui then
        mcm._mission_briefing_gui:RefreshXPOverview()
    end
end