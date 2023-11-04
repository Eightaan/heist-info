local function GetIcon(params)
    local texture = ""
    local texture_rect = {}
    local x = params.x or 0
    local y = params.y or 0
    if params.skills then
        texture = "guis/textures/pd2/skilltree/icons_atlas"
		texture_rect = { x * 64, y * 64, 64, 64 }
    elseif params.u100skill then
        texture = "guis/textures/pd2/skilltree_2/icons_atlas_2"
		texture_rect = { x * 80, y * 80, 80, 80 }
    elseif params.deck then
        texture = "guis/" .. (params.folder and ("dlcs/" .. params.folder .. "/") or "") .. "textures/pd2/specialization/icons_atlas"
		texture_rect = { x * 64, y * 64, 64, 64 }
    elseif params.texture then
        texture = params.texture
        texture_rect = params.texture_rect
    end
    return texture, texture_rect
end

local EHI = EHI
local buff_w_original = 32
local buff_h_original = 64
local buff_w = buff_w_original
local buff_h = buff_h_original
---@class FakeEHIBuffsManager
---@field new fun(self: self, panel: Panel): self
FakeEHIBuffsManager = class()
---@param panel Panel
function FakeEHIBuffsManager:init(panel)
	self._buffs = {}
    self._hud_panel = panel:panel({
        name = "fake_ehi_buffs_panel",
        layer = 0,
        alpha = 1
    })
    self:SetScale(EHI:GetOption("buffs_scale"))
    self._x = EHI:GetOption("buffs_x_offset")
    self._y = EHI:GetOption("buffs_y_offset")
    self._n_visible = 0
	self._buffs_alignment = EHI:GetOption("buffs_alignment")
    self._gap = 6
    self:AddFakeTrackers()
    self:OrganizeBuffs()
end

function FakeEHIBuffsManager:SetScale(scale)
    self._scale = scale
	buff_w = buff_w_original * scale
    buff_h = buff_h_original * scale
end

function FakeEHIBuffsManager:AddFakeTrackers()
    local visible = EHI:GetOption("show_buffs")
    local shape = EHI:GetOption("buffs_shape")
    local progress = EHI:GetOption("buffs_show_progress")
    local buffs = tweak_data.ehi.buff
    local max = math.random(3, 5)
    local max_buffs = table.size(buffs)
    local visible_buffs = {}
    local saferect_x, saferect_y = managers.gui_data:full_to_safe(self._hud_panel:w(), self._hud_panel:h())
    saferect_x = self._hud_panel:w() - saferect_x + 0.5
    saferect_y = self._hud_panel:h() - saferect_y + 0.5
    saferect_x = saferect_x * 2
    saferect_y = saferect_y * 2
    for i = 1, max, 1 do
        local n = 0
        local m = math.random(1, max_buffs)
        for key, buff in pairs(buffs) do
            n = n + 1
            if m == n then
                if not visible_buffs[key] then
                    local params = {}
                    params.id = key
                    params.texture, params.texture_rect = GetIcon(buff)
                    params.text = buff.text
                    params.x = self._x - saferect_x
                    params.y = self._y + saferect_y
                    params.visible = visible
                    params.shape = shape
                    params.scale = self._scale
                    params.show_progress = progress
                    params.good = not buff.bad
                    params.saferect_x = saferect_x
                    params.saferect_y = saferect_y
                    params.parent_class = self
                    if buff.class and buff.class == "EHIGaugeBuffTracker" then
                        params.class = "FakeEHIGaugeBuffTracker"
                    end
                    self:AddFakeTracker(params)
                    visible_buffs[key] = true
                    break
                else
                    n = n - 1
                end
            end
        end
    end
    if EHI:GetOption("buffs_invert_progress") then
        self:UpdateBuffs("InvertProgress")
    end
end

function FakeEHIBuffsManager:AddFakeTracker(params)
    self._n_visible = self._n_visible + 1
    self._buffs[self._n_visible] = _G[params.class or "FakeEHIBuffTracker"]:new(self._hud_panel, params)
end

