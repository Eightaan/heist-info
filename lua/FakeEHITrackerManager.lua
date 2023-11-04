local EHI = EHI
local Icon = EHI.Icons
local panel_size_original = 32
local panel_offset_original = 6
local panel_size = panel_size_original
local panel_offset = panel_offset_original
---@class FakeEHITrackerManager
---@field new fun(self: self, panel: Panel): self
FakeEHITrackerManager = class()
FakeEHITrackerManager.make_fine_text = BlackMarketGui.make_fine_text
---@param panel Panel
function FakeEHITrackerManager:init(panel)
    self._hud_panel = panel:panel({
        name = "fake_ehi_panel",
        --layer = -10,
        alpha = 1
    })
    if EHI:IsVR() then
        self._scale = EHI:GetOption("vr_scale")
        local x, y = managers.gui_data:safe_to_full(EHI:GetOption("vr_x_offset"), EHI:GetOption("vr_y_offset"))
        self._x = x
        self._y = y
    else
        self._scale = EHI:GetOption("scale")
        local x, y = managers.gui_data:safe_to_full(EHI:GetOption("x_offset"), EHI:GetOption("y_offset"))
        self._x = x
        self._y = y
    end
    self._text_scale = EHI:GetOption("text_scale")
    self._bg_visibility = EHI:GetOption("show_tracker_bg")
    self._corner_visibility = EHI:GetOption("show_tracker_corners")
    self._icons_visibility = EHI:GetOption("show_one_icon")
    self._tracker_alignment = EHI:GetOption("tracker_alignment")
    panel_size = panel_size_original * self._scale
    panel_offset = panel_offset_original * self._scale
    self._horizontal = {
        x = self._x,
        y = self._y,
        x_offset = 0
    }
    self._vertical = {
        x = self._x,
        y = self._y,
        y_offset = 0,
        max_icons = 4
    }
    self:AddFakeTrackers()
end

