local EHI = EHI
if EHI:CheckLoadHook("TeamAIBase") or not EHI:GetOption("show_buffs") then
    return
end

local original =
{
    set_loadout = TeamAIBase.set_loadout,
    remove_upgrades = TeamAIBase.remove_upgrades
}

function TeamAIBase:set_loadout(loadout, ...)
    original.set_loadout(self, loadout, ...)
    if not loadout then
        return
    end
    EHI:CallCallback(EHI.CallbackMessage.TeamAISkillBoostChange, loadout.skill or "none", "add")
    EHI:CallCallback(EHI.CallbackMessage.TeamAIAbilityBoostChange, loadout.ability or "none", "add")
end

function TeamAIBase:remove_upgrades(...)
    if not self._loadout then
        original.remove_upgrades(self, ...)
        return
    end
    EHI:CallCallback(EHI.CallbackMessage.TeamAISkillBoostChange, self._loadout.skill or "none", "remove")
    EHI:CallCallback(EHI.CallbackMessage.TeamAIAbilityBoostChange, self._loadout.ability or "none", "remove")
    original.remove_upgrades(self, ...)
end