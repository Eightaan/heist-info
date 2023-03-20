local EHI = EHI
if EHI:CheckLoadHook("MutatorCG22") or EHI:IsXPTrackerHidden() then
    return
end

local original =
{
    sync_load = MutatorCG22.sync_load,
    sync_present_sledded = MutatorCG22.sync_present_sledded
}

local function RefreshXPCollected(self)
    local xp_collected = self:get_xp_collected()
    managers.experience:SetCG22EventXPCollected(xp_collected)
end

function MutatorCG22:sync_load(...)
    original.sync_load(self, ...)
    RefreshXPCollected(self)
end

function MutatorCG22:sync_present_sledded(...)
	original.sync_present_sledded(self, ...)
    RefreshXPCollected(self)
end