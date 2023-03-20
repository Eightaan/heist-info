local EHI = EHI
local Icon = EHI.Icons
local triggers = {
    [103712] = { time = 25, id = "HeliTrade", icons = Icon.HeliLootDrop }
}

local other =
{
    [102557] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}

EHI:ParseTriggers({
    mission = triggers,
    other = other
})
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 24)
    end)
end
EHI:AddXPBreakdown({
    objective =
    {
        escape = 2000
    },
    loot_all = 500
})