EHIEquipmentTracker = class(EHITracker)
EHIEquipmentTracker._update = false
function EHIEquipmentTracker:init(panel, params)
    self._format = params.format or "charges"
    self._dont_show_placed = params.dont_show_placed or false
    self._amount = 0
    self._placed = 0
    self._deployables = {}
    EHIEquipmentTracker.super.init(self, panel, params)
end

do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return EHI:RoundNumber(self._amount, 0.01) .. " (" .. self._placed .. ")"
            else
                if self._dont_show_placed then
                    return self._amount
                else
                    return self._amount .. " (" .. self._placed .. ")"
                end
            end
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return "(" .. self._placed .. ") " .. EHI:RoundNumber(self._amount, 0.01)
            else
                if self._dont_show_placed then
                    return self._amount
                else
                    return "(" .. self._placed .. ") " .. self._amount
                end
            end
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return "(" .. EHI:RoundNumber(self._amount, 0.01) .. ") " .. self._placed
            else
                if self._dont_show_placed then
                    return self._amount
                else
                    return "(" .. self._amount .. ") " .. self._placed
                end
            end
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return self._placed .. "(" .. EHI:RoundNumber(self._amount, 0.01) .. ")"
            else
                if self._dont_show_placed then
                    return self._amount
                else
                    return self._placed .. " (" .. self._amount .. ")"
                end
            end
        end
    elseif format == 5 then -- Uses
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return EHI:RoundNumber(self._amount, 0.01)
            else
                return tostring(self._amount)
            end
        end
    else -- Bags placed
        function EHIEquipmentTracker:Format()
            if self._dont_show_placed then
                if self._format == "percent" then
                    return tostring(EHI:RoundNumber(self._amount, 0.01))
                end
                return tostring(self._amount)
            else
                return tostring(self._placed)
            end
        end
    end
end

function EHIEquipmentTracker:UpdateAmount(unit, key, amount)
    if not key then
        EHI:DebugEquipment(self._id, unit, key, amount)
        return
    end
    self._deployables[key] = amount
    self._amount = 0
    self._placed = 0
    for _, value in pairs(self._deployables) do
        if value > 0 then
            self._amount = self._amount + value
            self._placed = self._placed + 1
        end
    end
    if self._amount <= 0 then
        self:delete()
    else
        self._text:set_text(self:Format())
        self:FitTheText()
        self:AnimateBG()
    end
end