EHIAggregatedHealthEquipmentTracker = class(EHITracker)
EHIAggregatedHealthEquipmentTracker._update = false
EHIAggregatedHealthEquipmentTracker._pos = { "doctor_bag", "first_aid_kit" }
EHIAggregatedHealthEquipmentTracker._dont_show_placed = { first_aid_kit = true }
EHIAggregatedHealthEquipmentTracker._forced_icons = { { icon = "doctor_bag", visible = false }, { icon = "first_aid_kit", visible = false } }
function EHIAggregatedHealthEquipmentTracker:init(panel, params)
    self._amount = {}
    self._placed = {}
    self._deployables = {}
    for _, id in ipairs(self._pos) do
        self._amount[id] = 0
        self._placed[id] = 0
        self._deployables[id] = {}
    end
    EHIAggregatedHealthEquipmentTracker.super.init(self, panel, params)
end

function EHIAggregatedHealthEquipmentTracker:Format()
    local s = ""
    for _, id in ipairs(self._pos) do
        if self._amount[id] > 0 then
            if s ~= "" then
                s = s .. " | "
            end
            s = s .. self:FormatDeployable(id)
        end
    end
    return s
end

do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIAggregatedHealthEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return self._amount[id]
            else
                return self._amount[id] .. " (" .. self._placed[id] .. ")"
            end
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIAggregatedHealthEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return self._amount[id]
            else
                return "(" .. self._placed[id] .. ") " .. self._amount[id]
            end
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIAggregatedHealthEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return self._amount[id]
            else
                return "(" .. self._amount[id] .. ") " .. self._placed[id]
            end
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIAggregatedHealthEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return self._amount[id]
            else
                return self._placed[id] .. " (" .. self._amount[id] .. ")"
            end
        end
    elseif format == 5 then -- Uses
        function EHIAggregatedHealthEquipmentTracker:FormatDeployable(id)
            return tostring(self._amount[id])
        end
    else -- Bags placed
        function EHIAggregatedHealthEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                return tostring(self._amount[id])
            else
                return tostring(self._placed[id])
            end
        end
    end
end

function EHIAggregatedHealthEquipmentTracker:GetTotalAmount()
    local amount = 0
    for _, count in pairs(self._amount) do
        amount = amount + count
    end
    return amount
end

function EHIAggregatedHealthEquipmentTracker:GetIconPosition(i)
    local start = self._time_bg_box:w()
    local gap = self._gap_scaled
    start = start + (self._icon_size_scaled * i)
    gap = gap + (self._gap_scaled * i)
    return start + gap
end

function EHIAggregatedHealthEquipmentTracker:UpdateIconsVisibility()
    local visibility = {}
    for i = 1, #self._pos, 1 do
        local s_i = tostring(i)
        local icon = self["_icon" .. s_i]
        if icon then
            icon:set_visible(false)
        end
    end
    for i, id in ipairs(self._pos) do
        if self._amount[id] > 0 then
            visibility[#visibility + 1] = i
        end
    end
    local move_x = 1
    local icons = 0
    for _, i in pairs(visibility) do
        local s_i = tostring(i)
        local icon = self["_icon" .. s_i]
        if icon then
            icons = icons + 1
            icon:set_visible(true)
            icon:set_x(self:GetIconPosition(move_x - 1))
        end
        move_x = move_x + 1
    end
    local n = icons
    local panel_w = self._time_bg_box:w()
    self._parent_class:ChangeTrackerWidth(self._id, panel_w + ((self._icon_size_scaled + self._gap_scaled) * n))
end

function EHIAggregatedHealthEquipmentTracker:UpdateAmount(id, unit, key, amount)
    if not key then
        EHI:DebugEquipment(self._id, unit, key, amount)
        return
    end
    self._deployables[id][key] = amount
    self._amount[id] = 0
    self._placed[id] = 0
    for _, value in pairs(self._deployables[id]) do
        if value > 0 then
            self._amount[id] = self._amount[id] + value
            self._placed[id] = self._placed[id] + 1
        end
    end
    if self:GetTotalAmount() <= 0 then
        self:delete()
    else
        self._text:set_text(self:Format())
        self:UpdateIconsVisibility()
        self:FitTheText()
        self:AnimateBG()
    end
end