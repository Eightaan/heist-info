local EHI = EHI
if EHI:CheckLoadHook("MissionBriefingGui") or EHI:IsXPTrackerDisabled() or not EHI:GetOption("show_mission_xp_overview") then
    return
end

local colors =
{
    loot_secured = EHI:GetColor(EHI.settings.colors.mission_briefing.loot_secured),
    total_xp = EHI:GetColor(EHI.settings.colors.mission_briefing.total_xp),
    optional = EHI:GetColor(EHI.settings.colors.mission_briefing.optional)
}

---@type XPBreakdown
local _params
local TacticSelected = 1
XPBreakdownItem = class()
function XPBreakdownItem:init(gui, panel, string, type, selected)
    self._gui = gui
    self._type = type
    self._panel = panel
    self._button = panel:text({
        align = "center",
        name = string,
        blend_mode = "add",
        layer = 2,
        text = gui._loc:text(string),
        font_size = tweak_data.menu.pd2_large_font_size / 2,
        font = tweak_data.menu.pd2_large_font,
        color = tweak_data.screen_colors.button_stage_3,
        visible = false
    })
    local _, _, w, h = self._button:text_rect()
    self._button:set_size(w + 15, h)
    self._button:set_position(math.round(self._button:x()), math.round(self._button:y()))
    self._tab_select_rect = panel:bitmap({
        texture = "guis/textures/pd2/shared_tab_box",
        visible = false,
        layer = 1,
        name = string .. "_selected",
        color = tweak_data.screen_colors.text
    })
    self._tab_select_rect:set_shape(self._button:shape())
    if selected then
        self:Select(true)
    end
end

function XPBreakdownItem:GetIndex()
    return self._type == "stealth" and 1 or 2
end

function XPBreakdownItem:SetPreviousItem(item)
    self._previous_item = item
end

function XPBreakdownItem:GetButton()
    return self._button
end

function XPBreakdownItem:SetPosByPanel(panel)
    self._button:set_bottom(panel:top())
    self._button:set_left(panel:left())
    self._tab_select_rect:set_bottom(self._button:bottom())
    self._tab_select_rect:set_left(self._button:left())
end

function XPBreakdownItem:SetPosByPreviousItem(item)
    self:SetPreviousItem(item)
    local button = item:GetButton()
    self._button:set_bottom(button:bottom())
    self._button:set_left(button:right() + 10)
    self._tab_select_rect:set_bottom(self._button:bottom())
    self._tab_select_rect:set_left(self._button:left())
end

function XPBreakdownItem:SetVisibleWithOffset(offset)
    self._button:set_y(self._button:y() + offset)
    self._button:set_visible(true)
    self._tab_select_rect:set_y(self._button:y())
end

function XPBreakdownItem:Select(no_change)
    if self._selected then
        return
    end
    self._button:set_color(tweak_data.screen_colors.button_stage_1)
    self._button:set_blend_mode("normal")
    self._tab_select_rect:show()
    self._selected = true
    if no_change then
        return
    end
    self._gui:OnTacticChanged(self:GetIndex(), self._previous_item:GetIndex())
end

function XPBreakdownItem:Unselect()
    if not self._selected then
        return
    end
    self._button:set_color(tweak_data.screen_colors.button_stage_3)
    self._button:set_blend_mode("add")
    self._tab_select_rect:hide()
    self._selected = false
end

function XPBreakdownItem:UnselectPreviousItem()
    self._previous_item:Unselect()
end

function XPBreakdownItem:mouse_moved(x, y)
    if not self._selected then
        if self._button:inside(x, y) then
            if not self._highlighted then
                self._highlighted = true
                self._button:set_color(tweak_data.screen_colors.button_stage_2)
                managers.menu_component:post_event("highlight")
            end
            return true
        elseif self._highlighted then
            self._button:set_color(tweak_data.screen_colors.button_stage_3)
            self._highlighted = false
        end
    end
    return false
end

function XPBreakdownItem:mouse_pressed(button, x, y)
    if button ~= Idstring("0") then
        return
    end
    if not self._selected and self._button and alive(self._button) and self._button:inside(x, y) then
        self:Select()
        self:UnselectPreviousItem()
    end
end

function XPBreakdownItem:destroy()
    self._panel:remove(self._button)
    self._panel:remove(self._tab_select_rect)
end

local reloading_outfit = false -- Fix for Beardlib stack overflow crash
local xp_format = EHI:GetOption("xp_format")
local diff_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", EHI:DifficultyIndex()) or 1

local original =
{
    init = MissionBriefingGui.init,
    set_slot_outfit = TeamLoadoutItem.set_slot_outfit,
    lobby_code_init = LobbyCodeMenuComponent.init
}

