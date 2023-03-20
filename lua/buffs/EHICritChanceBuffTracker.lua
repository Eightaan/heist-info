local EHI = EHI
local player_manager
local detection_risk = 0
EHICritChanceBuffTracker = class(EHIGaugeBuffTracker)
EHICritChanceBuffTracker._refresh_time = 1 / EHI:GetBuffOption("crit_refresh")
function EHICritChanceBuffTracker:init(panel, params)
    EHICritChanceBuffTracker.super.init(self, panel, params)
    self._time = self._refresh_time
    self._crit = 0
    self._update_disabled = true
end

function EHICritChanceBuffTracker:UpdateCrit()
    local total = player_manager:critical_hit_chance(detection_risk)
    if self._crit == total then
        return
    end
    if self._persistent or total > 0 then
        self:SetRatio(total)
        self:Activate()
    else
        self:Deactivate()
    end
    self._crit = total
end

function EHICritChanceBuffTracker:ForceUpdate()
    if self._update_disabled then
        return
    end
    self:UpdateCrit()
    self._time = self._refresh_time
end

function EHICritChanceBuffTracker:PreUpdate()
    player_manager = managers.player
    detection_risk = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
    detection_risk = math.round(detection_risk * 100)
    local function f(state)
        self:SetCustody(state)
    end
    EHI:AddOnCustodyCallback(f)
    self._update_disabled = false
    self:SetRatio(0)
end

function EHICritChanceBuffTracker:SetCustody(state)
    if state then
        self._parent_class:RemoveBuffFromUpdate(self._id)
        self._crit = 0
        self:Deactivate()
    else
        self._time = self._refresh_time
        self._parent_class:AddBuffToUpdate(self._id, self)
    end
    self._update_disabled = state
end

function EHICritChanceBuffTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:UpdateCrit()
        self._time = self._refresh_time
    end
end

function EHICritChanceBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._panel:stop()
    self._panel:animate(self._show)
    self._parent_class:AddVisibleBuff(self._id)
end

function EHICritChanceBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
    self._panel:stop()
    self._panel:animate(self._hide)
    self._active = false
end