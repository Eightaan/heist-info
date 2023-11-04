---@class EHIHealthRegenBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIHealthRegenBuffTracker = class(EHIBuffTracker)
function EHIHealthRegenBuffTracker:init(panel, params)
    EHIHealthRegenBuffTracker.super.init(self, panel, params)
    local icon = self._panel:child("icon") -- Hostage Taker regen
    self._panel:bitmap({ -- Muscle regen
        name = "icon2",
        texture = "guis/textures/pd2/specialization/icons_atlas",
        texture_rect = {4 * 64, 64, 64, 64},
        color = Color.white,
        x = icon:x(),
        y = icon:y(),
        w = icon:w(),
        h = icon:h()
    })
    self._panel:bitmap({
        name = "icon3",
        texture = tweak_data.hud_icons.skill_5.texture,
        texture_rect = tweak_data.hud_icons.skill_5.texture_rect,
        color = Color.white,
        x = icon:x(),
        y = icon:y(),
        w = icon:w(),
        h = icon:h()
    })
    self:SetIcon("hostage_taker")
end

function EHIHealthRegenBuffTracker:SetIcon(buff)
    if self._buff == buff then
        return
    end
    if buff == "hostage_taker" then
        self._panel:child("icon"):set_visible(true)
        self._panel:child("icon2"):set_visible(false)
        self._panel:child("icon3"):set_visible(false)
    elseif buff == "muscle" then
        self._panel:child("icon2"):set_visible(true)
        self._panel:child("icon"):set_visible(false)
        self._panel:child("icon3"):set_visible(false)
    else -- AIRegen
        self._panel:child("icon3"):set_visible(true)
        self._panel:child("icon2"):set_visible(false)
        self._panel:child("icon"):set_visible(false)
    end
    self._buff = buff
end

---@class EHIStaminaBuffTracker : EHIGaugeBuffTracker, EHIDodgeChanceBuffTracker
---@field super EHIGaugeBuffTracker
EHIStaminaBuffTracker = class(EHIGaugeBuffTracker)
EHIStaminaBuffTracker.Activate = EHIDodgeChanceBuffTracker.Activate
EHIStaminaBuffTracker.Deactivate = EHIDodgeChanceBuffTracker.Deactivate
EHIStaminaBuffTracker.RoundNumber = EHI.RoundNumber
function EHIStaminaBuffTracker:Spawned(max_stamina)
    self:SetMaxStamina(max_stamina)
    self:PreUpdate()
end

function EHIStaminaBuffTracker:PreUpdate()
    self:SetRatio(self._max_stamina)
    self:Activate()
end

function EHIStaminaBuffTracker:SetMaxStamina(value)
    self._max_stamina = value
end

function EHIStaminaBuffTracker:SetRatio(ratio)
    local value = ratio / self._max_stamina
    local rounded = self:RoundNumber(value, 0.01)
    EHIStaminaBuffTracker.super.SetRatio(self, value, rounded)
end

---@class EHIStoicBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIStoicBuffTracker = class(EHIBuffTracker)
function EHIStoicBuffTracker:Activate(t, pos)
    EHIStoicBuffTracker.super.Activate(self, self._auto_shrug or t, pos)
end

function EHIStoicBuffTracker:Extend(t)
    EHIStoicBuffTracker.super.Extend(self, self._auto_shrug or t)
end

function EHIStoicBuffTracker:SetAutoShrug(t)
    self._auto_shrug = t
end

---@class EHIHackerTemporaryDodgeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIHackerTemporaryDodgeBuffTracker = class(EHIBuffTracker)
function EHIHackerTemporaryDodgeBuffTracker:Activate(...)
    EHIHackerTemporaryDodgeBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction("DodgeChance", "ForceUpdate")
end

function EHIHackerTemporaryDodgeBuffTracker:Deactivate()
    EHIHackerTemporaryDodgeBuffTracker.super.Deactivate(self)
    self._parent_class:CallFunction("DodgeChance", "ForceUpdate")
end

---@class EHIUnseenStrikeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIUnseenStrikeBuffTracker = class(EHIBuffTracker)
function EHIUnseenStrikeBuffTracker:Activate(...)
    EHIUnseenStrikeBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction("CritChance", "ForceUpdate")
end

function EHIUnseenStrikeBuffTracker:Deactivate()
    EHIUnseenStrikeBuffTracker.super.Deactivate(self)
    self._parent_class:CallFunction("CritChance", "ForceUpdate")
end

---@class EHIExPresidentBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIExPresidentBuffTracker = class(EHIGaugeBuffTracker)
function EHIExPresidentBuffTracker:PreUpdateCheck()
    return managers.player:has_category_upgrade("player", "armor_health_store_amount")
end

function EHIExPresidentBuffTracker:PreUpdate()
    self._parent_class:AddBuffNoUpdate(self._id)
end

function EHIExPresidentBuffTracker:SetStoredHealthMaxAndUpdateRatio(max, ratio)
    self._stored_health_max = max
    self:SetRatio(nil, ratio)
end

function EHIExPresidentBuffTracker:SetRatio(ratio, custom_value)
    ratio = custom_value / self._stored_health_max
    EHIExPresidentBuffTracker.super.SetRatio(self, ratio, custom_value)
end