MissionBriefingGui.FormatTime = tweak_data.ehi.functions.ReturnMinutesAndSeconds
function MissionBriefingGui:init(...)
    original.init(self, ...)
    self._loc = managers.localization
    self._xp = managers.experience
    local w = self._fullscreen_panel:w() * 0.45
    self._ehi_panel = self._fullscreen_panel:panel({
        name = "ehi_panel",
        h = 100,
        layer = 9,
        w = w
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
    self._ehi_panel:set_top(75)
    self._ehi_panel:set_visible(false)
    self._ehi_panel_v2:set_visible(false)
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
            local alive_original = ex._ehi_xp.alive_players
            local skill_original = ex._ehi_xp.skill_xp_multiplier
            local gage_original = ex._ehi_xp.gage_bonus
            ex._ehi_xp.alive_players = self._num_winners or 1
            ex._ehi_xp.skill_xp_multiplier = self._skill_bonus or 1
            ex._ehi_xp.gage_bonus = self._gage_bonus or 1
            local value = ex:MultiplyXPWithAllBonuses(xp)
            ex._ehi_xp.alive_players = alive_original
            ex._ehi_xp.skill_xp_multiplier = skill_original
            ex._ehi_xp.gage_bonus = gage_original
            return value
        end
    end
    self:ProcessXPBreakdown()
end

function MissionBriefingGui:ProcessXPBreakdown()
    if _params then
        self:AddXPBreakdown(_params)
    elseif tweak_data.levels:IsLevelSkirmish() then
        -- Hardcoded in shared instance "obj_skm"
        ---@type XPBreakdown
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

---@param params XPBreakdown
function MissionBriefingGui:AddXPBreakdown(params)
    if type(params) ~= "table" or not next(params) then
        return
    end
    self:FakeExperienceMultipliers()
    if params.tactic then
        local tactic = params.tactic
        if self._panels then
            self:ProcessBreakDown(tactic.stealth, self._panels[1])
            self:ProcessBreakDown(tactic.loud, self._panels[2])
        else
            self._stealth_button = XPBreakdownItem:new(self, self._fullscreen_panel, "ehi_experience_stealth", "stealth", TacticSelected == 1)
            self._stealth_button:SetPosByPanel(self._ehi_panel)
            self._loud_button = XPBreakdownItem:new(self, self._fullscreen_panel, "ehi_experience_loud", "loud", TacticSelected == 2)
            self._loud_button:SetPosByPreviousItem(self._stealth_button)
            self._stealth_button:SetPreviousItem(self._loud_button)
            self._panels = {}
            -- Process stealth tactic first, loud at the end
            local panel = { panel = self._ehi_panel_v2, lines = 0 } -- Reuse the panel, memory efficiency
            self:ProcessBreakDown(tactic.stealth, panel)
            self._panels[1] = panel
            -- Loud
            self._ehi_panel:panel({
                name = "panel_v2",
                layer = 9,
            })
            local panel_v2 = { panel = self._ehi_panel:child("panel_v2"), lines = 0, adjust_h = true, selected = TacticSelected == 2 }
            self:ProcessBreakDown(tactic.loud, panel_v2)
            self._panels[2] = panel_v2
            local offset = Global.game_settings.single_player and 20 or 25
            self._stealth_button:SetVisibleWithOffset(offset)
            self._loud_button:SetVisibleWithOffset(offset)
            self._ehi_panel:set_y(self._ehi_panel:y() + offset)
            original.mouse_pressed = self.mouse_pressed
            self.mouse_pressed = function(gui, button, x, y, ...)
                local result = original.mouse_pressed(gui, button, x, y, ...)
                if result then
                    local fx, fy = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
                    gui._stealth_button:mouse_pressed(button, fx, fy)
                    gui._loud_button:mouse_pressed(button, fx, fy)
                end
                return result
            end
            original.mouse_moved = self.mouse_moved
            self.mouse_moved = function(gui, x, y, ...)
                if not alive(gui._panel) or not alive(gui._fullscreen_panel) or not gui._enabled then
                    return false, "arrow"
                end
                if gui._displaying_asset then
                    return false, "arrow"
                end
                if game_state_machine:current_state().blackscreen_started and game_state_machine:current_state():blackscreen_started() then
                    return false, "arrow"
                end
                local fx, fy = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
                if gui._stealth_button:mouse_moved(fx, fy) then
                    return true, "link"
                end
                if gui._loud_button:mouse_moved(fx, fy) then
                    return true, "link"
                end
                return original.mouse_moved(gui, x, y, ...)
            end
            original.close = self.close
            self.close = function(gui, ...)
                gui._stealth_button:destroy()
                gui._loud_button:destroy()
                original.close(gui, ...)
                -- Remove hooks; the gui will refresh or is closing
                gui.mouse_pressed = original.mouse_pressed
                gui.mouse_moved = original.mouse_moved
                original.mouse_pressed = nil
                original.mouse_moved = nil
            end
        end
    else
        self:ProcessBreakDown(params)
    end
    _params = params
end

---@param params XPBreakdown|_XPBreakdown
---@param panel table?
function MissionBriefingGui:ProcessBreakDown(params, panel)
    panel = panel or { panel = self._ehi_panel_v2, lines = 0, adjust_h = true }
    local gage = xp_format == 3 and EHI:AreGagePackagesSpawned()
    self:AddXPOverviewText(panel)
    if params.wave_all then
        local data = params.wave_all
        if type(data) == "table" then
            local xp_multiplied = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
            local total_xp = self._xp:cash_string(xp_multiplied, "+")
            self:AddXPText(panel, string.format("%s (%s): ", self._loc:text("ehi_experience_each_wave_survived"), self._loc:text("ehi_experience_trigger_times", { times = data.times })), total_xp)
            self:AddTotalXP(panel, self._xp:cash_string(xp_multiplied * data.times, "+"))
        else
            local total_xp = self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(data), "+")
            self:AddXPText(panel, string.format("%s: %s", self._loc:text("ehi_experience_each_wave_survived")), total_xp)
        end
    elseif params.wave then
        local total_xp = 0
        for wave, xp in ipairs(params.wave) do
            local xp_computed = self._xp:FakeMultiplyXPWithAllBonuses(xp)
            total_xp = total_xp + xp_computed
            self:AddXPText(panel, self._loc:text("ehi_experience_wave_survived", { wave = wave }), self._xp:cash_string(xp_computed, "+"))
        end
        self:AddTotalXP(panel, self._xp:cash_string(total_xp, "+"))
    elseif params.objective then
        local total_xp = { base = 0, add = not params.no_total_xp }
        for key, data in pairs(params.objective) do
            local str = self:GetTranslatedKey(key)
            if key == "escape" then
                self:ProcessEscape(panel, str, data, total_xp, gage)
            elseif key == "random" then
                self:ProcessRandomObjectives(panel, data, total_xp, gage)
            elseif type(data) == "table" then
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data.amount)
                end
                local text_color = data.optional and colors.optional
                if data.times then
                    local times_formatted = self._loc:text("ehi_experience_trigger_times", { times = data.times })
                    local s
                    if data.stealth then
                        total_xp.add = false
                        s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_stealth") .. ")"
                    elseif data.loud then
                        total_xp.add = false
                        s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_loud") .. ")"
                    else
                        s = str .. " (" .. times_formatted .. ")"
                        total_xp.base = total_xp.base + (data.amount * data.times)
                    end
                    self:AddXPText(panel, s .. ": ", xp, xp_with_gage, text_color)
                elseif data.stealth then
                    total_xp.add = false
                    self:AddXPText(panel, str .. " (" .. self._loc:text("ehi_experience_stealth") .. "): ", xp, xp_with_gage, text_color)
                elseif data.loud then
                    total_xp.add = false
                    self:AddXPText(panel, str .. " (" .. self._loc:text("ehi_experience_loud") .. "): ", xp, xp_with_gage, text_color)
                else
                    total_xp.base = total_xp.base + data
                    self:AddXPText(panel, str .. ": ", xp, xp_with_gage, text_color)
                end
            else
                total_xp.base = total_xp.base + data
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data)
                end
                self:AddXPText(panel, str .. ": ", xp, xp_with_gage)
            end
        end
        self:ProcessLoot(panel, params, total_xp, gage)
        self:ProcessTotalXP(panel, params, gage, total_xp)
    elseif params.objectives then
        local total_xp = { base = 0, add = not params.no_total_xp }
        for _, data in ipairs(params.objectives) do
            if type(data) == "table" then
                if type(data.stealth) == "number" and type(data.loud) == "number" then
                    total_xp.add = false
                    local str = data.name and self:GetTranslatedKey(data.name) or "<Unknown objective>"
                    if data.times then
                    else
                        local stealth_value = self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(data.stealth), "+")
                        local stealth_value_gage
                        if gage then
                            stealth_value_gage = self:FormatXPWithAllGagePackages(data.stealth)
                        end
                        self:AddXPText(panel, str .. " (" .. self._loc:text("ehi_experience_stealth") .. "): ", stealth_value, stealth_value_gage)
                        local loud_value = self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(data.loud), "+")
                        local loud_value_gage
                        if gage then
                            loud_value_gage = self:FormatXPWithAllGagePackages(data.loud)
                        end
                        self:AddXPText(panel, str .. " (" .. self._loc:text("ehi_experience_loud") .. "): ", loud_value, loud_value_gage)
                    end
                elseif data.escape then
                    self:ProcessEscape(panel, self:GetTranslatedKey("escape"), data.escape, total_xp, gage)
                elseif data.random then
                    self:ProcessRandomObjectives(panel, data.random, total_xp, gage)
                else
                    local amount = data.amount or 0
                    local value = self._xp:FakeMultiplyXPWithAllBonuses(amount)
                    local xp = self._xp:cash_string(value, "+")
                    local xp_with_gage
                    if gage then
                        xp_with_gage = self:FormatXPWithAllGagePackages(amount)
                    end
                    local str = data.name and self:GetTranslatedKey(data.name) or "<Unknown objective>"
                    local text_color = data.optional and colors.optional
                    if data.times then
                        local times_formatted = self._loc:text("ehi_experience_trigger_times", { times = data.times })
                        local s
                        if data.stealth then
                            total_xp.add = false
                            s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_stealth") .. ")"
                        elseif data.loud then
                            total_xp.add = false
                            s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_loud") .. ")"
                        else
                            s = str .. " (" .. times_formatted .. ")"
                            total_xp.base = total_xp.base + (amount * data.times)
                        end
                        self:AddXPText(panel, s .. ": ", xp, xp_with_gage, text_color)
                    elseif data.stealth then
                        total_xp.add = false
                        self:AddXPText(panel, str .. " (" .. self._loc:text("ehi_experience_stealth") .. "): ", xp, xp_with_gage, text_color)
                    elseif data.loud then
                        total_xp.add = false
                        self:AddXPText(panel, str .. " (" .. self._loc:text("ehi_experience_loud") .. "): ", xp, xp_with_gage, text_color)
                    else
                        total_xp.base = total_xp.base + amount
                        self:AddXPText(panel, str .. ": ", xp, xp_with_gage, text_color)
                    end
                end
            end
        end
        self:ProcessLoot(panel, params, total_xp, gage)
        self:ProcessTotalXP(panel, params, gage, total_xp)
    elseif params.loot or params.loot_all then
        local total_xp = { base = 0, add = not params.no_total_xp }
        self:ProcessLoot(panel, params, total_xp, gage)
        self:ProcessTotalXP(panel, params, gage, total_xp)
    else
        for key, _ in pairs(params) do
            EHI:Log("[MissionBriefingGui] Unknown key! " .. tostring(key))
        end
    end
    if panel.lines > 0 and panel.adjust_h then
        if self._panels then
            self._panels[1].h = self:GetPanelHeight(self._panels[1].lines)
            panel.h = self:GetPanelHeight(panel.lines)
            local visible_panel = panel.selected and panel or self._panels[1]
            local hidden_panel = panel.selected and self._panels[1] or panel
            self._ehi_panel:set_h(visible_panel.h)
            self._ehi_panel:set_visible(true)
            visible_panel.panel:set_h(visible_panel.h)
            visible_panel.panel:set_visible(true)
            hidden_panel.panel:set_h(hidden_panel.h)
            hidden_panel.panel:set_visible(false)
        else
            local h = self:GetPanelHeight(panel.lines)
            self._ehi_panel:set_h(h)
            self._ehi_panel:set_visible(true)
            panel.panel:set_h(h)
            panel.panel:set_visible(true)
        end
    end
