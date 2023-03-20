local EHI = EHI
if EHI:CheckLoadHook("Setup") then
    return
end

local original =
{
    init_managers = Setup.init_managers,
    init_finalize = Setup.init_finalize,
    destroy = Setup.destroy
}

function Setup:init_managers(managers, ...)
    original.init_managers(self, managers, ...)
    managers.ehi = EHIManager:new()
    managers.ehi_waypoint = EHIWaypointManager:new()
    managers.ehi_buff = EHIBuffManager:new()
    EHI:CallCallbackOnce(EHI.CallbackMessage.InitManagers, managers)
end

function Setup:init_finalize(...)
    original.init_finalize(self, ...)
    managers.ehi:init_finalize()
    managers.ehi_waypoint:init_finalize()
end

function Setup:destroy(...)
    original.destroy(self, ...)
    managers.ehi:destroy()
end