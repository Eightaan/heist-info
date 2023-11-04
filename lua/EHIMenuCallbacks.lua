local EHI = EHI
function EHIMenu:UpdatePreviewTextVisibility(value)
    self._preview_panel:UpdatePreviewTextVisibility(value)
end

function EHIMenu:SetOption(value, option)
    EHI.settings[option] = value
end

function EHIMenu:SetUnlockableOption(value, option)
    EHI.settings.unlockables[option] = value
end

function EHIMenu:SetBuffOption(value, option)
    EHI.settings.buff_option[option] = value
end

function EHIMenu:SetXPPanelOption(value, option)
    self:UpdateTracker(option, value <= 2)
end

function EHIMenu:SetGagePanelOption(value, option)
    self:UpdateTracker(option, value == 1)
end

function EHIMenu:UpdateTracker(option, value)
    self._preview_panel:UpdateTracker(option, value)
end

function EHIMenu:UpdateEnemyCountTracker(value)
    self._preview_panel:UpdateEnemyCountTracker(value)
end

function EHIMenu:SetFocus2(focus, value)
    self:SetFocus(focus, "show_enemy_count_tracker")
end

function EHIMenu:SetEquipmentColor(color, option)
    local c = EHI.settings.equipment_color[option]
    c.r = color.red
    c.g = color.green
    c.b = color.blue
end

function EHIMenu:UpdateXOffset(x)
    self._preview_panel:UpdateXOffset(x)
end

function EHIMenu:UpdateYOffset(y)
    self._preview_panel:UpdateYOffset(y)
end

function EHIMenu:UpdateTextScale(scale)
    self._preview_panel:UpdateTextScale(scale)
end

function EHIMenu:UpdateScale(scale)
    self._preview_panel:UpdateScale(scale)
end

function EHIMenu:UpdateFormat(format)
    self._preview_panel:UpdateFormat(format)
end

function EHIMenu:UpdateEquipmentFormat(format)
    self._preview_panel:UpdateEquipmentFormat(format)
end

function EHIMenu:UpdateTrackerVisibility(value, option)
    self._preview_panel:Redraw()
    self:SetFocus(value, option)
end

function EHIMenu:UpdateBGVisibility(visibility)
    self._preview_panel:UpdateBGVisibility(visibility)
end

function EHIMenu:UpdateCornerVisibility(visibility)
    self._preview_panel:UpdateCornerVisibility(visibility)
end

function EHIMenu:UpdateIconsVisibility(visibility)
    self._preview_panel:UpdateIconsVisibility(visibility)
end

function EHIMenu:UpdateTrackerAlignment(alignment)
    self._preview_panel:UpdateTrackerAlignment(alignment)
end

function EHIMenu:SetFocus(focus, value)
    self._preview_panel:SetSelected(value)
end

function EHIMenu:fcc_equipment_tracker(focus, ...)
    self:SetFocus(focus, focus and "show_equipment_tracker" or "")
end

function EHIMenu:fcc_equipment_tracker_menu(focus, ...)
    EHI:DelayCall("HighlightDelay", 0.5, function()
        self:SetFocus(focus, focus and "show_equipment_tracker" or "")
    end)
end

function EHIMenu:UpdateMinionTracker(value)
    self._preview_panel:UpdateMinionTracker(value)
end

function EHIMenu:fcc_show_minion_option(focus, ...)
    self:SetFocus(focus, focus and "show_minion_tracker" or "")
end

function EHIMenu:UpdateBuffsVisibility(visibility)
    self._buffs_preview_panel:UpdateBuffs("SetVisibility", visibility)
end

function EHIMenu:UpdateBuffsXOffset(x)
    self._buffs_preview_panel:UpdateXOffset(x)
end

function EHIMenu:UpdateBuffsYOffset(y)
    self._buffs_preview_panel:UpdateYOffset(y)
end

function EHIMenu:UpdateBuffsScale(scale)
    self._buffs_preview_panel:UpdateScale(scale)
end

function EHIMenu:UpdateBuffsAlignment(alignment)
    self._buffs_preview_panel:UpdateAlignment(alignment)
end

function EHIMenu:UpdateBuffsShape(value)
    self._buffs_preview_panel:UpdateBuffs("UpdateBuffShape", value)
end

function EHIMenu:UpdateBuffsProgressVisibility(visibility)
    self._buffs_preview_panel:UpdateBuffs("UpdateProgressVisibility", visibility)
end

function EHIMenu:UpdateBuffsInvertProgress()
    self._buffs_preview_panel:UpdateBuffs("InvertProgress")
end

function EHIMenu:SetColor(color, option, color_type)
    local c = EHI.settings.colors[color_type][option]
    c.r = color.red
    c.g = color.green
    c.b = color.blue
end