function FakeEHITrackerManager:AddFakeTrackers()
    self._n_of_trackers = 0
    self._fake_trackers = {} ---@type table<number, FakeEHITracker?>
    self:AddFakeTracker({ id = "show_mission_trackers", time = math.rand(0.5, 9.99), icons = { Icon.Wait } })
    self:AddFakeTracker({ id = "show_mission_trackers", time = math.random(60, 180), icons = { Icon.Car, Icon.Escape } })
    self:AddFakeTracker({ id = "show_unlockables", time = math.random(60, 180), icons = { Icon.Trophy } })
    do
        local xp_panel = EHI:GetOption("xp_panel")
        if xp_panel <= 2 then
            self:AddFakeTracker({ id = "show_gained_xp", icons = { "xp" }, extend_half = xp_panel == 2, class = "FakeEHIXPTracker" })
        end
    end
    self:AddFakeTracker({ id = "show_trade_delay", time = 5 + (math.random(1, 4) * 30), icons = { { icon = "mugshot_in_custody", color = self:GetPeerColor() } } })
    self:AddFakeTracker({ id = "show_timers", time = math.random(60, 240), icons = { Icon.Drill, Icon.Wait, "silent", Icon.Loop } })
    self:AddFakeTracker({ id = "show_timers", time = math.random(60, 120), icons = { Icon.PCHack } })
    self:AddFakeTracker({ id = "show_timers", time = math.random(60, 120), icons = { Icon.PCHack }, extend = true, class = "FakeEHITimerTracker" })
    self:AddFakeTracker({ id = "show_camera_loop", time = math.random(10, 25), icons = { "camera_loop" } })
    self:AddFakeTracker({ id = "show_enemy_turret_trackers", time = math.random(10, 30), icons = { Icon.Turret, "reload" } })
    self:AddFakeTracker({ id = "show_enemy_turret_trackers", time = math.random(10, 30), icons = { Icon.Turret, Icon.Fix } })
    do
        local time = math.rand(1, 8)
        self:AddFakeTracker({ id = "show_zipline_timer", time = time, icons = { "zipline_bag" } })
        self:AddFakeTracker({ id = "show_zipline_timer", time = time * 2, icons = { "zipline", Icon.Loop } })
    end
    if EHI:GetOption("gage_tracker_panel") == 1 then
        self:AddFakeTracker({ id = "show_gage_tracker", icons = { "gage" }, class = "FakeEHIProgressTracker" })
    end
    self:AddFakeTracker({ id = "show_captain_damage_reduction", icons = { "buff_shield" }, class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_equipment_tracker", show_placed = true, icons = { "doctor_bag" }, class = "FakeEHIEquipmentTracker" })
    self:AddFakeTracker({ id = "show_minion_tracker", min = 1, charges = 4, icons = { "minion" }, class = "FakeEHIMinionCounterTracker" })
    self:AddFakeTracker({ id = "show_difficulty_tracker", icons = { "enemy" }, class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_drama_tracker", chance = math.random(100), icons = { "C_Escape_H_Street_Bullet" }, class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_pager_tracker", progress = 3, max = 4, icons = { Icon.Pager }, class = "FakeEHIProgressTracker" })
    self:AddFakeTracker({ id = "show_pager_callback", time = math.rand(0.5, 12), icons = { "pager_icon" } })
    self:AddFakeTracker({ id = "show_enemy_count_tracker", count = math.random(20, 80), icons = { "pager_icon", { icon = "enemy", visible = false } }, class = "FakeEHIEnemyCountTracker" })
    self:AddFakeTracker({ id = "show_civilian_count_tracker", count = math.random(1, 10), icons = { "civilians" }, class = "FakeEHICountTracker" })
    self:AddFakeTracker({ id = "show_laser_tracker", time = math.rand(0.5, 4), icons = { EHI.Icons.Lasers } })
    if EHI:CombineAssaultDelayAndAssaultTime() then
        self:AddFakeTracker({ id = "aggregate_assault_delay_and_assault_time", time = math.random(0, 240), icons = { "assaultbox" }, class = "FakeEHIAssaultTimeTracker" })
    else
        self:AddFakeTracker({ id = "show_assault_delay_tracker", time = math.random(30, 120), icons = { "assaultbox" } })
        self:AddFakeTracker({ id = "show_assault_time_tracker", time = math.random(0, 240), icons = { "assaultbox" }, class = "FakeEHIAssaultTimeTracker" })
    end
    self:AddFakeTracker({ id = "show_loot_counter", icons = { Icon.Loot }, class = "FakeEHIProgressTracker" })
    self:AddFakeTracker({ id = "show_bodybags_counter", count = math.random(1, 3), icons = { "equipment_body_bag" }, class = "FakeEHICountTracker" })
    self:AddFakeTracker({ id = "show_escape_chance", icons = { { icon = Icon.Car, color = Color.red } }, chance = math.random(100), class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_sniper_tracker", icons = { "sniper" }, class = "FakeEHISniperTracker" })
    self:AddPreviewText()
end

function FakeEHITrackerManager:AddFakeTracker(params)
    if not EHI:GetOption(params.id) then
        return
    end
    if self._n_of_trackers == 0 then
        self:CreateFirstFakeTracker(params)
    else
        self:CreateFakeTracker(params)
    end
end

function FakeEHITrackerManager:CreateFakeTracker(params)
    params.x, params.y = self:GetPos(self._n_of_trackers)
    params.scale = self._scale
    params.text_scale = self._text_scale
    params.bg = self._bg_visibility
    params.corners = self._corner_visibility
    params.one_icon = self._icons_visibility
    params.parent_class = self
    self._n_of_trackers = self._n_of_trackers + 1
    self._fake_trackers[self._n_of_trackers] = _G[params.class or "FakeEHITracker"]:new(self._hud_panel, params)
end

function FakeEHITrackerManager:CreateFirstFakeTracker(params)
    params.first = true
    self:CreateFakeTracker(params)
    self._fake_trackers[1]._bg_box:child("left_top"):set_color(Color.red) ---@diagnostic disable-line
end

function FakeEHITrackerManager:GetPeerColor()
    if CustomNameColor and CustomNameColor.GetOwnColor then
        return CustomNameColor:GetOwnColor()
    end
    local i = 1
    local session = managers.network and managers.network:session()
    if session and session:local_peer() then
        i = session:local_peer():id() or 1
    end
    return tweak_data.chat_colors[i] or tweak_data.chat_colors[#tweak_data.chat_colors] or Color.white
end

function FakeEHITrackerManager:GetOtherPeerColor()
    local colors = deep_clone(tweak_data.chat_colors)
    local i = 1
    local session = managers.network and managers.network:session()
    if session and session:local_peer() then
        i = session:local_peer():id() or 1
    end
    table.remove(colors, i)
    return colors[math.random(#colors - 1)]
end

function FakeEHITrackerManager:AddPreviewText()
    if self._n_of_trackers == 0 then
        return
    end
    self._preview_text = self._hud_panel:text({
        name = "preview_text",
        text = managers.localization:text("ehi_preview"),
        font_size = 23,
        font = tweak_data.menu.pd2_large_font,
        align = "center",
        vertical = "center",
        layer = 401,
        visible = EHI:GetOption("show_preview_text")
    })
    self:make_fine_text(self._preview_text)
    self._preview_text:set_bottom(self:GetY(0) - panel_offset)
    self._preview_text:set_x(self._x)
end

function FakeEHITrackerManager:UpdatePreviewTextVisibility(visibility)
    if self._preview_text then
        self._preview_text:set_visible(visibility)
    end
end

function FakeEHITrackerManager:GetPos(pos)
    local x, y = self._x, self._y
    if self._tracker_alignment == 1 then -- Vertical
        local new_y = self:GetY(pos, true)
        if (new_y + panel_offset + panel_size) > self._hud_panel:h() then
            self._vertical.y_offset = pos
            local new_x = self._vertical.x + self:GetTrackerSize(self._vertical.max_icons)
            self._vertical.x = new_x
            x = new_x
        else
            x = self._vertical.x
            y = new_y
        end
    elseif pos and pos > 0 then -- Horizontal
        local tracker = self._fake_trackers[pos] --[[@as FakeEHITracker]]
        x = tracker._panel:right() + (tracker:GetSize() - tracker._panel:w()) + panel_offset
        --[[if x > self._hud_panel:w() then
            x = self._x
            local new_y = self._horizontal.y + panel_offset + panel_size
            self._horizontal.y = new_y
            y = new_y
        else
            y = self._horizontal.y
        end]]
    end
    return x, y
end

function FakeEHITrackerManager:GetY(pos, horizontal)
    local corrected_pos = horizontal and (pos - self._vertical.y_offset) or pos
    return self._y + (corrected_pos * (panel_size + panel_offset))
end

function FakeEHITrackerManager:GetTrackerSize(n_of_icons)
    local panel_with_offset = panel_size + panel_offset
    local gap = 5 * n_of_icons
    local icons = 32 * n_of_icons
    local final_size = (64 + panel_with_offset + gap + icons) * self._scale
    return final_size
end

function FakeEHITrackerManager:UpdateTracker(id, value)
    local correct_id = ""
    if id == "xp_panel" then
        correct_id = "show_gained_xp"
    elseif id == "gage_tracker_panel" then
        correct_id = "show_gage_tracker"
    end
    if correct_id == "" then
        return
    end
    local tracker = self:GetTracker(correct_id)
    if not not tracker ~= value then
        self:Redraw()
    end
end

function FakeEHITrackerManager:UpdateEnemyCountTracker(value)
    local tracker = self:GetTracker("show_enemy_count_tracker")
    if tracker then
        tracker:UpdateFormat(value)
    end
end

function FakeEHITrackerManager:UpdateFormat(format)
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateFormat(format)
    end
end

function FakeEHITrackerManager:UpdateEquipmentFormat(format)
    for _, tracker in ipairs(self._fake_trackers) do
        if tracker.UpdateEquipmentFormat then ---@diagnostic disable-line
            tracker:UpdateEquipmentFormat(format) ---@diagnostic disable-line
        end
    end
end

function FakeEHITrackerManager:UpdateXOffset(x)
    local x_full, _ = managers.gui_data:safe_to_full(x, 0)
    self._x = x_full
    self._vertical.x = x_full
    self._vertical.y_offset = 0
    for i, tracker in ipairs(self._fake_trackers) do
        local x_new, _ = self:GetPos(i - 1)
        tracker:SetX(x_new)
    end
end

function FakeEHITrackerManager:UpdateYOffset(y)
    local _, y_full = managers.gui_data:safe_to_full(0, y)
    self._y = y_full
    self._vertical.x = self._x
    self._vertical.y = y_full
    self._vertical.y_offset = 0
    for i, tracker in ipairs(self._fake_trackers) do
        local x_new, y_new = self:GetPos(i - 1)
        tracker:SetPos(x_new, y_new)
    end
    if self._preview_text then
        self._preview_text:set_bottom(self:GetY(0) - panel_offset)
    end
end

function FakeEHITrackerManager:SetSelected(id)
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:SetSelected(id)
    end
end

function FakeEHITrackerManager:UpdateTextScale(scale)
    self._text_scale = scale
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateTextScale(scale)
    end
end

function FakeEHITrackerManager:UpdateScale(scale)
    self._scale = scale
    panel_size = panel_size_original * self._scale
    panel_offset = panel_offset_original * self._scale
    self:Redraw()
end

function FakeEHITrackerManager:UpdateBGVisibility(visibility)
    self._bg_visibility = visibility
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateBGVisibility(visibility, self._corner_visibility)
    end
end

function FakeEHITrackerManager:UpdateCornerVisibility(visibility)
    self._corner_visibility = visibility
    if not self._bg_visibility then
        return
    end
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateCornerVisibility(visibility)
    end
end

function FakeEHITrackerManager:UpdateIconsVisibility(visibility)
    self._icons_visibility = visibility
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateIconsVisibility(visibility)
    end
    if self._tracker_alignment == 2 then -- Horizontal Alignment
        self:UpdateXOffset(EHI:GetOption("x_offset"))
    end
end

function FakeEHITrackerManager:UpdateTrackerAlignment(alignment)
    if self._tracker_alignment == alignment then
        return
    end
    self._tracker_alignment = alignment
    self:Redraw()
end

function FakeEHITrackerManager:Redraw()
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:destroy()
    end
    if self._preview_text then
        self._hud_panel:remove(self._preview_text)
    end
    self._horizontal.x = self._x
    self._horizontal.y = self._y
    self._horizontal.x_offset = 0
    self._vertical.x = self._x
    self._vertical.y = self._y
    self._vertical.y_offset = 0
    self:AddFakeTrackers()
end

function FakeEHITrackerManager:UpdateMinionTracker(value)
    local tracker = self:GetTracker("show_minion_tracker")
    if not tracker then
        return
    end
    tracker:UpdateFormat(value)
end

---@param id string
---@return FakeEHITracker?
function FakeEHITrackerManager:GetTracker(id)
    for _, tracker in ipairs(self._fake_trackers) do
        if tracker:GetID() == id then
            return tracker
        end
    end
end

local icons = tweak_data.ehi and tweak_data.ehi.icons or {}

local function GetIcon(icon)
    if icons[icon] then
        return icons[icon].texture, icons[icon].texture_rect
    end
    return tweak_data.hud_icons:get_icon_or(icon, icons.default.texture, icons.default.texture_rect)
end

---@param self FakeEHITracker
---@param i string
---@param texture string
---@param texture_rect table?
---@param color number
---@param alpha number
---@param visible boolean
---@param x number
local function CreateIcon(self, i, texture, texture_rect, color, alpha, visible, x)
    self["_icon" .. i] = self._panel:bitmap({
        name = "icon" .. i,
        texture = texture,
        texture_rect = texture_rect,
        color = color,
        alpha = alpha,
        visible = visible,
        x = x,
        w = self._icon_size_scaled,
        h = self._icon_size_scaled
    })
end

---@param panel Panel
---@param params table
---@param config table
---@return Panel
local function HUDBGBox_create(panel, params, config) -- Not available when called from menu
	local box_panel = panel:panel(params)
	local color = config and config.color or Color.white
	local bg_color = config and config.bg_color or Color(1, 0, 0, 0)
    local corner_visible = config.bg_visible and config.corner_visible

	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = bg_color,
        visible = config.bg_visible
	})

	local left_top = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "left_top",
		visible = params.first or corner_visible,
		layer = 0,
		y = 0,
		halign = "left",
		x = 0,
		valign = "top",
		color = color,
		blend_mode = "add"
	})
	local left_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "left_bottom",
		visible = corner_visible,
		layer = 0,
		x = 0,
		y = 0,
		halign = "left",
		rotation = -90,
		valign = "bottom",
		color = color,
		blend_mode = "add"
	})

	left_bottom:set_bottom(box_panel:h())

	local right_top = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "right_top",
		visible = corner_visible,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 90,
		valign = "top",
		color = color,
		blend_mode = "add"
	})

	right_top:set_right(box_panel:w())

	local right_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "right_bottom",
		visible = corner_visible,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 180,
		valign = "bottom",
		color = color,
		blend_mode = "add"
	})

	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())

	return box_panel
