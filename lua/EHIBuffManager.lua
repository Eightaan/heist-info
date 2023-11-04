local EHI = EHI
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

local buff_w = 32
local buff_h = 64
---@class EHIBuffManager
EHIBuffManager = {}
function EHIBuffManager:new()
    self._buffs = {} ---@type table<string, EHIBuffTracker?>
    self._update_buffs = setmetatable({}, {__mode = "k"}) ---@type table<string, EHIBuffTracker?>
    if EHI:IsVR() then
        self._x = EHI:GetOption("buffs_vr_x_offset")
        self._y = EHI:GetOption("buffs_vr_y_offset")
    else
        self._x = EHI:GetOption("buffs_x_offset")
        self._y = EHI:GetOption("buffs_y_offset")
    end
    self._scale = EHI:GetOption("buffs_scale")
    buff_w = buff_w * self._scale
    buff_h = buff_h * self._scale
    self._visible_buffs = {}
    self._n_visible = 0
    self._cache = {}
    self._gap = 6
    return self
end

function EHIBuffManager:init_finalize(hud)
    local path = EHI.LuaPath .. "buffs/"
    dofile(path .. "EHIBuffTracker.lua")
    dofile(path .. "EHIGaugeBuffTracker.lua")
    dofile(path .. "EHIDodgeChanceBuffTracker.lua")
    dofile(path .. "EHIBikerBuffTracker.lua")
    dofile(path .. "EHIMeleeChargeBuffTracker.lua")
    dofile(path .. "EHIUppersRangeBuffTracker.lua")
    dofile(path .. "EHIBerserkerBuffTracker.lua")
    dofile(path .. "EHICritChanceBuffTracker.lua")
    dofile(path .. "SimpleBuffEdits.lua")
    self._panel = hud.panel
    self:InitializeBuffs()
    self:InitializeTagTeamBuffs()
    EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(self, self, "ActivateUpdatingBuffs"))
    EHI:AddOnCustodyCallback(callback(self, self, "RemoveAbilityCooldown"))
    if EHI:IsClient() then
        Hooks:Add("NetworkReceivedData", "NetworkReceivedData_EHIBuff", function(_, id, data)
            if id == EHI.SyncMessages.EHISyncAddBuff then
                local tbl = LuaNetworking:StringToTable(data)
                self:AddBuff(tbl.id, tonumber(tbl.t) or 0)
            end
        end)
    end
end

function EHIBuffManager:InitializeBuffs()
    local tweak = tweak_data.ehi.buff
    for id, buff in pairs(tweak) do
        if not buff.option or EHI:GetBuffOption(buff.option) then
            local params = {}
            params.id = id
            params.x = self._x
            params.y = self._y
            params.w = buff_w
            params.h = buff_h
            params.text = buff.text
            params.texture, params.texture_rect = GetIcon(buff)
            params.format = buff.format
            params.good = not buff.bad
            params.no_progress = buff.no_progress
            params.max = buff.max
            params.class = buff.class
            params.scale = self._scale
            params.persistent = buff.persistent
            params.parent_class = self
            self:CreateBuff(params)
        end
    end
end

function EHIBuffManager:InitializeTagTeamBuffs()
    if not EHI:GetBuffOption("tag_team") then
        return
    end
    local local_peer_id = managers.network:session():local_peer():id()
    local texture, texture_rect = GetIcon(tweak_data.ehi.buff.TagTeamEffect)
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        if i ~= local_peer_id then -- You cannot tag yourself...
            local params = {}
            params.id = "TagTeamTagged_" .. i .. local_peer_id
            params.x = self._x
            params.y = self._y
            params.w = buff_w
            params.h = buff_h
            params.texture = texture
            params.texture_rect = texture_rect
            params.good = true
            params.icon_color = tweak_data.chat_colors[i] or Color.white
            params.scale = self._scale
            params.parent_class = self
            self:CreateBuff(params)
        end
    end
end

---@param params table
function EHIBuffManager:CreateBuff(params)
    local buff = _G[params.class or "EHIBuffTracker"]:new(self._panel, params) --[[@as EHIBuffTracker]]
    self._buffs[params.id] = buff
    if params.persistent and EHI:GetBuffOption(params.persistent) then
        buff:SetPersistent()
    end
end