function FakeEHIBuffsManager:OrganizeBuffs()
    if self._buffs_alignment == 1 then -- Left
        if self._n_visible == 0 then
            return
        end
        local i = 0
        local previous_buff
        for _, buff in pairs(self._buffs) do
            if i == 0 then
                buff:SetX(self._x)
            else
                buff:SetXOnly(previous_buff._hud_panel:right() + self._gap)
            end
            i = i + 1
            previous_buff = buff
        end
    elseif self._buffs_alignment == 2 then -- Center
        if self._n_visible == 0 then
            return
        elseif self._n_visible == 1 then
            self._buffs[1]:SetCenterX(self._hud_panel:center_x())
        else
            local even = self._n_visible % 2 == 0
            local center_x = self._hud_panel:center_x()
            local buff_w_half = buff_w / 2
            if even then
                local switch = true
                local move = buff_w_half + self._gap
                local move_gap_2 = move - (self._gap / 2)
                local panel_move = buff_w_half + move
                local buff_left
                local buff_right
                for _, buff in ipairs(self._buffs) do
                    buff:SetCenterX(center_x)
                    if switch then
                        if buff_left then
                            buff:SetXOnly(buff_left._hud_panel:x() - panel_move)
                        else
                            buff:MovePanelLeft(move_gap_2)
                        end
                        buff_left = buff
                    else
                        if buff_right then
                            buff:SetXOnly(buff_right._hud_panel:right() + self._gap)
                        else
                            buff:MovePanelRight(move_gap_2)
                        end
                        buff_right = buff
                    end
                    switch = not switch
                end
            else
                local middle_switch = true
                local switch = false
                local move = buff_w_half + self._gap
                local panel_move = buff_w_half + move
                local buff_left
                local buff_right
                for _, buff in ipairs(self._buffs) do
                    buff:SetCenterX(center_x)
                    if middle_switch then
                        buff_left = buff
                        buff_right = buff
                        middle_switch = false
                    elseif switch then
                        buff:SetXOnly(buff_left._hud_panel:x() - panel_move)
                        buff_left = buff
                    else
                        buff:SetXOnly(buff_right._hud_panel:right() + self._gap)
                        buff_right = buff
                    end
                    switch = not switch
                end
            end
        end
    else -- Right
        if self._n_visible == 0 then
            return
        end
        local i = 0
        local move = buff_w + self._gap
        for _, buff in ipairs(self._buffs) do
            buff:SetRight(self._x)
            if i ~= 0 then
                buff:MovePanelLeft(move * i)
            end
            i = i + 1
        end
    end
end

function FakeEHIBuffsManager:UpdateXOffset(x)
	self._x = x
	if self._buffs_alignment == 2 then -- Center
		return
	end
	self:OrganizeBuffs()
end

function FakeEHIBuffsManager:UpdateYOffset(y)
	self._y = y
    self:UpdateBuffs("SetY", y)
end

function FakeEHIBuffsManager:UpdateScale(scale)
    self:SetScale(scale)
    self:UpdateBuffs("destroy")
    self._buffs = {}
    self._n_visible = 0
    self:AddFakeTrackers()
    self:OrganizeBuffs()
end

function FakeEHIBuffsManager:UpdateAlignment(alignment)
	self._buffs_alignment = alignment
	self:OrganizeBuffs()
end

function FakeEHIBuffsManager:UpdateBuffs(f, ...)
    for _, buff in pairs(self._buffs) do
        buff[f](buff, ...)
    end
end

FakeEHIBuffTracker = class()
FakeEHIBuffTracker._rect_circle = {128, 0, -128, 128}
FakeEHIBuffTracker._rect_square = {32, 0, -32, 32}
function FakeEHIBuffTracker:init(panel, params)
    local buff_w_half = buff_w / 2
    self._show_progress = params.show_progress
    self._shape = params.shape
    self._scale = params.scale
    self._id = params.id
    self._parent_panel = panel
    self._hud_panel = panel:panel({
        name = self._id,
        w = buff_w,
        h = buff_h,
        y = panel:bottom() - buff_h - params.y + (params.saferect_y / 2),
        visible = params.visible
    })
    local icon = self._hud_panel:bitmap({
        name = "icon",
        texture = params.texture,
        texture_rect = params.texture_rect,
        color = params.good and Color.white or Color.red,
        x = 0,
        y = buff_w_half,
        w = buff_w,
        h = buff_w
    })
	self._time_bg_box = self._hud_panel:panel({
		name = "time_bg_box",
		x = 0,
        y = buff_w_half,
        w = buff_w,
        h = buff_w
	})
	self._time_bg_box:rect({
		blend_mode = "normal",
		name = "bg_square",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = Color(1, 0, 0, 0),
        visible = self._shape == 1
	})
    self._time_bg_box:bitmap({
        name = "bg_circle",
        layer = -1,
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        texture = "guis/textures/pd2/hud_tabs",
        texture_rect = {105, 34, 19, 19},
        color = Color.black:with_alpha(0.2),
        visible = self._shape == 2
    })
    self._hud_panel:bitmap({
        name = "progress_circle",
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        y = icon:y(),
        w = icon:w(),
        h = icon:h(),
        texture = params.good and "guis/textures/pd2_mod_ehi/buff_cframe" or "guis/textures/pd2_mod_ehi/buff_cframe_debuff",
        texture_rect = self._rect_circle,
        visible = self._shape == 2 and self._show_progress
    })
    self._hud_panel:bitmap({
        name = "progress_square",
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        y = icon:y(),
        w = icon:w(),
        h = icon:h(),
        texture = params.good and "guis/textures/pd2_mod_ehi/buff_sframe" or "guis/textures/pd2_mod_ehi/buff_sframe_debuff",
        texture_rect = self._rect_square,
        visible = self._shape == 1 and self._show_progress
    })
    self._hint = self._hud_panel:text({
        name = "hint",
        text = params.text or "",
        w = self._hud_panel:w(),
        h = buff_w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = buff_w_half,
        color = Color.white,
        align = "center",
        x = 0,
        y = 0
    })
    self._time = math.random(0, 100)
    self._text = self._hud_panel:text({
        name = "text",
        text = "100s",
        w = self._hud_panel:w(),
        h = self._hud_panel:h() - self._time_bg_box:h() - buff_w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = buff_w_half,
        color = Color.white,
        align = "center",
        vertical = "center",
        y = self._hud_panel:w() + buff_w_half,
    })
    self._hud_panel:set_center_x(panel:center_x())
    self._saferect_x = params.saferect_x
    self._saferect_y = params.saferect_y
    self:SetProgress(self._time / 100)
    self:UpdateProgressVisibility(self._show_progress, true)
    self._inverted = false
    if self._show_progress then
        local size = 24 * self._scale
        local move = 4 * self._scale
        icon:set_size(size, size)
        icon:set_x(icon:x() + move)
        icon:set_y(icon:y() + move)
    end
