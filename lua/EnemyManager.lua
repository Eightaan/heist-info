local EHI = EHI
if EHI:CheckLoadHook("EnemyManager") then
    return
end

---@return number
function EnemyManager:GetNumberOfEnemies()
    return self._enemy_data.nr_units
end

if not (EHI:GetOption("show_enemy_count_tracker") or EHI:GetOption("show_civilian_count_tracker")) then
    return
end

local original = {}

if EHI:GetOption("show_enemy_count_tracker") then
    original.on_enemy_registered = EnemyManager.on_enemy_registered
    original.on_enemy_unregistered = EnemyManager.on_enemy_unregistered
    dofile(EHI.LuaPath .. "trackers/EHIEnemyCountTracker.lua")
    if EHI:GetOption("show_enemy_count_show_pagers") then
        local alarm_unit = {}
        function EnemyManager:on_enemy_registered(unit, ...)
            original.on_enemy_registered(self, unit, ...)
            if alarm_unit[unit:base()._tweak_table] then
                managers.ehi_tracker:CallFunction("EnemyCount", "AlarmEnemyRegistered")
            else
                managers.ehi_tracker:CallFunction("EnemyCount", "NormalEnemyRegistered")
            end
        end
        function EnemyManager:on_enemy_unregistered(unit, ...)
            original.on_enemy_unregistered(self, unit, ...)
            if alarm_unit[unit:base()._tweak_table] then
                managers.ehi_tracker:CallFunction("EnemyCount", "AlarmEnemyUnregistered")
            else
                managers.ehi_tracker:CallFunction("EnemyCount", "NormalEnemyUnregistered")
            end
        end
        for name, data in pairs(tweak_data.character) do
            if type(data) == "table" and data.has_alarm_pager then
                alarm_unit[name] = true
            end
        end
        EHI:AddOnAlarmCallback(function()
            managers.ehi_tracker:CallFunction("EnemyCount", "Alarm")
        end)
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            local enemy_data = managers.enemy._enemy_data
            local enemy_counted = managers.ehi_tracker:ReturnValue("EnemyCount", "GetEnemyCount") or -1
            if enemy_data.nr_units == enemy_counted then
                return
            end
            managers.ehi_tracker:CallFunction("EnemyCount", "ResetCounter")
            for _, data in pairs(enemy_data.unit_data or {}) do
                if alarm_unit[data.unit:base()._tweak_table] then
                    managers.ehi_tracker:CallFunction("EnemyCount", "AlarmEnemyRegistered")
                else
                    managers.ehi_tracker:CallFunction("EnemyCount", "NormalEnemyRegistered")
                end
            end
        end)
    else
        function EnemyManager:on_enemy_registered(...)
            original.on_enemy_registered(self, ...)
            managers.ehi_tracker:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
        end
        function EnemyManager:on_enemy_unregistered(...)
            original.on_enemy_unregistered(self, ...)
            managers.ehi_tracker:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
        end
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            managers.ehi_tracker:SetTrackerCount("EnemyCount", managers.enemy:GetNumberOfEnemies())
        end)
    end
end

if EHI:GetOption("show_civilian_count_tracker") then
    local function CreateTracker(count)
        managers.ehi_tracker:AddTracker({
            id = "CivilianCount",
            count = count,
            flash_times = 1,
            icons = { "civilians" },
            class = EHI.Trackers.Counter
        })
    end
    local function CivilianDied(civilian_data, from_destroy)
        if managers.ehi_tracker:TrackerExists("CivilianCount") then
            local count = managers.ehi_tracker:ReturnValue("CivilianCount", "GetCount")
            if count <= 1 then
                managers.ehi_tracker:RemoveTracker("CivilianCount")
            else
                managers.ehi_tracker:DecreaseTrackerCount("CivilianCount")
            end
        else
            local civilians_alive = table.size(civilian_data.unit_data) - (from_destroy and 1 or 0)
            if civilians_alive > 1 then
                CreateTracker(civilians_alive)
            end
        end
    end
    original.register_civilian = EnemyManager.register_civilian
    function EnemyManager:register_civilian(...)
        original.register_civilian(self, ...)
        if managers.ehi_tracker:TrackerExists("CivilianCount") then
            managers.ehi_tracker:IncreaseTrackerCount("CivilianCount")
        else
            CreateTracker(table.size(self._civilian_data.unit_data))
        end
    end

    original.on_civilian_died = EnemyManager.on_civilian_died
    function EnemyManager:on_civilian_died(...)
        original.on_civilian_died(self, ...)
        CivilianDied(self._civilian_data)
    end

    original.on_civilian_destroyed = EnemyManager.on_civilian_destroyed
    function EnemyManager:on_civilian_destroyed(civilian, ...)
        if self._civilian_data.unit_data[civilian:key()] then
            CivilianDied(self._civilian_data, true)
        end
        original.on_civilian_destroyed(self, civilian, ...)
    end
    EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
        local count = table.size(managers.enemy._civilian_data.unit_data)
        if count <= 0 then
            managers.ehi_tracker:RemoveTracker("CivilianCount")
        elseif managers.ehi_tracker:TrackerExists("CivilianCount") then
            managers.ehi_tracker:CallFunction("CivilianCount", "ResetCounter")
            managers.ehi_tracker:SetTrackerCount("CivilianCount", count)
        else
            CreateTracker(count)
        end
    end)
end