---@param id string
function EHIBuffManager:UpdateBuffIcon(id)
    local tweak = tweak_data.ehi.buff[id]
    local buff = self._buffs[id]
    if buff and tweak then
        local texture, texture_rect = GetIcon(tweak)
        buff:UpdateIcon(texture, texture_rect)
    end
end

---@param id string
---@param f string
---@param ... unknown
function EHIBuffManager:CallFunction(id, f, ...)
    local buff = self._buffs[id]
    if buff and buff[f] then
        buff[f](buff, ...)
    end
end

---@param id string
---@param t number
function EHIBuffManager:SyncBuff(id, t)
    EHI:SyncTable(EHI.SyncMessages.EHISyncAddBuff, { id = id, t = t })
end

function EHIBuffManager:ActivateUpdatingBuffs()
    for id, buff in pairs(tweak_data.ehi.buff) do
        if buff.activate_after_spawn then
            local b = self._buffs[id]
            if b and b:PreUpdateCheck() then
                b:PreUpdate()
                self:AddBuffToUpdate(id, b)
            end
        elseif buff.check_after_spawn then
            local b = self._buffs[id]
            if b and b:PreUpdateCheck() then
                b:PreUpdate()
            end
        end
    end
end

---@param id string
---@param t number
function EHIBuffManager:AddBuff(id, t)
    local buff = self._buffs[id]
    if buff then
        if buff:IsActive() then
            buff:Extend(t)
        else
            buff:Activate(t, self._n_visible)
            self._visible_buffs[id] = true
            self._n_visible = self._n_visible + 1
            self:ReorganizeFast(buff)
        end
    end
end

---@param id string
---@param start_t number
---@param end_t number
function EHIBuffManager:AddBuff2(id, start_t, end_t)
    local t = end_t - start_t
    self:AddBuff(id, t)
end

---To stop moving buffs left and right on the screen
---@param id string
---@param start_t number
---@param end_t number
function EHIBuffManager:AddBuff3(id, start_t, end_t)
    local t = end_t - start_t + 0.2
    self:AddBuff(id, t)
end

---@param id string
function EHIBuffManager:AddBuffNoUpdate(id)
    local buff = self._buffs[id]
    if buff and not buff:IsActive() then
        buff:ActivateNoUpdate(self._n_visible)
        self._visible_buffs[id] = true
        self._n_visible = self._n_visible + 1
        self:ReorganizeFast(buff)
    end
end

---@param id string
---@param ratio number
---@param custom_value number?
function EHIBuffManager:AddGauge(id, ratio, custom_value)
    local buff = self._buffs[id] --[[@as EHIGaugeBuffTracker]]
    if buff then
        if buff:IsActive() then
            buff:SetRatio(ratio, custom_value)
        else
            buff:Activate(ratio, custom_value, self._n_visible)
            self._visible_buffs[id] = true
            self._n_visible = self._n_visible + 1
            self:ReorganizeFast(buff)
        end
    end
end

---@param id string
function EHIBuffManager:RemoveBuff(id)
    local buff = self._buffs[id]
    if buff and buff:IsActive() then
        buff:Deactivate()
    end
end

---@param id string
---@param t number
function EHIBuffManager:AppendTime(id, t)
    local buff = self._buffs[id]
    if buff then
        buff:Append(t)
    end
end

---@param id string
---@param t number
---@param max number
function EHIBuffManager:AppendTimeCeil(id, t, max)
    local buff = self._buffs[id]
    if buff then
        buff:AppendCeil(t, max)
    end
end

---@param id string
---@param t number
function EHIBuffManager:ShortenBuffTime(id, t)
    local buff = self._buffs[id]
    if buff then
        buff:Shorten(t)
    end
end

---@param id string
---@param buff EHIBuffTracker
function EHIBuffManager:AddVisibleBuff(id, buff)
    self._visible_buffs[id] = true
    buff:SetPos(self._n_visible)
    self._n_visible = self._n_visible + 1
    self:ReorganizeFast(buff)
end

---@param id string
---@param pos number?
function EHIBuffManager:RemoveVisibleBuff(id, pos)
    self._visible_buffs[id] = nil
    self._n_visible = self._n_visible - 1
    self:Reorganize(pos)
end

---@param id string
---@param buff EHIBuffTracker
function EHIBuffManager:AddBuffToUpdate(id, buff)
    self._update_buffs[id] = buff
