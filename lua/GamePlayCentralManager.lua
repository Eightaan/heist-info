local EHI = EHI
if EHI:CheckLoadHook("GamePlayCentralManager") then
    return
end

local original =
{
    restart_the_game = GamePlayCentralManager.restart_the_game,
    load = GamePlayCentralManager.load
}

function GamePlayCentralManager:restart_the_game(...)
    EHI:CallCallback(EHI.CallbackMessage.GameRestart)
    original.restart_the_game(self, ...)
end

function GamePlayCentralManager:load(data, ...)
    original.load(self, data, ...)
	local state = data.GamePlayCentralManager
    local heist_timer = state.heist_timer or 0
    managers.ehi:LoadTime(heist_timer)
    managers.ehi_waypoint:LoadTime(heist_timer)
end

function GamePlayCentralManager:GetMissionDisabledUnit(id)
    return self._mission_disabled_units[id]
end

function GamePlayCentralManager:GetMissionEnabledUnit(id)
    return not self:GetMissionDisabledUnit(id)
end