end

function MissionBriefingGui:GetPanelHeight(lines)
    return 10 + (lines * 22)
end

function MissionBriefingGui:ProcessTotalXP(panel, params, gage, total_xp)
    if params.total_xp_override then
        local override = params.total_xp_override
        local override_objective = override.objective or {}
        local override_objectives = override.objectives or {}
        local override_loot = override.loot or {}
        local o_params = override.params
        if o_params then
            if o_params.custom then
                self:ParamsCustom(panel, params, o_params.custom)
            elseif o_params.min_max then
                self:ParamsMinMax(panel, params, o_params.min_max)
            elseif o_params.min then
                self:ParamsMinWithMax(panel, params, o_params, override)
            elseif o_params.max_only then
                self:ParamsMaxOnly(panel, params, o_params.max_only)
            end
        else
            local base = 0
            for key, data in pairs(params.objective or {}) do
                if override_objective[key] then
                    local o_override = override_objective[key]
                    local times = o_override.times or 1
                    if type(data) == "table" then
                        base = base + (data.amount * times)
                    else
                        base = base + (data * times)
                    end
                elseif type(data) == "table" then
                elseif type(data) == "number" then
                    base = base + data
                end
            end
            for _, data in ipairs(params.objectives or {}) do
                if override_objectives[data.name or "unknown"] then
                    local o_override = override_objectives[data.name or "unknown"]
                    local times = o_override.times or 1
                    base = base + ((data.amount or 0) * times)
                elseif data.escape then
                    if type(data.escape) == "number" then
                        base = base + data.escape
                    else
                        EHI:Log("[MissionBriefingGui] Unknown type for escape!")
                    end
                else
                    base = base + (data.amount or 0)
                end
            end
            for key, data in pairs(params.loot or {}) do
                if override_loot[key] then
                    local o_override = override_loot[key]
                    local times = o_override.times or 1
                    if type(data) == "table" then
                        base = base + (data.amount * times)
                    else
                        base = base + (data * times)
                    end
                elseif type(data) == "table" then
                elseif type(data) == "number" then
                    base = base + data
                end
            end
            local value = self._xp:FakeMultiplyXPWithAllBonuses(base)
            local xp = self._xp:cash_string(value, "+")
            local xp_with_gage
            if gage then
                xp_with_gage = self:FormatXPWithAllGagePackages(base)
            end
            self:AddTotalXP(panel, xp, xp_with_gage)
        end
    elseif total_xp.add and total_xp.base > 0 then
        local total = self._xp:FakeMultiplyXPWithAllBonuses(total_xp.base)
        local xp_with_gage
        if gage then
            xp_with_gage = self:FormatXPWithAllGagePackages(total_xp.base)
        end
        self:AddTotalXP(panel, self._xp:cash_string(total, "+"), xp_with_gage)
    end
