local EHI = EHI
if EHI:CheckLoadHook("Drill") then
    return
end

local function SetAutorepair(unit_key, autorepair)
    managers.ehi:CallFunction(unit_key, "SetAutorepair", autorepair)
    managers.ehi_waypoint:CallFunction(unit_key, "SetAutorepair", autorepair)
end

if EHI:IsHost() then
    local _f_set_autorepair = Drill.set_autorepair
    function Drill:set_autorepair(...)
        _f_set_autorepair(self, ...)
        if self._autorepair == nil then
            return
        end
        SetAutorepair(tostring(self._unit:key()), self._autorepair)
    end
else
    local  _f_on_autorepair = Drill.on_autorepair
    function Drill:on_autorepair(...)
        _f_on_autorepair(self, ...)
        SetAutorepair(tostring(self._unit:key()), true)
    end
end