local color =
{
    doctor_bag = EHI:GetEquipmentColor("doctor_bag"),
    ammo_bag = EHI:GetEquipmentColor("ammo_bag"),
    grenade_crate = EHI:GetEquipmentColor("grenade_crate"),
    first_aid_kit = EHI:GetEquipmentColor("first_aid_kit"),
    bodybags_bag = EHI:GetEquipmentColor("bodybags_bag")
}

---@class EHIAggregatedEquipmentTracker : EHITracker
---@field super EHITracker
EHIAggregatedEquipmentTracker = class(EHITracker)
EHIAggregatedEquipmentTracker._update = false
EHIAggregatedEquipmentTracker._dont_show_placed = { first_aid_kit = true }
EHIAggregatedEquipmentTracker._ids = { "doctor_bag", "ammo_bag", "grenade_crate", "first_aid_kit", "bodybags_bag" }
function EHIAggregatedEquipmentTracker:pre_init(params)
    self._n_of_deployables = 0
    self._amount = {}
    self._placed = {}
    self._deployables = {}
    self._ignore = params.ignore or {}
    self._format = {}
    self.text =
    {
        doctor_bag = false,
        ammo_bag = false,
        grenade_crate = false,
        first_aid_kit = false,
        bodybags_bag = false
    }
    for _, id in ipairs(self._ids) do
        self._amount[id] = 0
        self._placed[id] = 0
        self._deployables[id] = {}
        self._format[id] = params.format[id] or "charges"
    end
end

function EHIAggregatedEquipmentTracker:post_init(params)
    self._default_panel_w = self._panel:w()
    self._default_bg_box_w = self._bg_box:w()
    self._panel_half = self._bg_box:w() / 2
    self._panel_w = self._default_panel_w
    self._bg_box:remove(self._text)
end

do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return EHI:RoundNumber(self._amount[id], 0.1) .. " (" .. self._placed[id] .. ")"
            elseif self._dont_show_placed[id] then
                return self._amount[id]
            end
            return self._amount[id] .. " (" .. self._placed[id] .. ")"
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return "(" .. self._placed[id] .. ") " .. EHI:RoundNumber(self._amount[id], 0.1)
            elseif self._dont_show_placed[id] then
                return self._amount[id]
            end
            return "(" .. self._placed[id] .. ") " .. self._amount[id]
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return "(" .. EHI:RoundNumber(self._amount[id], 0.1) .. ") " .. self._placed[id]
            elseif self._dont_show_placed[id] then
                return self._amount[id]
            end
            return "(" .. self._amount[id] .. ") " .. self._placed[id]
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return self._placed[id] .. " (" .. EHI:RoundNumber(self._amount[id], 0.1) .. ")"
            elseif self._dont_show_placed[id] then
                return self._amount[id]
            end
            return self._placed[id] .. " (" .. self._amount[id] .. ")"
        end
    elseif format == 5 then -- Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return tostring(EHI:RoundNumber(self._amount[id], 0.01))
            end
            return tostring(self._amount[id])
        end
    else -- Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                if self._format[id] == "percent" then
                    return tostring(EHI:RoundNumber(self._amount[id], 0.01))
                end
                return tostring(self._amount[id])
            end
            return tostring(self._placed[id])
        end
    end
end

function EHIAggregatedEquipmentTracker:GetTotalAmount()
    local amount = 0
    for _, count in pairs(self._amount) do
        amount = amount + count
    end
    return amount
end

function EHIAggregatedEquipmentTracker:AddToIgnore(id)
    self._ignore[id] = true
    self._deployables[id] = {}
    self._amount[id] = 0
    self._placed[id] = 0
    self:CheckAmount(id)
end

function EHIAggregatedEquipmentTracker:UpdateAmount(id, unit, key, amount)
    if not key then
        EHI:DebugEquipment(self._id, unit, key, amount)
        return
    end
    if self._ignore[id] then
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
    self:CheckAmount(id)
end

function EHIAggregatedEquipmentTracker:CheckAmount(id)
    if self:GetTotalAmount() <= 0 then
        self:delete()
    else
        self:UpdateText(id)
    end
end

function EHIAggregatedEquipmentTracker:UpdateText(id)
    if self.text[id] then
        if self._amount[id] <= 0 then
            self:RemoveText(id)
        else
            local text = self._bg_box:child(id) --[[@as PanelText]]
            text:set_text(self:FormatDeployable(id))
            self:FitTheText(text)
        end
        self:AnimateBG()
    elseif not self._ignore[id] then
        if self._amount[id] > 0 then
            self:AddText(id)
            self:AnimateBG()
        end
    end
end

function EHIAggregatedEquipmentTracker:AddText(id)
    self._n_of_deployables = self._n_of_deployables + 1
    local text = self:CreateText({
        name = id,
        color = color[id]
    })
    self.text[id] = true
    text:set_text(self:FormatDeployable(id))
    self:Reorganize(true)
end

function EHIAggregatedEquipmentTracker:RemoveText(id)
    self._bg_box:remove(self._bg_box:child(id))
    self.text[id] = false
    self._n_of_deployables = self._n_of_deployables - 1
    if self._n_of_deployables == 1 then
        for ID, _ in pairs(self.text) do
            local text = self._bg_box:child(ID) --[[@as PanelText?]]
            if text then
                text:set_font_size(self._panel:h() * self._text_scale)
                text:set_x(0)
                text:set_w(self._bg_box:w())
                self:FitTheText(text)
                break
            end
        end
    end
    self:Reorganize()
end

function EHIAggregatedEquipmentTracker:AnimateMovement()
    self:AnimatePanelW(self._panel_w)
    self:ChangeTrackerWidth(self._panel_w)
    self:AnimIconX(self._panel_w - self._icon_size_scaled)
end

function EHIAggregatedEquipmentTracker:AlignTextOnHalfPos()
    local pos = 0
    for _, id in ipairs(self._ids) do
        local text = self._bg_box:child(id) --[[@as PanelText?]]
        if text then
            text:set_w(self._panel_half)
            text:set_x(self._panel_half * pos)
            self:FitTheText(text)
            pos = pos + 1
        end
    end
end

function EHIAggregatedEquipmentTracker:Reorganize(addition)
    if self._n_of_deployables == 1 then
        if true then
            return
        end
        for id, _ in pairs(self.text) do
            local text = self._bg_box:child(id) --[[@as PanelText?]]
            if text then
                text:set_font_size(self._panel:h() * self._text_scale)
                text:set_w(self._icon_size_scaled)
                self:FitTheText(text)
            end
        end
    elseif self._n_of_deployables == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self._panel_w = self._default_panel_w
            self:AnimateMovement()
            self._bg_box:set_w(self._default_bg_box_w)
        end
    elseif addition then
        self._panel_w = self._panel_w + self._panel_half
        self:AnimateMovement()
        self._bg_box:set_w(self._bg_box:w() + self._panel_half)
        self:AlignTextOnHalfPos()
    else
        self._panel_w = self._panel_w - self._panel_half
        self:AnimateMovement()
        self._bg_box:set_w(self._bg_box:w() - self._panel_half)
        self:AlignTextOnHalfPos()
    end
end