end

---@class FakeEHITracker
---@field _icon1 PanelBitmap
---@field _parent_class FakeEHITrackerManager
FakeEHITracker = class()
FakeEHITracker._gap = 5
FakeEHITracker._icon_size = 32
FakeEHITracker._icon_gap_size = FakeEHITracker._icon_size + FakeEHITracker._gap
FakeEHITracker._selected_color = Color(255, 255, 165, 0) / 255
---@param panel Panel
---@param params table
function FakeEHITracker:init(panel, params)
    self._scale = params.scale --[[@as number]]
    self._text_scale = params.text_scale --[[@as number]]
    self._first = params.first
    local number_of_icons = 0
    local gap = 0
    if params.icons then
        number_of_icons = #params.icons
        gap = self._gap * number_of_icons
    end
    self._gap_scaled = self._gap * self._scale
    self._icon_size_scaled = 32 * self._scale
    self._icon_gap_size_scaled = (self._icon_size + self._gap) * self._scale -- (32 + 5) * self._scale
    self._parent_panel = panel
    self._panel = panel:panel({
        name = params.id,
        x = params.x,
        y = params.y,
        w = (64 + gap + (self._icon_size * number_of_icons)) * self._scale,
        h = self._icon_size_scaled
    })
    self._time = params.time or 0
    self._bg_box = HUDBGBox_create(self._panel, {
        x = 0,
        y = 0,
        w = 64 * self._scale,
        h = self._icon_size_scaled
    }, {
        bg_visible = params.bg,
        corner_visible = params.corners,
        first = self._first
    })
    self._text = self._bg_box:text({
        name = "text1",
        text = self:Format(),
        align = "center",
        vertical = "center",
        w = self._bg_box:w(),
        h = self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self:FitTheText()
    self._n_of_icons = number_of_icons
    self._n = number_of_icons
    if number_of_icons > 0 then
        local start = self._bg_box:w()
        local icon_gap = self._gap_scaled
        for i, v in ipairs(params.icons) do
            local s_i = tostring(i)
            if type(v) == "string" then
                local texture, rect = GetIcon(v)
                CreateIcon(self, s_i, texture, rect, Color.white, 1, true, start + icon_gap)
            else -- table
                local texture, rect = GetIcon(v.icon)
                CreateIcon(self, s_i, texture, rect, v.color,
                    v.alpha or 1,
                    v.visible ~= false,
                    start + icon_gap)
            end
            start = start + self._icon_size_scaled
            icon_gap = icon_gap + self._gap_scaled
        end
        if params.one_icon then
            self:UpdateIconsVisibility(true)
            self._n = 1
        end
    end
    self._id = params.id
    self._parent_class = params.parent_class
    if params.extend then
        self:SetBGSize()
    elseif params.extend_half then
        self:SetBGSize(self._bg_box:w() / 2)
    end
    self._selected = false
end

---@param w number? If not provided, `w` is taken from the BG
---@param type string?
---|"add" # Adds `w` to the BG; default `type` if not provided
---|"short" # Shorts `w` on the BG
---@param dont_recalculate_panel_w boolean? Setting this to `true` will not recalculate the total width on the main panel
function FakeEHITracker:SetBGSize(w, type, dont_recalculate_panel_w)
    w = w or self._bg_box:w()
    if not type or type == "add" then
        self._bg_box:set_w(self._bg_box:w() + w)
    else
        self._bg_box:set_w(self._bg_box:w() - w)
    end
    if not dont_recalculate_panel_w then
        local start = self._bg_box:w()
        local icons_with_gap = self._icon_gap_size_scaled * self._n_of_icons
        self._panel:set_w(start + icons_with_gap)
    end
    self:SetIconsX()
end

function FakeEHITracker:SetIconsX()
    ---@type PanelBitmap?
    local previous_icon
    for i = 1, self._n_of_icons, 1 do
        local icon = self["_icon" .. tostring(i)] --[[@as PanelBitmap?]]
        if icon then
            self:SetIconX(previous_icon, icon)
            previous_icon = icon
        end
    end
end

---@param previous_icon PanelBitmap?
---@param icon PanelBitmap? Defaults to `self._icon1` if not provided
function FakeEHITracker:SetIconX(previous_icon, icon)
    icon = icon or self._icon1
    if icon then
        if previous_icon then
            icon:set_x(previous_icon:right() + self._gap_scaled)
        else
            icon:set_x(self._bg_box:w() + self._gap_scaled)
        end
    end
end

function FakeEHITracker:GetID()
    return self._id
end

function FakeEHITracker:ResetFontSize(text)
    text:set_font_size(self._panel:h() * self._text_scale)
end

function FakeEHITracker:FitTheText(text)
    text = text or self._text
    self:ResetFontSize(text)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w) * self._text_scale)
    end
