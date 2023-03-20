local EHI = EHI
local Icon = EHI.Icons
local triggers = {
    [100114] = { time = 17 * 18, id = "Thermite", icons = { Icon.Fire } },
    [100138] = { time = 20, id = "ObjectiveWait", icons = { Icon.Wait } }
}

EHI:ParseTriggers({ mission = triggers })
EHI:ShowLootCounter({ max = 20 })