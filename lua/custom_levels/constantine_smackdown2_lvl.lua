local EHI = EHI
EHI:ShowLootCounter({ max = 18 })

---@type MissionDoorTable
local MissionDoor =
{
    [Vector3(5636.56, 7026.42, -1877.75)] = EHI:GetInstanceElementID(100006, 0),
    [Vector3(5743.57, 5743.44, -1877.75)] = EHI:GetInstanceElementID(100006, 250),
    [Vector3(5260.62, 5334.95, -1890.75)] = EHI:GetInstanceElementID(100006, 500),
    [Vector3(-4420.84, -4693.55, -1877.75)] = EHI:GetInstanceElementID(100006, 750),
    [Vector3(-3930.91, -4684.99, -1877.75)] = EHI:GetInstanceElementID(100006, 1000),
    [Vector3(-4313.83, -5976.53, -1877.75)] = EHI:GetInstanceElementID(100006, 1250)
}
EHI:SetMissionDoorData(MissionDoor)