end

function FakeEHITracker:UpdateFormat(format)
    self._text:set_text(self:Format(format))
    self:FitTheText()
end

function FakeEHITracker:Format(format)
    format = format or EHI:GetOption("time_format")
    if format == 1 then
        return tweak_data.ehi.functions.FormatSecondsOnly(self)
    else
        return tweak_data.ehi.functions.FormatMinutesAndSeconds(self)
    end
end

function FakeEHITracker:SetX(x)
    self._panel:set_x(x)
end

function FakeEHITracker:SetY(y)
    self._panel:set_y(y)
end

function FakeEHITracker:SetPos(x, y)
    self:SetX(x)
    self:SetY(y)
end

function FakeEHITracker:SetSelected(id)
    local previous = self._selected
    self._selected = id == self:GetID()
    if previous == self._selected then
        return
    end
    self:SetTextColor(self._selected)
end

function FakeEHITracker:SetTextColor(selected)
    self._text:set_color(selected and self._selected_color or Color.white)
end

function FakeEHITracker:UpdateBGVisibility(visibility, corners)
    self._bg_box:child("bg"):set_visible(visibility) ---@diagnostic disable-line
    self:UpdateCornerVisibility(visibility and corners)
end

function FakeEHITracker:UpdateCornerVisibility(visibility)
    if not self._first then
        self._bg_box:child("left_top"):set_visible(visibility) ---@diagnostic disable-line
    end
    self._bg_box:child("left_bottom"):set_visible(visibility) ---@diagnostic disable-line
    self._bg_box:child("right_top"):set_visible(visibility) ---@diagnostic disable-line
    self._bg_box:child("right_bottom"):set_visible(visibility) ---@diagnostic disable-line
