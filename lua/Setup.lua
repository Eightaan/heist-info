local EHI = EHI
EHI._cache.is_vr = _G.IS_VR
if EHI:CheckLoadHook("Setup") then
    return
end
dofile(EHI.LuaPath .. "EHITrackerManager.lua")
dofile(EHI.LuaPath .. "EHIWaypointManager.lua")
dofile(EHI.LuaPath .. "EHIBuffManager.lua")
dofile(EHI.LuaPath .. "EHIDeployableManager.lua")
if EHI:IsVR() then
    dofile(EHI.LuaPath .. "EHITrackerManagerVR.lua")
    dofile(EHI.LuaPath .. "EHIDeployableManagerVR.lua")
end
dofile(EHI.LuaPath .. "EHITradeManager.lua")
dofile(EHI.LuaPath .. "EHIEscapeChanceManager.lua")
dofile(EHI.LuaPath .. "EHIManager.lua")

local original =
{
    init_managers = Setup.init_managers,
    init_finalize = Setup.init_finalize
}

function Setup:init_managers(managers, ...)
    original.init_managers(self, managers, ...)
    managers.ehi_tracker = EHITrackerManager:new()
    managers.ehi_waypoint = EHIWaypointManager:new()
    managers.ehi_buff = EHIBuffManager:new()
    managers.ehi_trade = EHITradeManager:new(managers.ehi_tracker)
    managers.ehi_escape = EHIEscapeChanceManager:new(managers.ehi_tracker)
    managers.ehi_deployable = EHIDeployableManager:new(managers.ehi_tracker)
    managers.ehi_manager = EHIManager:new(managers.ehi_tracker, managers.ehi_waypoint, managers.ehi_escape)
    EHI:CallCallbackOnce(EHI.CallbackMessage.InitManagers, managers)
end

function Setup:init_finalize(...)
    original.init_finalize(self, ...)
    managers.ehi_tracker:init_finalize()
    managers.ehi_deployable:init_finalize()
    managers.ehi_waypoint:init_finalize()
    managers.ehi_manager:init_finalize()
end