local EHI = EHI
if EHI:CheckLoadHook("MissionEndState") then
    return
end

local original =
{
    at_enter = MissionEndState.at_enter
}
function MissionEndState:at_enter(...)
    EHI:CallCallbackOnce(EHI.CallbackMessage.MissionEnd, self._success)
    original.at_enter(self, ...)
    managers.ehi_tracker:HidePanel()
end