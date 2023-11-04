local EHI = EHI
if EHI:CheckLoadHook("ElementExperience") then
    return
end

local original = ElementExperience.init
function ElementExperience:init(...)
    original(self, ...)
    if self._values.amount and self._values.amount > 0 then
        EHI._cache.XPElement = EHI._cache.XPElement + 1
    end
end

if EHI.debug.gained_experience then
    local on_executed = ElementExperience.on_executed
    function ElementExperience:on_executed(...)
        if not self._values.enabled then
            return
        end
        managers.hud:DebugExperience(self._id, self._editor_name, self._values.amount)
        on_executed(self, ...)
    end
end