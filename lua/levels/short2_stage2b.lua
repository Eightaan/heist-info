local EHI = EHI
local triggers =
{
    [100806] = { time = 62 + 24, id = "HeliEscape", icons = EHI.Icons.HeliEscape }
}

EHI:ParseTriggers({ mission = triggers })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 13000
    }
})