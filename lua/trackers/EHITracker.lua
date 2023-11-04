local Color = Color
local math_abs = math.abs
local math_min = math.min
local math_sin = math.sin
local math_lerp = math.lerp
---@param o PanelBaseObject
---@param start_a number Start alpha
---@param end_a number End alpha
local function visibility(o, start_a, end_a) -- This is actually faster than manually re-typing optimized "over" function
    local TOTAL_T = 0.18
    local t = 0
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math_min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        o:set_alpha(math_lerp(start_a, end_a, lerp))
    end
end
---@param o PanelBaseObject
---@param target_y number
local function top(o, target_y)
    local t = 0
    local total = 0.18
    local from_y = o:y()
    while t < total do
        t = t + coroutine.yield()
        o:set_y(math_lerp(from_y, target_y, t / total))
    end
    o:set_y(target_y)
end
---@param o PanelBaseObject
---@param target_x number
local function left(o, target_x)
    local t = 0
    local total = 0.18
    local from_x = o:x()
    while t < total do
        t = t + coroutine.yield()
        o:set_x(math_lerp(from_x, target_x, t / total))
    end
    o:set_x(target_x)
end
---@param o PanelBaseObject
---@param target_w number
---@param self EHITracker
local function panel_w(o, target_w, self)
    local TOTAL_T = 0.18
    local from_w = o:w()
    local abs = -(from_w - target_w)
    local t = (1 - abs / abs) * TOTAL_T
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math_min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        o:set_w(math_lerp(from_w, target_w, lerp))
    end
    if self and self.Redraw then ---@diagnostic disable-line
        self:Redraw() ---@diagnostic disable-line
    end
end
---@param o PanelBaseObject
---@param target_x number
local function icon_x(o, target_x)
    local TOTAL_T = 0.18
    local from_x = o:x()
    local t = (1 - math_abs(from_x - target_x) / math_abs(from_x - target_x)) * TOTAL_T
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math_min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        o:set_x(math_lerp(from_x, target_x, lerp))
    end
end
---@param bg PanelRectangle
---@param total_t number
local function bg_attention(bg, total_t)
    local color = Color.white
	local t = total_t or 3
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local cv = math_abs(math_sin(t * 180 * 1))
		bg:set_color(Color(1, color.red * cv, color.green * cv, color.blue * cv))
	end
	bg:set_color(Color(1, 0, 0, 0))
end
---@param o PanelBaseObject
---@param skip boolean
---@param self EHITracker
local function destroy(o, skip, self)
    if not skip then
        visibility(o, o:alpha(), 0)
    end
    self._bg_box:child("bg"):stop()
    self._parent_panel:remove(self._panel)
end
local icons = tweak_data.ehi.icons
---@param icon string
---@return string, { x: number, y: number, w: number, h: number }
local function GetIcon(icon)
    if icons[icon] then
        return icons[icon].texture, icons[icon].texture_rect
    end
    return tweak_data.hud_icons:get_icon_or(icon, icons.default.texture, icons.default.texture_rect)
end

---@param self EHITracker
---@param i string
---@param texture string
---@param texture_rect { x: number, y: number, w: number, h: number }
---@param color Color
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

local bg_visibility = EHI:GetOption("show_tracker_bg")
local corner_visibility = EHI:GetOption("show_tracker_corners")

---@param panel Panel
---@param params table
---@return Panel
local function CreateHUDBGBox(panel, params)
    local box_panel = panel:panel(params)
	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = Color(1, 0, 0, 0),
        visible = bg_visibility
	})
    if bg_visibility and corner_visibility then
        box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            name = "left_top",
            visible = true,
            layer = 0,
            y = 0,
            halign = "left",
            x = 0,
            valign = "top",
            blend_mode = "add"
        })
        local left_bottom = box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            name = "left_bottom",
            visible = true,
            layer = 0,
            x = 0,
            y = 0,
            halign = "left",
            rotation = -90,
            valign = "bottom",
            blend_mode = "add"
        })
        left_bottom:set_bottom(box_panel:h())
        local right_top = box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            name = "right_top",
            visible = true,
            layer = 0,
            x = 0,
            y = 0,
            halign = "right",
            rotation = 90,
            valign = "top",
            blend_mode = "add"
        })
        right_top:set_right(box_panel:w())
        local right_bottom = box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            name = "right_bottom",
            visible = true,
            layer = 0,
            x = 0,
            y = 0,
            halign = "right",
            rotation = 180,
            valign = "bottom",
            blend_mode = "add"
        })
        right_bottom:set_right(box_panel:w())
        right_bottom:set_bottom(box_panel:h())
    end
	return box_panel
