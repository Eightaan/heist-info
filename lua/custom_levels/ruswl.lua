local EHI = EHI
local Icon = EHI.Icons
local obj_delay = { time = 30, id = "ObjectiveDelay", icons = { Icon.Wait } }
local triggers = {
    [100404] = obj_delay,
    [100405] = obj_delay,
    [101181] = { time = 30, id = "ChemSetReset", icons = { Icon.Loop } },
    [101182] = { time = 30, id = "ChemSetCooking", icons = { Icon.Methlab } },
    [101088] = { time = 84, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot }
}

EHI:ParseTriggers({ mission = triggers })