end

function FakeEHIBuffTracker:SetProgress(r)
    local c = Color(1, r, 1, 1)
    self._hud_panel:child("progress_circle"):set_color(c)
    self._hud_panel:child("progress_square"):set_color(c)
end

function FakeEHIBuffTracker:SetCenterX(center_x)
    self._hud_panel:set_center_x(center_x)
end

function FakeEHIBuffTracker:SetVisibility(visibility)
	self._hud_panel:set_visible(visibility)
end

function FakeEHIBuffTracker:SetX(x)
    self:SetXOnly(x + (self._saferect_x / 2))
end

function FakeEHIBuffTracker:SetXOnly(x)
    self._hud_panel:set_x(x)
end

function FakeEHIBuffTracker:SetY(y)
    local _y = y - (self._saferect_y / 2)
	self._hud_panel:set_y(self._hud_panel:parent():bottom() - self._hud_panel:h() - _y - self._saferect_y)
end

function FakeEHIBuffTracker:MovePanelLeft(x)
    self._hud_panel:set_x(self._hud_panel:x() - x)
end

function FakeEHIBuffTracker:MovePanelRight(x)
    self._hud_panel:set_x(self._hud_panel:x() + x)
end

function FakeEHIBuffTracker:SetRight(x)
    self._hud_panel:set_right(self._hud_panel:parent():w() - x - (self._saferect_x / 2))
end

function FakeEHIBuffTracker:UpdateBuffShape(shape)
    if shape == 1 then -- Square
        self._time_bg_box:child("bg_square"):set_visible(true)
        self._hud_panel:child("progress_square"):set_visible(self._show_progress)
        self._time_bg_box:child("bg_circle"):set_visible(false)
        self._hud_panel:child("progress_circle"):set_visible(false)
    else -- Circle
        self._time_bg_box:child("bg_square"):set_visible(false)
        self._hud_panel:child("progress_square"):set_visible(false)
        self._time_bg_box:child("bg_circle"):set_visible(true)
        self._hud_panel:child("progress_circle"):set_visible(self._show_progress)
    end
    self._shape = shape
end

function FakeEHIBuffTracker:UpdateProgressVisibility(visibility, dont_force)
    self._show_progress = visibility
    self:UpdateBuffShape(self._shape)
    if dont_force then
        return
    end
    local icon = self._hud_panel:child("icon")
    if self._show_progress then
        local size = 24 * self._scale
        local move = 4 * self._scale
        icon:set_size(size, size)
        icon:set_x(icon:x() + move)
        icon:set_y(icon:y() + move)
    else
        local size = 32 * self._scale
        icon:set_size(size, size)
        icon:set_x(self._time_bg_box:x())
        icon:set_y(self._time_bg_box:y())
    end
end

local function Invert(self, rect, shape)
    local size = self._inverted and 0 or rect[4]
    local size_3 = self._inverted and rect[4] or rect[3]
    self._hud_panel:child(shape):set_texture_rect(size, rect[2], size_3, rect[4])
end
function FakeEHIBuffTracker:InvertProgress()
    self._inverted = not self._inverted
    Invert(self, self._rect_square, "progress_square")
    Invert(self, self._rect_circle, "progress_circle")
end

function FakeEHIBuffTracker:Format()
    return self._time .. "s"
end

function FakeEHIBuffTracker:destroy()
    if alive(self._hud_panel) and alive(self._parent_panel) then
        self._parent_panel:remove(self._hud_panel)
    end
end

FakeEHIGaugeBuffTracker = class(FakeEHIBuffTracker)
function FakeEHIGaugeBuffTracker:init(panel, params)
    FakeEHIGaugeBuffTracker.super.init(self, panel, params)
    self._ratio = math.random()
    self:SetProgress(self._ratio)
    self:InvertProgress()
end

function FakeEHIGaugeBuffTracker:Format()
    return (self._ratio * 100) .. "%"
end