end

function MissionBriefingGui:ParamsCustom(panel, params, o_params)
    for _, c_params in ipairs(o_params) do
        if c_params.type == "min_max" then
            self:ParamsMinMax(panel, params, c_params)
        elseif c_params.type == "min_with_max" then
            self:ParamsMinWithMax(panel, params, c_params, params.total_xp_override)
        elseif c_params.type == "max_only" then
        else
            EHI:Log("Custom type not recognized! " .. tostring(c_params.type))
        end
    end
end

function MissionBriefingGui:ParamsMinMax(panel, params, o_params)
    local min, max = 0, 0
    if o_params.objective then
        local o_min, o_max = {}, {}
        for key, value in pairs(o_params.objective or {}) do
            if value.min_max then
                local times = { times = value.min_max }
                o_min[key] = times
                o_max[key] = times
            else
                if value.min then
                    o_min[key] = { times = value.min }
                end
                if value.max then
                    o_max[key] = { times = value.max }
                end
            end
        end
        min = self:SumObjective(params.objective, o_min, true)
        max = self:SumObjective(params.objective, o_max)
    else
        min = self:SumObjective(params.objective, {}, true)
        max = self:SumObjective(params.objective, {})
    end
    if o_params.objectives then
        local o_min, o_max = {}, {}
        for key, value in pairs(o_params.objectives or {}) do
            if value.min_max then
                local times = { times = value.min_max }
                o_min[key] = times
                o_max[key] = times
            else
                if value.min then
                    o_min[key] = { times = value.min }
                end
                if value.max then
                    o_max[key] = { times = value.max }
                end
            end
        end
        min = min + self:SumObjectives(params.objectives, o_min, true)
        max = max + self:SumObjectives(params.objectives, o_max)
    else
        min = min + self:SumObjectives(params.objectives, {}, true)
        max = max + self:SumObjectives(params.objectives, {})
    end
    for key, data in pairs(o_params.loot or {}) do
        local loot = params.loot and params.loot[key]
        if loot then
            local amount = 0
            if type(loot) == "table" then
                amount = loot.amount
            elseif type(loot) == "number" then
                amount = loot
            end
            min = min + (amount * (data.min_max or data.min or 0))
            max = max + (amount * (data.min_max or data.max or 0))
        end
    end
    if o_params.loot_all then
        local data = o_params.loot_all
        local amount = 0
        if type(params.loot_all) == "table" then
            amount = params.loot_all.amount
        elseif type(params.loot_all) == "number" then
            amount = params.loot_all
        end
        min = min + (amount * (data.min_max or data.min or 0))
        max = max + (amount * (data.min_max or data.max or 0))
    end
    self:AddTotalMinMaxXP(panel, min, max, true, o_params.name)
end

