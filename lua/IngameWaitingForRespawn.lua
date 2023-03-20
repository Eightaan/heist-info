local EHI = EHI
if EHI:CheckLoadHook("IngameWaitingForRespawnState") then
    return
end

local original =
{
    at_enter = IngameWaitingForRespawnState.at_enter,
    finish_trade = IngameWaitingForRespawnState.finish_trade
}

function IngameWaitingForRespawnState:at_enter(...)
    original.at_enter(self, ...)
    EHI:RunOnCustodyCallback(true)
end

function IngameWaitingForRespawnState:finish_trade(...)
    original.finish_trade(self, ...)
    EHI:RunOnCustodyCallback(false)
end