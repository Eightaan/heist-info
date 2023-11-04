local EHI = EHI
if EHI:CheckLoadHook("Drill") then
    return
end
local original = {}

local function SetAutorepair(unit_key, autorepair)
    managers.ehi_manager:Call(unit_key, "SetAutorepair", autorepair)
end

if EHI:IsHost() then
    original.set_autorepair = Drill.set_autorepair
    function Drill:set_autorepair(...)
        original.set_autorepair(self, ...)
        if self._autorepair == nil then
            return
        end
        SetAutorepair(tostring(self._unit:key()), self._autorepair)
    end
else
    original.on_autorepair = Drill.on_autorepair
    function Drill:on_autorepair(...)
        original.on_autorepair(self, ...)
        SetAutorepair(tostring(self._unit:key()), true)
    end
end