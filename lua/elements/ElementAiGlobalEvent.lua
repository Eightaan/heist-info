local EHI = EHI
if EHI:CheckLoadHook("ElementAiGlobalEvent") then
    return
end

local original =
{
    client_on_executed = ElementAiGlobalEvent.client_on_executed,
    on_executed = ElementAiGlobalEvent.on_executed
}

local mode = "besiege"

local function NotifyListeners(wave_mode)
    if wave_mode and wave_mode ~= mode then
        if wave_mode ~= "besiege" and wave_mode ~= "hunt" then
            return
        end
        mode = wave_mode
        if wave_mode == "besiege" then
            EHI:CallCallback(EHI.CallbackMessage.AssaultWaveModeChanged, "normal")
        elseif wave_mode == "hunt" then
            EHI:CallCallback(EHI.CallbackMessage.AssaultWaveModeChanged, "endless")
        end
    end
end

function ElementAiGlobalEvent:client_on_executed(...)
    original.client_on_executed(self, ...)
    local wave_mode = self._wave_modes[self._values.wave_mode]
    NotifyListeners(wave_mode)
end

function ElementAiGlobalEvent:on_executed(...)
    if not self._values.enabled then
        return
    end
    local wave_mode = self._wave_modes[self._values.wave_mode]
    NotifyListeners(wave_mode)
    original.on_executed(self, ...)
end