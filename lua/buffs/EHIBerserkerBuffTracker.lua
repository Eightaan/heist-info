local EHI = EHI
local player_manager
local math_max = math.max
local THRESHOLD = tweak_data.upgrades.player_damage_health_ratio_threshold or 0.5
EHIBerserkerBuffTracker = class(EHIGaugeBuffTracker)
EHIBerserkerBuffTracker._refresh_time = 1 / EHI:GetBuffOption("berserker_refresh")
function EHIBerserkerBuffTracker:init(panel, params)
    EHIBerserkerBuffTracker.super.init(self, panel, params)
    self._time = 0.2
    self._damage_multiplier = 0
    self._melee_damage_multiplier = 0
    self._current_damage_multiplier = 0
    self._current_melee_damage_multiplier = 0
end

function EHIBerserkerBuffTracker:PreUpdate()
    player_manager = managers.player
    if player_manager:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0) == 0 then
        return
    end
    local function f(state)
        self:SetCustody(state)
    end
    EHI:AddOnCustodyCallback(f)
    self._damage_multiplier = player_manager:upgrade_value('player', 'damage_health_ratio_multiplier', 0)
    self._melee_damage_multiplier = player_manager:upgrade_value('player', 'melee_damage_health_ratio_multiplier', 0)
    self._parent_class:AddBuffToUpdate(self._id, self)
end

function EHIBerserkerBuffTracker:SetCustody(state)
    if state then
        self._parent_class:RemoveBuffFromUpdate(self._id)
        self:Deactivate()
    else
        self:Activate()
        self._time = self._refresh_time
        self._parent_class:AddBuffToUpdate(self._id, self)
    end
end

function EHIBerserkerBuffTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:UpdateMultipliers()
        self._time = self._refresh_time
    end
end

function EHIBerserkerBuffTracker:UpdateMultipliers()
    local player_unit = player_manager:player_unit()
    if not player_unit then
        return
    end
    local character_damage = player_unit:character_damage()
    if not character_damage then
        return
    end
    local health_ratio = character_damage:health_ratio()
    if health_ratio and health_ratio <= THRESHOLD then
        local damage_ratio = 1 - (health_ratio / math_max(0.01, THRESHOLD))
        self._current_melee_damage_multiplier = 1 + self._melee_damage_multiplier * damage_ratio
        self._current_damage_multiplier = 1 + self._damage_multiplier * damage_ratio
        local mul = self._current_damage_multiplier * self._current_melee_damage_multiplier
        if mul > 1 then
            self:ActivateSoft()
            self:SetRatio(damage_ratio)
        else
            self:DeactivateSoft()
        end
    else
        self:DeactivateSoft()
    end
end

function EHIBerserkerBuffTracker:SetRatio(ratio)
    if self._ratio == ratio then
        return
    end
    EHIBerserkerBuffTracker.super.SetRatio(self, ratio)
end

function EHIBerserkerBuffTracker:Activate()
    self._active = true
end

function EHIBerserkerBuffTracker:ActivateSoft()
    if self._visible then
        return
    end
    self._panel:stop()
    self._panel:animate(self._show)
    self._parent_class:AddVisibleBuff(self._id)
    self._visible = true
end

function EHIBerserkerBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:DeactivateSoft()
    self._active = false
    self._progress:set_color(Color(1, 0, 1, 1)) -- No need to animate this because the panel is no longer visible
end

function EHIBerserkerBuffTracker:DeactivateSoft()
    if not self._visible then
        return
    end
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
    self._panel:stop()
    self._panel:animate(self._hide)
    self._visible = false
end

function EHIBerserkerBuffTracker:Format()
    local dmg = EHI:RoundNumber(self._current_damage_multiplier, 0.1)
    local mdmg = EHI:RoundNumber(self._current_melee_damage_multiplier, 0.1)
    local s = (dmg > 1 and dmg .. "x" or "") .. (dmg > 1 and (mdmg > 1 and " " .. mdmg .. "x" or "") or (mdmg > 1 and mdmg .. "x" or ""))
    return s
end