end

function FakeEHITracker:UpdateIconsVisibility(visibility)
    local i_start = visibility and 2 or 1
    self._n = visibility and 1 or self._n_of_icons
    for i = i_start, self._n_of_icons, 1 do
        self["_icon" .. i]:set_visible(not visibility)
    end
end

function FakeEHITracker:UpdateTextScale(scale)
    self._text_scale = scale
    self:FitTheText()
end

function FakeEHITracker:GetSize()
    if self._n == 1 then
        return self._bg_box:w() + self._icon_gap_size_scaled
    end
    return self._panel:w()
end

function FakeEHITracker:destroy()
    if alive(self._panel) and alive(self._parent_panel) then
        self._parent_panel:remove(self._panel)
    end
end

---@class FakeEHIXPTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIXPTracker = class(FakeEHITracker)
function FakeEHIXPTracker:init(panel, params)
    self._xp = math.random(1000, 1000000)
    FakeEHIXPTracker.super.init(self, panel, params)
    if params.extend_half and self._icon1 then
        self._text:set_w(self._bg_box:w())
        self:FitTheText()
    end
end

function FakeEHIXPTracker:Format(format)
    return "+" .. self._xp
end

---@class FakeEHIProgressTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIProgressTracker = class(FakeEHITracker)
function FakeEHIProgressTracker:init(panel, params)
    self._progress = math.random(0, params.progress or 9)
    self._max = params.max or 10
    FakeEHIProgressTracker.super.init(self, panel, params)