end

---@class EHITracker
---@field new fun(self: self, panel: Panel, params: AddTrackerTable|ElementTrigger): self
---@field _forced_icons table? Forces specific icons in the tracker
---@field _forced_time number? Forces specific time in the tracker
---@field _icon1 PanelBitmap
---@field _panel_override_w number?
EHITracker = class()
EHITracker._update = true
EHITracker._fade_time = 5
EHITracker._tracker_type = "accurate"
EHITracker._gap = 5
EHITracker._icon_size = 32
EHITracker._scale = EHI:IsVR() and EHI:GetOption("vr_scale") or EHI:GetOption("scale") --[[@as number]]
EHITracker._text_scale = EHI:GetOption("text_scale") --[[@as number]]
-- (32 + 5) * self._scale
EHITracker._icon_gap_size_scaled = (EHITracker._icon_size + EHITracker._gap) * EHITracker._scale
-- 32 * self._scale
EHITracker._icon_size_scaled = EHITracker._icon_size * EHITracker._scale
-- 5 * self._scale
EHITracker._gap_scaled = EHITracker._gap * EHITracker._scale
EHITracker._text_color = Color.white
---@param panel Panel Main panel provided by EHITrackerManager
---@param params EHITracker_params
function EHITracker:init(panel, params)
    self:pre_init(params)
    self._id = params.id
    self._icons = self._forced_icons or params.icons
    self._n_of_icons = 0
    local gap = 0
    if type(self._icons) == "table" then
        self._n_of_icons = #self._icons
        gap = self._gap * self._n_of_icons
    end
    self._parent_panel = panel
    self._time = self._forced_time or params.time or 0
    self._panel = panel:panel({
        name = params.id,
        x = params.x,
        y = params.y,
        w = (64 + gap + (self._icon_size * self._n_of_icons)) * self._scale,
        h = self._icon_size_scaled,
        alpha = 0,
        visible = true
    })
    self._bg_box = CreateHUDBGBox(self._panel, {
        x = 0,
        y = 0,
        w = 64 * self._scale,
        h = self._icon_size_scaled
    })
    self._text = self._bg_box:text({
        name = "text1",
        text = self:Format(),
        align = "center",
        vertical = "center",
        w = self._bg_box:w(),
        h = self._icon_size_scaled,
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self:FitTheText()
    if self._n_of_icons > 0 then
        self:CreateIcons()
    end
    self:OverridePanel()
    self._parent_class = params.parent_class
    self._hide_on_delete = params.hide_on_delete
    self._flash_times = params.flash_times or 3
    self._anim_flash = params.flash_bg ~= false
    self:post_init(params)
    if params.dynamic then
        self:SetPanelVisible()
    end
end

---@param params EHITracker_params
function EHITracker:pre_init(params)
end

---@param params EHITracker_params
function EHITracker:post_init(params)
end

function EHITracker:OverridePanel()
end

---@param new_id string
function EHITracker:UpdateID(new_id)
    self._id = new_id
end

---@param x number
---@param y number
function EHITracker:PosAndSetVisible(x, y)
    self._panel:set_x(x)
    self._panel:set_y(y)
    self:SetPanelVisible()
end

function EHITracker:SetPanelVisible()
    if self._anim_visibility then
        self._panel:stop(self._anim_visibility)
        self._anim_visibility = nil
    end
    self._anim_visibility = self._panel:animate(visibility, 0, 1)
end

function EHITracker:SetPanelHidden()
    if self._anim_visibility then
        self._panel:stop(self._anim_visibility)
        self._anim_visibility = nil
    end
    self._anim_visibility = self._panel:animate(visibility, 1, 0)
end

---@param target_y number
function EHITracker:AnimateTop(target_y)
    if self._anim_move then
        self._panel:stop(self._anim_move)
        self._anim_move = nil
    end
    self._anim_move = self._panel:animate(top, target_y)
end

---@param target_x number
function EHITracker:AnimateLeft(target_x)
    if self._anim_move then
        self._panel:stop(self._anim_move)
        self._anim_move = nil
    end
    self._anim_move = self._panel:animate(left, target_x)
end

---@param target_w number
function EHITracker:AnimatePanelW(target_w)
    if self._anim_set_w then
        self._panel:stop(self._anim_set_w)
        self._anim_set_w = nil
    end
    self._anim_set_w = self._panel:animate(panel_w, target_w)
end

---@param target_w number
function EHITracker:AnimatePanelWAndRefresh(target_w)
    if self._anim_set_w then
        self._panel:stop(self._anim_set_w)
        self._anim_set_w = nil
    end
    self._anim_set_w = self._panel:animate(panel_w, target_w, self)
end

---@param previous_icon PanelBitmap?
---@param icon PanelBitmap? Defaults to `self._icon1` if not provided
function EHITracker:SetIconX(previous_icon, icon)
    icon = icon or self._icon1
    if icon then
        if previous_icon then
            icon:set_x(previous_icon:right() + self._gap_scaled)
        else
            icon:set_x(self._bg_box:w() + self._gap_scaled)
        end
    end
end

---@param target_x number
function EHITracker:AnimIconX(target_x)
    if not self._icon1 then
        return
    end
    if self._anim_icon1_x then
        self._icon1:stop(self._anim_icon1_x)
        self._anim_icon1_x = nil
    end
    self._anim_icon1_x = self._icon1:animate(icon_x, target_x)
end

if EHI:GetOption("time_format") == 1 then
    EHITracker.Format = tweak_data.ehi.functions.FormatSecondsOnly
    EHITracker.FormatTime = tweak_data.ehi.functions.ReturnSecondsOnly
else
    EHITracker.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
    EHITracker.FormatTime = tweak_data.ehi.functions.ReturnMinutesAndSeconds
end

if EHI:GetOption("show_one_icon") then
    function EHITracker:CreateIcons()
        local icon_pos = self._bg_box:w() + self._gap_scaled
        local first_icon = self._icons[1]
        if type(first_icon) == "string" then
            local texture, rect = GetIcon(first_icon)
            CreateIcon(self, "1", texture, rect, Color.white, 1, true, icon_pos)
        elseif type(first_icon) == "table" then
            local texture, rect = GetIcon(first_icon.icon or "default")
            CreateIcon(self, "1", texture, rect, first_icon.color,
                first_icon.alpha or 1,
                first_icon.visible ~= false,
                icon_pos)
        end
    end
else
    function EHITracker:CreateIcons()
        local start = self._bg_box:w()
        local icon_gap = self._gap_scaled
        for i, v in ipairs(self._icons) do
            local s_i = tostring(i)
            if type(v) == "string" then
                local texture, rect = GetIcon(v)
                CreateIcon(self, s_i, texture, rect, Color.white, 1, true, start + icon_gap)
            elseif type(v) == "table" then -- table
                local texture, rect = GetIcon(v.icon or "default")
                CreateIcon(self, s_i, texture, rect, v.color,
                    v.alpha or 1,
                    v.visible ~= false,
                    start + icon_gap)
            end
            start = start + self._icon_size_scaled
            icon_gap = icon_gap + self._gap_scaled
        end
    end
end

---@param params EHITracker_CreateText?
---@return PanelText
function EHITracker:CreateText(params)
    params = params or {}
    local text = self._bg_box:text({
        name = params.name or "",
        text = params.text or "",
        align = "center",
        vertical = "center",
        w = params.w or self._bg_box:w(),
        h = params.h or self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = params.color or self._text_color
    })
    if params.status_text then
        self:SetStatusText(params.status_text, text)
    end
    return text
end

---@param w number? If not provided, `w` is taken from the BG
---@param type string?
---|"add" # Adds `w` to the BG; default `type` if not provided
---|"short" # Shorts `w` on the BG
---@param dont_recalculate_panel_w boolean? Setting this to `true` will not recalculate the total width on the main panel
function EHITracker:SetBGSize(w, type, dont_recalculate_panel_w)
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
end

---@param t any Unused
---@param dt number
function EHITracker:update(t, dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

---@param t any Unused
---@param dt number
function EHITracker:update_fade(t, dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

---@param text PanelText?
function EHITracker:ResetFontSize(text)
    text = text or self._text
    text:set_font_size(self._panel:h() * self._text_scale)
end

---@param text PanelText?
function EHITracker:FitTheText(text)
    text = text or self._text
    self:ResetFontSize(text)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w) * self._text_scale)
    end
end

---@param time number
function EHITracker:SetTime(time)
    self:SetTimeNoAnim(time)
    self:AnimateBG()
end

---@param time number
function EHITracker:SetTimeNoAnim(time)
    self._time = time
    self._text:set_text(self:Format())
    self:FitTheText()
end

function EHITracker:Run(params)
    self:SetTimeNoAnim(params.time or 0)
    self:SetTextColor()
end

---@param delay number
function EHITracker:AddDelay(delay)
    self:SetTime(self._time + delay)
end

---@param t number?
function EHITracker:AnimateBG(t)
    if not self._anim_flash then
        return
    end
    local bg = self._bg_box:child("bg") --[[@as PanelBitmap]]
    bg:stop()
    bg:set_color(Color(1, 0, 0, 0))
    bg:animate(bg_attention, t or self._flash_times)
end

---@param color Color? Color is set to `White` or tracker default color if not provided
---@param text PanelText? Defaults to `self._text` if not provided
function EHITracker:SetTextColor(color, text)
    text = text or self._text
    text:set_color(color or self._text_color)
end

---@param new_icon string
---@return string, { x: number, y: number, w: number, h: number }
function EHITracker:GetIcon(new_icon)
    return GetIcon(new_icon)
end

---@param new_icon string
function EHITracker:SetIcon(new_icon)
    local icon, texture_rect = GetIcon(new_icon)
    if texture_rect then
        self._icon1:set_image(icon, unpack(texture_rect))
    else
        self._icon1:set_image(icon)
    end
end

---@param color any
---@param icon PanelBitmap?
function EHITracker:SetIconColor(color, icon)
    icon = icon or self._icon1
    if icon then
        icon:set_color(color)
    end
end

---@param status string
---@param text PanelText?
function EHITracker:SetStatusText(status, text)
    text = text or self._text
    local txt = "ehi_achievement_" .. status
    if LocalizationManager._custom_localizations[txt] then
        text:set_text(managers.localization:text(txt))
    else
        text:set_text(string.upper(status))
    end
    self:FitTheText(text)
end

---@param time number
function EHITracker:SetTrackerAccurate(time)
    self._tracker_type = "accurate"
    self:SetTextColor()
    self:SetTimeNoAnim(time)
end

function EHITracker:RemoveTrackerFromUpdate()
    self._parent_class:RemoveTrackerFromUpdate(self._id)
end

function EHITracker:AddTrackerToUpdate()
    self._parent_class:AddTrackerToUpdate(self._id, self)
end

---@param w number? If not provided the width is then called from `EHITracker:GetPanelW()`
function EHITracker:ChangeTrackerWidth(w)
    self._parent_class:ChangeTrackerWidth(self._id, w or self:GetPanelW())
end

function EHITracker:GetPanelW()
    return self._panel_override_w or self._panel:w()
end

function EHITracker:GetTrackerType()
    return self._tracker_type
end

---@param skip boolean?
function EHITracker:destroy(skip)
    if alive(self._panel) and alive(self._parent_panel) then
        if self._icon1 then
            self._icon1:stop()
        end
        self._panel:stop()
        self._panel:animate(destroy, skip, self)
    end
end

function EHITracker:delete()
    if self._hide_on_delete then
        self._panel:stop()
        self:SetPanelHidden()
        self._parent_class:HideTracker(self._id)
        return
    elseif self._refresh_on_delete then
        self:Refresh()
        return
    end
    self:destroy()
    self._parent_class:DestroyTracker(self._id)
end

function EHITracker:Refresh()
end

function EHITracker:ForceDelete()
    self._hide_on_delete = nil
    self._refresh_on_delete = nil
    self:delete()
end

---@param create_f function
---@param animate_f function
function EHITracker.SetCustomBGFunctions(create_f, animate_f)
    CreateHUDBGBox = create_f
    bg_attention = animate_f
end