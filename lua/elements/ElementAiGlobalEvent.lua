local EHI = EHI
if EHI:CheckLoadHook("ElementAiGlobalEvent") then
    return
end

local original =
{
    client_on_executed = ElementAiGlobalEvent.client_on_executed,
    on_executed = ElementAiGlobalEvent.on_executed
}

local function TriggerEndlessAssault()
    EHI._cache.EndlessAssault = true
    managers.ehi:RemoveTracker("AssaultTime")
    managers.ehi:RemoveTracker("Assault")
end

function ElementAiGlobalEvent:client_on_executed(...)
    original.client_on_executed(self, ...)
    local wave_mode = self._wave_modes[self._values.wave_mode]
    if wave_mode then
        if wave_mode == "hunt" then
            TriggerEndlessAssault()
        --elseif wave_mode == "besiege" then
            --managers.hud:SetNormalAssaultOverride()
        end
    end
end

function ElementAiGlobalEvent:on_executed(...)
    if not self._values.enabled then
        return
    end
    local wave_mode = self._wave_modes[self._values.wave_mode]
    if wave_mode then
        if wave_mode == "hunt" then
            TriggerEndlessAssault()
        --elseif wave_mode == "besiege" then
            --managers.hud:SetNormalAssaultOverride()
        end
    end
    original.on_executed(self, ...)
end