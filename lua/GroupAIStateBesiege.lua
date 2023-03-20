local EHI = EHI
if EHI:CheckLoadHook("GroupAIStateBesiege") then
    return
end

local original =
{
    set_phalanx_damage_reduction_buff = GroupAIStateBesiege.set_phalanx_damage_reduction_buff
}

function GroupAIStateBesiege:set_phalanx_damage_reduction_buff(damage_reduction, ...)
    original.set_phalanx_damage_reduction_buff(self, damage_reduction, ...)
    managers.ehi:SetChance("PhalanxDamageReduction", (EHI:RoundChanceNumber(damage_reduction or 0)))
end

if EHI:AssaultDelayTrackerIsEnabled() then
    original._begin_assault_task = GroupAIStateBesiege._begin_assault_task
    function GroupAIStateBesiege:_begin_assault_task(...)
        original._begin_assault_task(self, ...)
        local end_t = self._task_data.assault.phase_end_t
        if end_t ~= 0 then
            local t = end_t - self._t
            managers.ehi:CallFunction("AssaultDelay", "StartAnticipation", t)
            managers.ehi:CallFunction("Assault", "StartAnticipation", t)
        end
    end
end