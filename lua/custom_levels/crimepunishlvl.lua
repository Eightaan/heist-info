local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100157] = { time = 60 + 43, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, class = TT.Pausable },
    [101137] = { time = 43, id = "EscapeHeli", special_function = SF.PauseTrackerWithTime },
    [101144] = { time = 43, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, special_function = SF.UnpauseTrackerIfExists }
}

EHI:ParseTriggers({ mission = triggers })