end

function FakeEHIProgressTracker:Format(format)
    return self._progress .. "/" .. self._max
end

---@class FakeEHIChanceTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIChanceTracker = class(FakeEHITracker)
function FakeEHIChanceTracker:init(panel, params)
    self._chance = params.chance or (math.random(1, 10) * 5)
    FakeEHIChanceTracker.super.init(self, panel, params)
end

function FakeEHIChanceTracker:Format(format)
    return self._chance .. "%"
end

---@class FakeEHIEquipmentTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIEquipmentTracker = class(FakeEHITracker)
function FakeEHIEquipmentTracker:init(panel, params)
    self._show_placed = params.show_placed
    local max = params.charges or 16
    self._charges = math.random(params.min or 2, max)
    self._placed = self._charges > 4 and math.ceil(self._charges / 4) or 1
    FakeEHIEquipmentTracker.super.init(self, panel, params)
end

function FakeEHIEquipmentTracker:Format(format)
    return self:EquipmentFormat()
end

function FakeEHIEquipmentTracker:EquipmentFormat(format)
    format = format or EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        if self._show_placed then
            return self._charges .. " (" .. self._placed .. ")"
        else
            return tostring(self._charges)
        end
    elseif format == 2 then -- (Bags placed) Uses
        if self._show_placed then
            return "(" .. self._placed .. ") " .. self._charges
        else
            return tostring(self._charges)
        end
    elseif format == 3 then -- (Uses) Bags placed
        if self._show_placed then
            return "(" .. self._charges .. ") " .. self._placed
        else
            return tostring(self._charges)
        end
    elseif format == 4 then -- Bags placed (Uses)
        if self._show_placed then
            return self._placed .. " (" .. self._charges .. ")"
        else
            return tostring(self._charges)
        end
    elseif format == 5 then -- Uses
        return tostring(self._charges)
    else -- Bags placed
        if self._show_placed then
            return tostring(self._placed)
        else
            return tostring(self._charges)
        end
    end
