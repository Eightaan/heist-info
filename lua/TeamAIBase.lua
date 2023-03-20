local EHI = EHI
if EHI:CheckLoadHook("TeamAIBase") then
    return
end

if not EHI:GetBuffAndOption("regen_throwable_ai") then
    return
end

local original =
{
    set_loadout = TeamAIBase.set_loadout,
    remove_upgrades = TeamAIBase.remove_upgrades
}

local value = tweak_data.upgrades.values.team.crew_throwable_regen
local max = (value and value[1] or 35) + 1
local progress = 0

local function IncreaseProgress(...)
    progress = progress + 1
    if progress == max then
        progress = 0
    end
    managers.ehi_buff:AddGauge2("crew_throwable_regen", progress / max, progress)
end

function TeamAIBase:set_loadout(loadout, ...)
    original.set_loadout(self, loadout, ...)
    if not loadout then
        return
    end
    if loadout.skill == "crew_generous" then
        progress = managers.player._throw_regen_kills or 0
        managers.ehi_buff:AddGauge2("crew_throwable_regen", progress / max, progress)
        managers.player:register_message(Message.OnEnemyKilled, "EHI_crew_throwable_regen", IncreaseProgress)
    end
end

function TeamAIBase:remove_upgrades(...)
    if not self._loadout then
        original.remove_upgrades(self, ...)
        return
    end
    if self._loadout.skill == "crew_generous" then
        managers.ehi_buff:RemoveBuff("crew_throwable_regen")
        managers.player:unregister_message(Message.OnEnemyKilled, "EHI_crew_throwable_regen")
    end
    original.remove_upgrades(self, ...)
end