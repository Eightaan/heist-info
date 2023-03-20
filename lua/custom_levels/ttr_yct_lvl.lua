local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local escape_delay = 24
local triggers = {
    [100518] = { time = 60 + escape_delay, id = "EscapeHeliSlow", icons = Icon.HeliEscape, special_function = SF.ExecuteIfElementIsEnabled },
    [100519] = { time = escape_delay, id = "EscapeHeliFast", icons = Icon.HeliEscape, special_function = SF.ExecuteIfElementIsEnabled },
    [100182] = { time = 54, id = "HeliDropC4", icons = Icon.HeliDropC4 }
}

EHI:ParseTriggers({ mission = triggers })