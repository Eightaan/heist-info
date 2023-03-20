local EHI = EHI
EHI:ShowLootCounter({ max = 18 })

local MissionDoorPositions =
{
    [1] = Vector3(5636.56, 7026.42, -1877.75),
    [2] = Vector3(5743.57, 5743.44, -1877.75),
    [3] = Vector3(5260.62, 5334.95, -1890.75),
    [4] = Vector3(-4420.84, -4693.55, -1877.75),
    [5] = Vector3(-3930.91, -4684.99, -1877.75),
    [6] = Vector3(-4313.83, -5976.53, -1877.75)
}
local MissionDoorIndex =
{
    [1] = { w_id = EHI:GetInstanceElementID(100006, 0) },
    [2] = { w_id = EHI:GetInstanceElementID(100006, 250) },
    [3] = { w_id = EHI:GetInstanceElementID(100006, 500) },
    [4] = { w_id = EHI:GetInstanceElementID(100006, 750) },
    [5] = { w_id = EHI:GetInstanceElementID(100006, 1000) },
    [6] = { w_id = EHI:GetInstanceElementID(100006, 1250) }
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)