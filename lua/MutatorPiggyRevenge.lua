local EHI = EHI
if EHI:CheckLoadHook("MutatorPiggyRevenge") then
    return
end
local original =
{
    on_game_started = MutatorPiggyRevenge.on_game_started,
    sync_load = MutatorPiggyRevenge.sync_load,
    sync_feed_piggybank = MutatorPiggyRevenge.sync_feed_piggybank,
    sync_explode_piggybank = MutatorPiggyRevenge.sync_explode_piggybank
}
function MutatorPiggyRevenge:on_game_started(...)
    original.on_game_started(self, ...)
    self._xp_tracker_is_visible = EHI:IsXPTrackerVisible()
    dofile(EHI.LuaPath .. "trackers/EHIPiggyBankMutatorTracker.lua")
    managers.ehi_tracker:AddTracker({
        id = "pda10_event",
        revenge = true,
        class = "EHIPiggyBankMutatorTracker"
    })
end

function MutatorPiggyRevenge:sync_load(mutator_manager, load_data, ...)
    original.sync_load(self, mutator_manager, load_data, ...)
    managers.ehi_tracker:CallFunction("pda10_event", "SyncLoad", load_data.piggyrevenge_mutator)
end

function MutatorPiggyRevenge:sync_feed_piggybank(...)
    original.sync_feed_piggybank(self, ...)
    managers.ehi_tracker:SetTrackerProgress("pda10_event", self._pig_fed_count)
end

function MutatorPiggyRevenge:sync_explode_piggybank(...)
    if self._exploded_pig_level then
        return
    end
    original.sync_explode_piggybank(self, ...)
    managers.ehi_tracker:RemoveTracker("pda10_event")
    if self._xp_tracker_is_visible then
        managers.experience:SetPiggyBankExplodedLevel(self._exploded_pig_level)
    end
end