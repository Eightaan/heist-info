EHIHostageTakerMuscleRegenBuffTracker = class(EHIBuffTracker)
function EHIHostageTakerMuscleRegenBuffTracker:init(panel, params)
    EHIHostageTakerMuscleRegenBuffTracker.super.init(self, panel, params)
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
    self:SetIcon("hostage_taker")
end

function EHIHostageTakerMuscleRegenBuffTracker:SetIcon(buff)
    if self._buff == buff then
        return
    end
    if buff == "hostage_taker" then
        self._panel:child("icon"):set_visible(true)
        self._panel:child("icon2"):set_visible(false)
    else
        self._panel:child("icon2"):set_visible(true)
        self._panel:child("icon"):set_visible(false)
    end
    self._buff = buff
end

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
    self:SetRatio2(value, rounded)
end

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

EHIHackerTemporaryDodgeBuffTracker = class(EHIBuffTracker)
function EHIHackerTemporaryDodgeBuffTracker:Activate(...)
    EHIHackerTemporaryDodgeBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction("DodgeChance", "ForceUpdate")
end

function EHIHackerTemporaryDodgeBuffTracker:Deactivate(...)
    EHIHackerTemporaryDodgeBuffTracker.super.Deactivate(self, ...)
    self._parent_class:CallFunction("DodgeChance", "ForceUpdate")
end

EHIUnseenStrikeBuffTracker = class(EHIBuffTracker)
function EHIUnseenStrikeBuffTracker:Activate(...)
    EHIUnseenStrikeBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction("CritChance", "ForceUpdate")
end

function EHIUnseenStrikeBuffTracker:Deactivate(...)
    EHIUnseenStrikeBuffTracker.super.Deactivate(self, ...)
    self._parent_class:CallFunction("CritChance", "ForceUpdate")
end