end

---@param id string
function EHIBuffManager:RemoveBuffFromUpdate(id)
    self._update_buffs[id] = nil
end

---@param in_custody boolean
function EHIBuffManager:RemoveAbilityCooldown(in_custody)
    if in_custody then
        local ability = self._cache.Ability
        if ability then
            self:RemoveBuff(ability)
        end
    end
end

---@param t number
---@param dt number
function EHIBuffManager:update(t, dt)
    for _, buff in pairs(self._update_buffs) do
        buff:update(t, dt)
    end
end

local alignment = EHI:GetOption("buffs_alignment")
if alignment == 1 then -- Left
    ---@param pos number?
    function EHIBuffManager:Reorganize(pos)
        if self._n_visible == 0 then
            return
        end
        pos = pos or self._n_visible
        for key, _ in pairs(self._visible_buffs) do
            local buff = self._buffs[key] --[[@as EHIBuffTracker]]
            buff:SetLeftXByPos(self._x, pos)
        end
    end

    ---@param buff EHIBuffTracker
    function EHIBuffManager:ReorganizeFast(buff)
        buff:SetLeftXByPos(self._x, self._n_visible)
    end
elseif alignment == 2 then -- Center
    local ceil = math.ceil
    local floor = math.floor
    ---@param pos number?
    function EHIBuffManager:Reorganize(pos)
        if self._n_visible == 0 then
            return
        elseif self._n_visible == 1 then
            local key, _ = next(self._visible_buffs)
            local buff = self._buffs[key] --[[@as EHIBuffTracker]]
            buff:SetCenterX(self._panel:center_x())
            buff:SetPos(0)
        else
            local even = self._n_visible % 2 == 0
            local center_pos = even and ceil(self._n_visible / 2) or floor(self._n_visible / 2)
            local center_x = self._panel:center_x()
            pos = pos or self._n_visible
            for key, _ in pairs(self._visible_buffs) do
                local buff = self._buffs[key] --[[@as EHIBuffTracker]]
                buff:SetCenterX(center_x)
                buff:SetCenterXByPos(pos, center_pos, even)
            end
        end
    end

    ---@param id string
    ---@param t number
    function EHIBuffManager:AddBuff(id, t)
        local buff = self._buffs[id]
        if buff then
            if buff:IsActive() then
                buff:Extend(t)
            else
                buff:Activate(t, self._n_visible)
                self._visible_buffs[id] = true
                self._n_visible = self._n_visible + 1
                self:Reorganize()
            end
        end
    end

    ---@param id string
    function EHIBuffManager:AddBuffNoUpdate(id)
        local buff = self._buffs[id]
        if buff and not buff:IsActive() then
            buff:ActivateNoUpdate(self._n_visible)
            self._visible_buffs[id] = true
            self._n_visible = self._n_visible + 1
            self:Reorganize()
        end
    end

    ---@param id string
    ---@param ratio number
    ---@param custom_value number?
    function EHIBuffManager:AddGauge(id, ratio, custom_value)
        local buff = self._buffs[id] --[[@as EHIGaugeBuffTracker]]
        if buff then
            if buff:IsActive() then
                buff:SetRatio(ratio, custom_value)
            else
                buff:Activate(ratio, custom_value, self._n_visible)
                self._visible_buffs[id] = true
                self._n_visible = self._n_visible + 1
                self:Reorganize()
            end
        end
    end

    ---@param id string
    ---@param buff EHIBuffTracker
    function EHIBuffManager:AddVisibleBuff(id, buff)
        self._visible_buffs[id] = true
        buff:SetPos(self._n_visible)
        self._n_visible = self._n_visible + 1
        self:Reorganize()
    end
else -- Right
    ---@param pos number?
    function EHIBuffManager:Reorganize(pos)
        if self._n_visible == 0 then
            return
        end
        pos = pos or self._n_visible
        for key, _ in pairs(self._visible_buffs) do
            local buff = self._buffs[key] --[[@as EHIBuffTracker]]
            buff:SetRightXByPos(self._x, pos)
        end
    end

    ---@param buff EHIBuffTracker
    function EHIBuffManager:ReorganizeFast(buff)
        buff:SetRightXByPos(self._x, self._n_visible)
    end
end