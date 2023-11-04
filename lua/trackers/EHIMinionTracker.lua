---@class EHIMinionTracker : EHITracker
---@field super EHITracker
EHIMinionTracker = class(EHITracker)
EHIMinionTracker._forced_icons = { "minion" }
EHIMinionTracker._update = false
function EHIMinionTracker:init(...)
    self._n_of_peers = 0
    self._peers = {}
    EHIMinionTracker.super.init(self, ...)
    self._default_panel_w = self._panel:w()
    self._default_bg_box_w = self._bg_box:w()
    self._panel_half = self._bg_box:w() / 2
    self._panel_w = self._default_panel_w
    self._bg_box_w = self._default_bg_box_w
    self._bg_box:remove(self._text)
end

function EHIMinionTracker:SetTextPeerColor()
    if self._n_of_peers == 1 then
        return
    end
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        if self._bg_box:child("text" .. i) then
            local color = tweak_data.chat_colors[i] or Color.white
            self._bg_box:child("text" .. i):set_color(color)
        end
    end
end

function EHIMinionTracker:SetIconColor()
    if self._n_of_peers >= 2 then
        self._icon1:set_color(Color.white)
    else
        local peer_id, _ = next(self._peers)
        local color = tweak_data.chat_colors[peer_id] or Color.white
        self._icon1:set_color(color)
    end
end

function EHIMinionTracker:Redraw()
    for _, text in ipairs(self._bg_box:children()) do
        if text.set_text then
            self:FitTheText(text)
        end
    end
end

function EHIMinionTracker:AnimateMovement()
    self:AnimatePanelWAndRefresh(self._panel_w)
    self:ChangeTrackerWidth(self._panel_w)
    self:AnimIconX(self._panel_w - self._icon_size_scaled)
end

function EHIMinionTracker:AlignTextOnHalfPos()
    local pos = 0
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        local text = self._bg_box:child("text" .. i)
        if text then
            text:set_w(self._panel_half)
            text:set_x(self._panel_half * pos)
            pos = pos + 1
        end
    end
end

function EHIMinionTracker:Reorganize(addition)
    if self._n_of_peers == 1 then
        if true then
            return
        end
        for i = 0, HUDManager.PLAYER_PANEL, 1 do
            local text = self._bg_box:child("text" .. i) --[[@as PanelText]]
            if text then
                text:set_font_size(self._panel:h() * self._text_scale)
                text:set_w(self._bg_box:w())
                self:FitTheText(text)
                break
            end
        end
    elseif self._n_of_peers == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self._panel_w = self._default_panel_w
            self:AnimateMovement()
            self._bg_box:set_w(self._default_bg_box_w)
        end
    elseif addition then
        self._panel_w = self._panel_w + self._panel_half
        self:AnimateMovement()
        self:SetBGSize(self._panel_half, "add", true)
        self:AlignTextOnHalfPos()
    else
        self._panel_w = self._panel_w - self._panel_half
        self:AnimateMovement()
        self:SetBGSize(self._panel_half, "short", true)
        self:AlignTextOnHalfPos()
    end
end

function EHIMinionTracker:RemovePeer(peer_id)
    if not self._peers[peer_id] then
        return
    end
    self._n_of_peers = self._n_of_peers - 1
    if self._n_of_peers == 0 then
        self:delete()
        return
    end
    self._peers[peer_id] = nil
    self._bg_box:remove(self._bg_box:child("text" .. peer_id))
    if self._n_of_peers == 1 then
        for i = 0, HUDManager.PLAYER_PANEL, 1 do
            local text = self._bg_box:child("text" .. i) --[[@as PanelText?]]
            if text then
                text:set_font_size(self._panel:h() * self._text_scale)
                text:set_color(Color.white)
                text:set_x(0)
                text:set_w(self._bg_box:w())
                self:FitTheText(text)
                break
            end
        end
    end
    self:AnimateBG()
    self:SetIconColor()
    self:SetTextPeerColor()
    self:Reorganize()
end

function EHIMinionTracker:FitTheTextUnique(i)
    self:FitTheText(self._bg_box:child("text" .. i) --[[@as PanelText]])
end

function EHIMinionTracker:FormatUnique(peer_id)
    self._bg_box:child("text" .. peer_id):set_text(tostring(self:GetNumberOfMinions(peer_id)))
end

function EHIMinionTracker:GetNumberOfMinions(peer_id)
    local total = 0
    for _, value in pairs(self._peers[peer_id] or {}) do
        if value > 0 then
            total = total + value
        end
    end
    return total
end

function EHIMinionTracker:AddMinion(unit, key, amount, peer_id)
    if not key then
        EHI:DebugEquipment(self._id, unit, key, amount, peer_id)
        return
    end
    if self._peers[peer_id] then
        self._peers[peer_id][key] = amount
        self:FormatUnique(peer_id)
        self:FitTheTextUnique(peer_id)
        self:AnimateBG()
        return
    end
    self._peers[peer_id] = { [key] = amount }
    self:CreateText({ name = "text" .. peer_id })
    self._n_of_peers = self._n_of_peers + 1
    if self._n_of_peers >= 2 then
        self:AnimateBG()
    end
    self:FormatUnique(peer_id)
    self:FitTheTextUnique(peer_id)
    self:Reorganize(true)
    self:SetIconColor()
    self:SetTextPeerColor()
end

function EHIMinionTracker:RemoveMinion(key)
    if not key then
        return
    end
    for peer, tbl in pairs(self._peers) do
        if tbl[key] then
            tbl[key] = 0
            if self:GetNumberOfMinions(peer) == 0 then
                self:RemovePeer(peer)
            else
                self:FormatUnique(peer)
                self:AnimateBG()
            end
            break
        end
    end
end

function EHIMinionTracker:UpdatePeerColors()
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        if self._bg_box:child("text" .. i) then
            local color = tweak_data.chat_colors[i] or Color.white
            self._bg_box:child("text" .. i):set_color(color)
        end
    end
end