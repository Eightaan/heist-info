local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local triggers = {
    [100931] = { time = 23 },
    [104910] = { time = 24 },
    [100842] = { time = 50, id = "Lasers", icons = { Icon.Lasers }, class = TT.Warning }
}

EHI:ParseTriggers({ mission = triggers }, "Escape", Icon.HeliEscapeNoLoot)
EHI:AddXPBreakdown({
    objective =
    {
        ff3_item_deployed = { amount = 300, stealth = true },
        ff3_cocaine_placed = { amount = 1000, stealth = true },
        ff3_gold_secured = { amount = 1000, stealth = true },
        pc_found = { amount = 8000, loud = true },
        pc_hack = { amount = 8000, loud = true },
        escape =
        {
            { amount = 2000, stealth = true },
            { amount = 8000, loud = true }
        }
    },
    no_total_xp = true
})