end

function FakeEHIEquipmentTracker:UpdateEquipmentFormat(format)
    self._text:set_font_size(self._panel:h() * self._text_scale)
    self._text:set_text(self:EquipmentFormat(format))
    self:FitTheText()
end

---@class FakeEHIMinionCounterTracker : FakeEHIEquipmentTracker
---@field super FakeEHIEquipmentTracker
FakeEHIMinionCounterTracker = class(FakeEHIEquipmentTracker)
function FakeEHIMinionCounterTracker:init(panel, params)
    FakeEHIMinionCounterTracker.super.init(self, panel, params)
    self._charges_second_player = math.random(params.min, params.charges)
    self._color_second_player = self._parent_class:GetOtherPeerColor()
    self._text_second_player = self._bg_box:text({
        name = "text_second_player",
        text = tostring(self._charges_second_player),
        align = "center",
        vertical = "center",
        w = self._bg_box:w() / 2,
        h = self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = self._color_second_player
    })
    self._text_second_player:set_right(self._bg_box:right())
    self:FitTheText(self._text_second_player)
    self._text_total = self._bg_box:text({
        name = "text_total",
        text = tostring(self._charges + self._charges_second_player),
        align = "center",
        vertical = "center",
        w = self._bg_box:w(),
        h = self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = Color.white
    })
    self:UpdateFormat(EHI:GetOption("show_minion_option"))
end

function FakeEHIMinionCounterTracker:UpdateFormat(value)
    self._icon1:set_color(value == 1 and self._parent_class:GetPeerColor() or Color.white)
    self._text_second_player:set_visible(value == 3)
    self._text_total:set_visible(value == 2)
    self._text:set_visible(value ~= 2)
    self._text:set_color(value == 3 and self._parent_class:GetPeerColor() or Color.white)
    self._format = value
    if value == 3 then
        self._text:set_w(self._bg_box:w() / 2)
    else
        self._text:set_w(self._bg_box:w())
    end
    self:FitTheText()
end

function FakeEHIMinionCounterTracker:SetTextColor(selected)
    self._text:set_color(selected and self._selected_color or (self._format == 3 and self._parent_class:GetPeerColor() or Color.white))
    self._text_second_player:set_color(selected and self._selected_color or self._color_second_player)
end

