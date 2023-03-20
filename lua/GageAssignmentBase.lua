local EHI = EHI
if EHI:CheckLoadHook("GageAssignmentBase") or not EHI:GetOption("show_gage_tracker") then
    return
end

local original =
{
    init = GageAssignmentBase.init
}

function GageAssignmentBase:init(...)
    original.init(self, ...)
    EHI._cache.GagePackages = (EHI._cache.GagePackages or 0) + 1
end