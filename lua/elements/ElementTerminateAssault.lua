local EHI = EHI
if EHI:CheckLoadHook("ElementTerminateAssault") then
    return
end

local valid = false
if EHI:CombineAssaultDelayAndAssaultTime() or EHI:GetOption("show_assault_delay_tracker") or EHI:GetOption("show_assault_time_tracker") then
    valid = true
end
if not valid then
    return
end

local original =
{
    on_executed = ElementTerminateAssault.on_executed,
    client_on_executed = ElementTerminateAssault.client_on_executed
}

local function Block()
    local state = managers.groupai:state()
	if not state.terminate_assaults then
        return
	end
    managers.ehi_tracker:CallFunction("Assault", "PoliceActivityBlocked")
    managers.ehi_tracker:CallFunction("AssaultDelay", "PoliceActivityBlocked")
    managers.ehi_tracker:CallFunction("AssaultTime", "PoliceActivityBlocked")
end

function ElementTerminateAssault:client_on_executed(...)
    original.client_on_executed(self, ...)
    Block()
end

function ElementTerminateAssault:on_executed(...)
    if not self._values.enabled then
		return
	end
    original.on_executed(self, ...)
    Block()
end