---@param panel Panel
---@param params table
---@param o_params table
---@param override table
function MissionBriefingGui:ParamsMinWithMax(panel, params, o_params, override)
    local override_objective = override.objective or {}
    local override_objectives = override.objectives or {}
    --local override_loot = override.loot or {}
    local min = 0
    local max
    local format_max = true
    if o_params.min.objective then
        if type(o_params.min.objective) == "table" then
            for key, value in pairs(o_params.min.objective) do
                local actual_value = 0
                local objective = params.objective[key]
                if type(objective) == "table" then
                    actual_value = objective.amount
                elseif type(objective) == "number" then
                    actual_value = objective
                end
                if type(value) == "table" then
                    min = min + (actual_value * (value.times or 1))
                elseif override_objective[key] then
                    min = min + (actual_value * (override_objective[key].times or 1))
                else
                    min = min + actual_value
                end
            end
        else
            min = min + self:SumObjective(params.objective, override_objective, true)
        end
    end
    if o_params.min.objectives then
        if type(o_params.min.objectives) == "table" then
            local objectives = o_params.min.objectives
            for _, data in ipairs(params.objectives or {}) do
                local key = data.name or "unknown"
                if objectives[key] or (data.escape and objectives.escape) or (data.random and objectives.random) then -- Count this objective
                    local actual_value = data.amount or 0
                    if data.escape then
                        if type(data.escape) == "number" then
                            min = min + data.escape
                        else
                            EHI:Log("[MissionBriefingGui] Unknown type for escape!")
                        end
                    elseif data.random then
                        for random, _ in pairs(objectives.random) do
                            local r_data = data.random[random]
                            if r_data and random ~= "max" then
                                if type(r_data) == "table" then
                                    for _, ro_data in ipairs(r_data) do
                                        min = min + (ro_data.amount * (ro_data.times or 1))
                                    end
                                else -- Number
                                    min = min + r_data
                                end
                            end
                        end
                    elseif type(objectives[key]) == "table" then
                        min = min + (actual_value * (objectives[key].times or 1))
                    elseif override_objectives[key] then
                        min = min + (actual_value * (override_objectives[key].times or 1))
                    else
                        min = min + actual_value
                    end
                end
            end
        else
            min = min + self:SumObjectives(params.objectives, override_objectives, true)
        end
    end
    if o_params.min.loot then
        for key, value in pairs(o_params.min.loot) do
            local loot = params.loot and params.loot[key]
            local times = type(value) == "table" and (value.times or 1) or 1
            local amount = 0
            if type(loot) == "table" then
                amount = loot.amount
                times = times ~= 1 and (loot.times or 1) or times
            elseif type(loot) == "number" then
                amount = loot
            end
            min = min + (amount * times)
        end
    elseif o_params.min.loot_all then
        local times = o_params.min.loot_all.times or 1
        if type(params.loot_all) == "table" then
            min = min + (params.loot_all.amount * times)
        elseif type(params.loot_all) == "number" then
            min = min + (params.loot_all * times)
        end
    end
    min = min + (o_params.min.bonus_xp or 0)
    if o_params.max then
        max = 0
        if o_params.max.objective then
            if type(o_params.max.objective) == "table" then
                for key, _ in pairs(o_params.max.objective) do
                    local actual_value = 0
                    local objective = params.objective[key]
                    if type(objective) == "table" then
                        actual_value = objective.amount
                    elseif type(objective) == "number" then
                        actual_value = objective
                    end
                    if override_objective[key] then
                        max = max + (actual_value * (override_objective[key].times or 1))
                    else
                        max = max + actual_value
                    end
                end
            else
                max = max + self:SumObjective(params.objective, override_objective)
            end
        end
        if o_params.max.objectives then
            if type(o_params.max.objectives) == "table" then
                local objectives = o_params.max.objectives
                for _, data in pairs(params.objectives or {}) do
                    local key = data.name or "unknown"
                    if objectives[key] or (data.escape and objectives.escape) or (data.random and objectives.random) then
                        local actual_value = data.amount or 0
                        if data.escape then
                            if type(data.escape) == "number" then
                                max = max + data.escape
                            else
                                EHI:Log("[MissionBriefingGui] Unknown type for escape!")
                            end
                        elseif data.random then
                            for random, random_data in pairs(objectives.random) do
                                local r_data = data.random[random]
                                if r_data and random ~= "max" then
                                    if type(random_data) == "table" and type(r_data) == "table" then
                                        if #random_data == #r_data then
                                            for i = 1, #random_data, 1 do
                                                local r = r_data[i]
                                                if type(random_data[i]) == "table" then
                                                    max = max + (r.amount * (random_data[i].times or r.times or 1))
                                                else -- Assume "true" value
                                                    max = max + (r.amount * (r.times or 1))
                                                end
                                            end
                                        else
                                            EHI:Log("Table length does not match for random objective '" .. tostring(random) .. "'; skipping")
                                        end
                                    elseif type(r_data) == "table" then -- Assume "true" value -> compute
                                        for _, ro_data in ipairs(r_data) do
                                            max = max + (ro_data.amount * (ro_data.times or 1))
                                        end
                                    else -- Number
                                        max = max + r_data
                                    end
                                end
                            end
                        elseif type(objectives[key]) == "table" then
                            max = max + (actual_value * (objectives[key].times or 1))
                        elseif override_objectives[key] then
                            max = max + (actual_value * (override_objectives[key].times or 1))
                        else
                            max = max + actual_value
                        end
                    end
                end
            else
                max = max + self:SumObjectives(params.objectives, override_objectives)
            end
        end
        if o_params.max.loot then
            for key, value in pairs(o_params.max.loot) do
                local loot = params.loot and params.loot[key]
                local times = type(value) == "table" and (value.times or 1) or 1
                local amount = 0
                if type(loot) == "table" then
                    amount = loot.amount
                    times = times ~= 1 and (loot.times or 1) or times
                elseif type(loot) == "number" then
                    amount = loot
                end
                max = max + (amount * times)
            end
        elseif o_params.max.loot_all then
            local times = o_params.max.loot_all.times or 1
            if type(params.loot_all) == "table" then
                max = max + (params.loot_all.amount * times)
            elseif type(params.loot_all) == "number" then
                max = max + (params.loot_all * times)
            end
        end
        max = max + (o_params.max.bonus_xp or 0)
    elseif o_params.max_level then
        format_max = false
        local max_n = 0
        if self._xp:reached_level_cap() then -- Level is maxed, show Infamy Pool instead
            max_n = self._xp:GetRemainingPrestigeXP()
            max = self._xp:experience_string(max_n)
        else -- Show remaining XP up to level 100
            max_n = self._xp:GetRemainingXPToMaxLevel()
            max = self._xp:experience_string(max_n)
        end
        local xp = self._loc:text("ehi_experience_xp")
        if o_params.max_level_bags then
            if false then --self._xp:FakeMultiplyXPWithAllBonuses(min) > max_n then

            else
                local loot_xp = self._xp:FakeMultiplyXPWithAllBonuses(params.loot_all)
                local loot_xp_gage = gage and self:FormatXPWithAllGagePackagesNoString(params.loot_all) or loot_xp
                local bags_to_secure = math.ceil(max_n / loot_xp)
                local bags_to_secure_gage = math.ceil(max_n / loot_xp_gage)
                local to_secure = self._loc:text("ehi_experience_to_secure", { amount = bags_to_secure })
                if bags_to_secure == bags_to_secure_gage then -- Securing gage packages does not matter -> you still need to secure the same amount of bags
                    max = string.format("+%s %s (%s)", max, xp, to_secure)
                else -- Securing gage packages will make a difference in bags, reflect it
                    max = string.format("+%s %s (%s; %s %s)", max, xp, to_secure, self._loc:text("ehi_experience_all_gage_packages"), tostring(bags_to_secure_gage))
                end
            end
        else
            max = "+" .. max .. " " .. xp
        end
    elseif not o_params.no_max then -- Max is missing, is not set to Player level max or is not disabled, assume all objectives to compute
        max = 0
        for key, data in pairs(params.objective or {}) do
            local times = 1
            if override_objective[key] then
                times = override_objective[key].times or 1
            end
            if type(data) == "table" then
                max = max + (data.amount * times)
            elseif type(data) == "number" then
                max = max + (data * times)
            end
        end
        for _, data in ipairs(params.objectives or {}) do
            if data.escape then
                if type(data.escape) == "number" then
                    max = max + data.escape
                else
                    EHI:Log("[MissionBriefingGui] Unknown type for escape!")
                end
            else
                local key = data.name or "unknown"
                local times = 1
                if override_objectives[key] then
                    times = override_objectives[key].times or 1
                end
                max = max + ((data.amount or 0) * times)
            end
        end
    end
    self:AddTotalMinMaxXP(panel, min, max, format_max, o_params.name)
