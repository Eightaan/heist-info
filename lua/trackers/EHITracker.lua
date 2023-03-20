local Color = Color
local math_abs = math.abs
local math_min = math.min
local math_sin = math.sin
local math_lerp = math.lerp
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
local function panel_w(o, target_w)
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
end
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
local icons = tweak_data.ehi.icons

local function GetIcon(icon)
    if icons[icon] then
        return icons[icon].texture, icons[icon].texture_rect
    end
    return tweak_data.hud_icons:get_icon_or(icon, icons.default.texture, icons.default.texture_rect)
end

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

EHITracker = class()
EHITracker._update = true
EHITracker._fade_time = 5
EHITracker._tracker_type = "accurate"
EHITracker._gap = 5
EHITracker._icon_size = 32
EHITracker._scale = _G.IS_VR and EHI:GetOption("vr_scale") or EHI:GetOption("scale")
EHITracker._text_scale = EHI:GetOption("text_scale")
EHITracker._icon_gap_size_scaled = (EHITracker._icon_size + EHITracker._gap) * EHITracker._scale
-- 32 * self._scale
EHITracker._icon_size_scaled = EHITracker._icon_size * EHITracker._scale
-- 5 * self._scale
EHITracker._gap_scaled = EHITracker._gap * EHITracker._scale
EHITracker._text_color = Color.white
function EHITracker:init(panel, params)
    self._id = params.id
    self._icons = self._forced_icons or params.icons
    self._n_of_icons = 0
    local gap = 0
    if type(self._icons) == "table" then
        self._n_of_icons = #self._icons
        gap = self._gap * self._n_of_icons
    end
    self._parent_panel = panel
    self._time = params.time or 0
    self._panel = panel:panel({
        name = params.id,
        x = params.x,
        y = params.y,
        w = (64 + gap + (self._icon_size * self._n_of_icons)) * self._scale,
        h = self._icon_size_scaled,
        alpha = 0,
        visible = true
    })
    self._time_bg_box = CreateHUDBGBox(self._panel, {
        x = 0,
        y = 0,
        w = 64 * self._scale,
        h = self._icon_size_scaled
    })
    self._text = self._time_bg_box:text({
        name = "text1",
        text = self:Format(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
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
    if params.dynamic then
        self:SetPanelVisible()
    end
end

function EHITracker:OverridePanel()
end

function EHITracker:PosAndSetVisible(x, y)
    self._panel:set_x(x)
    self._panel:set_y(y)
    self:SetPanelVisible()
end

function EHITracker:SetPanelVisible()
    self._panel:animate(visibility, 0, 1)
end

function EHITracker:SetPanelHidden()
    self._panel:animate(visibility, 1, 0)
end

if EHI:GetOption("show_one_icon") then
    function EHITracker:CreateIcons()
        local icon_pos = self._time_bg_box:w() + self._gap_scaled
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
        local start = self._time_bg_box:w()
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

function EHITracker:SetTop(target_y)
    if self._anim_move then
        self._panel:stop(self._anim_move)
        self._anim_move = nil
    end
    self._anim_move = self._panel:animate(top, target_y)
end

function EHITracker:SetLeft(target_x)
    if self._anim_move then
        self._panel:stop(self._anim_move)
        self._anim_move = nil
    end
    self._anim_move = self._panel:animate(left, target_x)
end

function EHITracker:SetPanelW(target_w)
    if self._anim_set_w then
        self._panel:stop(self._anim_set_w)
        self._anim_set_w = nil
    end
    self._anim_set_w = self._panel:animate(panel_w, target_w)
end

function EHITracker:SetIconX(target_x)
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
else
    EHITracker.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
end

function EHITracker:update(t, dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

function EHITracker:update_fade(t, dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

function EHITracker:ResetFontSize(text)
    text:set_font_size(self._panel:h() * self._text_scale)
end

function EHITracker:FitTheText(text)
    text = text or self._text
    self:ResetFontSize(text)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w) * self._text_scale)
    end
end

function EHITracker:SetTime(time)
    self:SetTimeNoAnim(time)
    self:AnimateBG()
end

function EHITracker:SetTimeNoAnim(time)
    self._time = time
    self._text:set_text(self:Format())
    self:FitTheText()
end

function EHITracker:Run(params)
    self:SetTimeNoAnim(params.time or 0)
    self:SetTextColor()
end

function EHITracker:AddDelay(delay)
    self:SetTime(self._time + delay)
end

function EHITracker:AnimateBG(t)
    local bg = self._time_bg_box:child("bg")
    bg:stop()
    bg:set_color(Color(1, 0, 0, 0))
    bg:animate(bg_attention, t or 3)
end

function EHITracker:SetTextColor(color)
    self._text:set_color(color or self._text_color)
end

function EHITracker:GetIcon(new_icon)
    return GetIcon(new_icon)
end

function EHITracker:SetIcon(new_icon)
    local icon, texture_rect = GetIcon(new_icon)
    if texture_rect then
        self._icon1:set_image(icon, unpack(texture_rect))
    else
        self._icon1:set_image(icon)
    end
end

function EHITracker:SetIconColor(color)
    self._icon1:set_color(color)
end

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

function EHITracker:GetPanelW()
    return self._panel_override_w or self._panel:w()
end

function EHITracker:GetTrackerType()
    return self._tracker_type
end

function EHITracker:destroy(skip)
    if alive(self._panel) and alive(self._parent_panel) then
        if self._icon1 then
            self._icon1:stop()
        end
        self._panel:stop()
        self._panel:animate(function(o)
            if not skip then
                local TOTAL_T = 0.18
                local t = 0
                while TOTAL_T > t do
                    local dt = coroutine.yield()
                    t = math_min(t + dt, TOTAL_T)
                    local lerp = t / TOTAL_T
                    o:set_alpha(math_lerp(1, 0, lerp))
                end
            end
            self._time_bg_box:child("bg"):stop()
            self._parent_panel:remove(self._panel)
        end)
    end
end

function EHITracker:delete()
    if self._hide_on_delete then
        self._panel:stop()
        self:SetPanelHidden()
        self._parent_class:HideTracker(self._id)
        return
    end
    self:destroy()
    self._parent_class:DestroyTracker(self._id)
end

function EHITracker:ForceDelete()
    self._hide_on_delete = nil
    self:delete()
end