---@class FakeEHICountTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHICountTracker = class(FakeEHITracker)
function FakeEHICountTracker:init(panel, params)
    self._count = params.count
    FakeEHICountTracker.super.init(self, panel, params)
end

function FakeEHICountTracker:Format(format)
    return tostring(self._count)
end

---@class FakeEHIEnemyCountTracker : FakeEHICountTracker
---@field super FakeEHICountTracker
---@field _icon2 PanelBitmap
FakeEHIEnemyCountTracker = class(FakeEHICountTracker)
function FakeEHIEnemyCountTracker:init(panel, params)
    self._alarm_count = math.random(0, 10)
    self._format_alarm = EHI:GetOption("show_enemy_count_show_pagers")
    FakeEHIEnemyCountTracker.super.init(self, panel, params)
end

function FakeEHIEnemyCountTracker:Format(format)
    if self._format_alarm then
        return self._alarm_count .. "|" .. self._count
    end
    return FakeEHIEnemyCountTracker.super.Format(self, format)
end

function FakeEHIEnemyCountTracker:UpdateFormat(format)
    self._format_alarm = format
    self._text:set_text(self:Format())
    self:FitTheText()
    self:UpdateIconPos()
end

function FakeEHIEnemyCountTracker:UpdateIconPos()
    if self._n == 1 then -- 1 icon
        self._icon1:set_visible(self._format_alarm)
        self._icon2:set_visible(not self._format_alarm)
        self._icon2:set_x(self._icon1:x())
    else
        self._icon1:set_visible(self._format_alarm)
        self._icon2:set_visible(true)
        if self._format_alarm then
            self._icon2:set_x(self._icon1:x() + self._icon_gap_size_scaled)
        else
            self._icon2:set_x(self._icon1:x())
        end
    end
end

function FakeEHIEnemyCountTracker:UpdateIconsVisibility(visibility)
    FakeEHIEnemyCountTracker.super.UpdateIconsVisibility(self, visibility)
    self:UpdateIconPos()
end

---@class FakeEHITimerTracker : FakeEHITracker, FakeEHIProgressTracker
---@field super FakeEHITracker
FakeEHITimerTracker = class(FakeEHITracker)
FakeEHITimerTracker.FormatProgress = FakeEHIProgressTracker.Format
function FakeEHITimerTracker:init(panel, params)
    self._max = 3
    self._progress = math.random(0, 2)
    FakeEHITimerTracker.super.init(self, panel, params)
    self._progress_text = self._bg_box:text({
        name = "text2",
        text = self:FormatProgress(),
        align = "center",
        vertical = "center",
        w = self._bg_box:w() / 2,
        h = self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self._text:set_left(0)
    self._progress_text:set_left(self._text:right())
    self:FitTheText(self._progress_text)
end

function FakeEHITimerTracker:SetTextColor(selected)
    FakeEHITimerTracker.super.SetTextColor(self, selected)
    self._progress_text:set_color(selected and self._selected_color or Color.white)
end

function FakeEHITimerTracker:UpdateTextScale(scale)
    FakeEHITimerTracker.super.UpdateTextScale(self, scale)
    self:FitTheText(self._progress_text)
end

---@class FakeEHIAssaultTimeTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIAssaultTimeTracker = class(FakeEHITracker)
function FakeEHIAssaultTimeTracker:init(panel, params)
    FakeEHIAssaultTimeTracker.super.init(self, panel, params)
    if self._time <= 5 then -- Fade
        self._icon1:set_color(Color(255, 0, 255, 255) / 255)
    elseif self._time >= 205 then -- Build
        self._icon1:set_color(Color.yellow)
    else
        self._icon1:set_color(Color(255, 237, 127, 127) / 255)
    end
end

---@class FakeEHISniperTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHISniperTracker = class(FakeEHITracker)
FakeEHISniperTracker._selected_color = Color.yellow
FakeEHISniperTracker._text_color = FakeEHITracker._selected_color
function FakeEHISniperTracker:init(panel, params)
    FakeEHISniperTracker.super.init(self, panel, params)
    self._text:set_color(self._text_color)
    self._text:set_text(tostring(math.random(1, 4)))
end

function FakeEHISniperTracker:SetTextColor(selected)
    self._text:set_color(selected and self._selected_color or self._text_color)
end