end

function MissionBriefingGui:ParamsMaxOnly(panel, params, o_params)
    local o_max = o_params.max or {}
    local max = 0
    if type(params.objective) == "table" then
        max = self:SumObjective(params.objective, o_max)
    end
    if type(params.objectives) == "table" then
        for _, data in ipairs(params.objectives or {}) do
            local key = data.name or "unknown"
            local actual_value = data.amount or 0
            if data.escape then
                if type(data.escape) == "number" then
                    actual_value = data.escape
                else
                    EHI:Log("[MissionBriefingGui] Unknown type for escape!")
                end
            end
            if o_max[key] then
                max = max + (actual_value * (o_max[key].times or data.times or 1))
            else
                max = max + (actual_value * (data.times or 1))
            end
        end
    else
        max = max + self:SumObjectives(params.objectives, o_max)
    end
    for key, data in pairs(o_params.loot or {}) do
        local loot = params.loot and params.loot[key]
        if loot then
            local amount = 0
            if type(loot) == "table" then
                amount = loot.amount
            elseif type(loot) == "number" then
                amount = loot
            end
            max = max + (amount * (data.min_max or data.max or 0))
        end
    end
    if o_params.loot_all then
        local data = o_params.loot_all
        local amount = 0
        if type(params.loot_all) == "table" then
            amount = params.loot_all.amount
        elseif type(params.loot_all) == "number" then
            amount = params.loot_all
        end
        max = max + (amount * (data.min_max or data.max or 0))
    end
    self:AddLine(panel, ("Max (" .. o_params.name .. "): +") .. self:FormatXPWithAllGagePackages(max) .. " " .. self._loc:text("ehi_experience_xp"), Color.green)
end

function MissionBriefingGui:AddXPText(panel, txt, value, value_with_gage, text_color)
    local xp = self._loc:text("ehi_experience_xp")
    local text
    if value_with_gage then
        text = string.format("%s%s-%s %s", txt, value, value_with_gage, xp)
    else
        text = string.format("%s%s %s", txt, value, xp)
    end
    panel.panel:text({
        name = tostring(panel.lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (panel.lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = text_color or Color.white,
        text = text,
        layer = 10
    })
    panel.lines = panel.lines + 1
end

function MissionBriefingGui:AddXPOverviewText(panel)
    panel.panel:text({
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
    panel.lines = panel.lines + 1
end

function MissionBriefingGui:AddTotalXP(panel, total, total_with_gage)
    local xp = self._loc:text("ehi_experience_xp")
    local txt
    if total_with_gage then
        txt = string.format("%s%s-%s %s", self._loc:text("ehi_experience_total_xp"), total, total_with_gage, xp)
    elseif total then
        txt = string.format("%s%s %s", self._loc:text("ehi_experience_total_xp"), total, xp)
    else
        txt = self._loc:text("ehi_experience_total_xp")
    end
    panel.panel:text({
        name = tostring(panel.lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (panel.lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = colors.total_xp,
        text = txt,
        layer = 10
    })
    panel.lines = panel.lines + 1
end

---@param panel Panel
---@param min number
---@param max number|string?
---@param format_max boolean
---@param post_fix string?
function MissionBriefingGui:AddTotalMinMaxXP(panel, min, max, format_max, post_fix)
    local post_fix_text = post_fix and self._loc:text("ehi_experience_" .. post_fix) or ""
    local xp = self._loc:text("ehi_experience_xp")
    if not post_fix then
        self:AddTotalXP(panel)
    end
    self:AddLine(panel, (post_fix and ("Min (" .. post_fix_text .. "): ") or "Min: ") .. self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(min), "+") .. " " .. xp, Color.green)
    if max then
        if format_max then
            self:AddLine(panel, (post_fix and ("Max (" .. post_fix_text .. "): +") or "Max: +") .. self:FormatXPWithAllGagePackages(max or 0 --[[@as number]]) .. " " .. xp, Color.green)
        else
            self:AddLine(panel, (post_fix and ("Max (" .. post_fix_text .. "): ") or "Max: ") .. tostring(max), Color.green)
        end
    end
end

function MissionBriefingGui:AddLootSecuredHeader(panel)
    panel.panel:text({
        name = tostring(panel.lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (panel.lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = colors.loot_secured,
        text = self._loc:text("ehi_experience_loot_secured"),
        layer = 10
    })
    panel.lines = panel.lines + 1
end

function MissionBriefingGui:AddLootSecured(panel, loot, times, to_secure, value, value_with_gage)
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
    local xp = self._loc:text("ehi_experience_xp")
    if value_with_gage then
        str = str .. ": " .. tostring(value) .. "-" .. tostring(value_with_gage) .. " " .. xp
    else
        str = str .. ": " .. tostring(value) .. " " .. xp
    end
    panel.panel:text({
        name = tostring(panel.lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (panel.lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = colors.loot_secured,
        text = str,
        layer = 10
    })
    panel.lines = panel.lines + 1
end

function MissionBriefingGui:AddRandomObjectivesHeader(panel, max)
    local text = max and self._loc:text("ehi_experience_random_objectives", { count = max }) or self._loc:text("ehi_experience_random_objectives_no_count")
    panel.panel:text({
        name = tostring(panel.lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (panel.lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        text = text,
        layer = 10
    })
    panel.lines = panel.lines + 1
end

function MissionBriefingGui:AddLine(panel, txt, txt_color)
    panel.panel:text({
        name = tostring(panel.lines),
        blend_mode = "add",
        x = 10,
        y = 10 + (panel.lines * 22),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = txt_color or Color.white,
        text = txt,
        layer = 10
    })
    panel.lines = panel.lines + 1
end

function MissionBriefingGui:FakeExperienceMultipliers()
    if EHI:IsRunningBB() or EHI:IsRunningUsefulBots() then
        self._num_winners = 4
    end
    if Global.block_update_outfit_information then -- Outfit update is late when "managers.player:get_skill_exp_multiplier(true)" is called, update it now to stay accurate
        local outfit_string = managers.blackmarket:outfit_string()
        local local_peer = managers.network:session():local_peer()
        reloading_outfit = true
        local_peer:set_outfit_string(outfit_string)
        reloading_outfit = false
    end
    self._skill_bonus = managers.player:get_skill_exp_multiplier(true)
end

---@param base_xp number
---@return number
function MissionBriefingGui:FormatXPWithAllGagePackagesNoString(base_xp)
    self._gage_bonus = 1.05
    local value = self._xp:FakeMultiplyXPWithAllBonuses(base_xp)
    self._gage_bonus = 1
    return value
end

---@param base_xp number
---@return string
function MissionBriefingGui:FormatXPWithAllGagePackages(base_xp)
    return self._xp:cash_string(self:FormatXPWithAllGagePackagesNoString(base_xp), "")
end

function MissionBriefingGui:RefreshXPOverview()
    self._num_winners = managers.network:session() and managers.network:session():amount_of_players() or 1
    if self._panels then
        for _, panel in ipairs(self._panels) do
            panel.panel:clear()
            panel.lines = 0
        end
    else
        self._ehi_panel_v2:clear()
    end
    self:ProcessXPBreakdown()
end

---@param key string
---@return string
function MissionBriefingGui:GetTranslatedKey(key)
    local string_id = "ehi_experience_" .. key
    if self._loc:exists(string_id) then
        return self._loc:text(string_id)
    end
    return key
end

---@param panel Panel
---@param params table
---@param total_xp table
---@param gage boolean?
function MissionBriefingGui:ProcessLoot(panel, params, total_xp, gage)
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
            if data.text then
                secured_bag = self._loc:text("ehi_experience_" .. data.text)
            end
            if data.times then
                self:AddXPText(panel, string.format("%s (%s): ", secured_bag, self._loc:text("ehi_experience_trigger_times", { times = data.times })), xp, xp_with_gage, colors.loot_secured)
            else
                self:AddXPText(panel, string.format("%s: ", secured_bag), xp, xp_with_gage, colors.loot_secured)
            end
            if total_xp.add and not data.times then
                total_xp.add = false
            end
            total_xp.base = total_xp.base + data.amount
        else
            local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
            local xp = self._xp:cash_string(value, "+")
            local xp_with_gage
            if gage then
                xp_with_gage = self:FormatXPWithAllGagePackages(data)
            end
            self:AddXPText(panel, string.format("%s: ", secured_bag), xp, xp_with_gage, colors.loot_secured)
            total_xp.add = false
        end
    elseif params.loot then
        self:AddLootSecuredHeader(panel)
        for loot, data in pairs(params.loot) do
            if type(data) == "table" then
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data.amount)
                end
                self:AddLootSecured(panel, loot, data.times or 0, data.to_secure or 0, xp, xp_with_gage)
                if total_xp.add and not data.times then
                    total_xp.add = false
                end
                total_xp.base = total_xp.base + data.amount
            else
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data)
                end
                self:AddLootSecured(panel, loot, 0, 0, xp, xp_with_gage)
                total_xp.add = false
            end
        end
    end
end

---@param panel Panel
---@param str string
---@param params table|number
---@param total_xp table
---@param gage boolean?
function MissionBriefingGui:ProcessEscape(panel, str, params, total_xp, gage)
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
                    s = s .. " (<" .. self:FormatTime(value.timer) .. ")"
                end
                s = s .. ": "
            else
                s = self._loc:text("ehi_experience_loud_escape")
                if value.c4_used then
                    s = s .. " (" .. self._loc:text("ehi_experience_c4_used") .. ")"
                end
                s = s .. ": "
            end
            self:AddXPText(panel, s, xp, xp_with_gage)
        end
        if next(params) then
            total_xp.add = false
        end
    elseif type(params) == "number" then
        local value = self._xp:FakeMultiplyXPWithAllBonuses(params)
        local xp = self._xp:cash_string(value, "+")
        local xp_with_gage
        if gage then
            xp_with_gage = self:FormatXPWithAllGagePackages(params)
        end
        self:AddXPText(panel, str .. ": ", xp, xp_with_gage)
        total_xp.base = total_xp.base + params
    end
end

---@param panel Panel
---@param random table
---@param total_xp table
---@param gage boolean?
function MissionBriefingGui:ProcessRandomObjectives(panel, random, total_xp, gage)
    if type(random) ~= "table" then
        return
    end
    total_xp.add = false
    self:AddRandomObjectivesHeader(panel, random.max)
    local c1 = Color("bfdd7d") -- Dark green
    local c2 = Color.yellow
    local final_color = c2
    local color_pos = 2
    for obj, data in pairs(random) do
        if obj ~= "max" then
            if color_pos == 1 then
                color_pos = 2
                final_color = c2
            else
                color_pos = 1
                final_color = c1
            end
            if type(data) == "table" then
                for _, xp in ipairs(data) do
                    local str = "- " .. self:GetTranslatedKey(xp.name)
                    local value = self._xp:FakeMultiplyXPWithAllBonuses(xp.amount)
                    local _xp = self._xp:cash_string(value, "+")
                    local xp_with_gage
                    if gage then
                        xp_with_gage = self:FormatXPWithAllGagePackages(xp.amount)
                    end
                    if data.times then
                        self:AddXPText(panel, str .. " (" .. tostring(data.times) .. "): ", _xp, xp_with_gage, final_color)
                    else
                        self:AddXPText(panel, str .. ": ", _xp, xp_with_gage, final_color)
                    end
                end
            else
                local str = "- " .. self:GetTranslatedKey(obj)
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
                local _xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if gage then
                    xp_with_gage = self:FormatXPWithAllGagePackages(data)
                end
                self:AddXPText(panel, str .. ": ", _xp, xp_with_gage, final_color)
            end
        end
    end
end

---@param objective table?
---@param override_objective table
---@param skip_optional boolean?
---@return number
function MissionBriefingGui:SumObjective(objective, override_objective, skip_optional)
    local xp = 0
    for key, obj in pairs(objective or {}) do
        local actual_value = 0
        local times = 1
        local count = true
        local override = override_objective[key]
        if type(obj) == "table" then
            actual_value = obj.amount
            times = obj.times or 1
            count = not obj.optional or (obj.optional and not skip_optional)
        elseif type(obj) == "number" then
            actual_value = obj
        end
        if count then
            if override then
                xp = xp + (actual_value * (override.times or times or 1))
            else
                xp = xp + (actual_value * (times or 1))
            end
        end
    end
    return xp
end

---@param objectives table?
---@param override_objectives table
---@param skip_optional boolean?
---@return number
function MissionBriefingGui:SumObjectives(objectives, override_objectives, skip_optional)
    local xp = 0
    for _, data in ipairs(objectives or {}) do
        if data.escape then
            if type(data.escape) == "number" then
                xp = xp + data.escape
            else
                EHI:Log("[MissionBriefingGui] Unknown type for escape!")
            end
        elseif data.random then
            EHI:Log("[MissionBriefingGui] Random objectives cannot be counted! Use min or max and count them manually")
        elseif not data.optional or (data.optional and not skip_optional) then
            local key = data.name or "unknown"
            local amount = data.amount or 0
            local o_override = override_objectives[key] or {}
            xp = xp + (amount * (o_override.times or data.times or 1))
        end
    end
    return xp
end

function MissionBriefingGui:OnTacticChanged(index, previous_index)
    local panel = self._panels[index]
    panel.panel:set_visible(true)
    self._ehi_panel:set_h(panel.h)
    self._panels[previous_index].panel:set_visible(false)
    TacticSelected = index
end

function TeamLoadoutItem:set_slot_outfit(slot, ...)
    original.set_slot_outfit(self, slot, ...)
    local player_slot = slot and self._player_slots[slot]
    if not player_slot or reloading_outfit then
        return
    end
    local mcm = managers.menu_component
    if mcm and mcm._mission_briefing_gui then
        mcm._mission_briefing_gui:RefreshXPOverview()
    end
end

function LobbyCodeMenuComponent:init(...)
    original.lobby_code_init(self, ...)
    if self._panel:alpha() ~= 0 then
        self._panel:set_y(0)
        if managers.hud._hud_mission_briefing and managers.hud._hud_mission_briefing.MoveJobName then
            managers.hud._hud_mission_briefing:MoveJobName()
        end
    end
end