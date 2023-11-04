---@class EHIDeployableManager
---@field IsLoading fun(self: self): boolean VR only (EHIDeployableManagerVR)
---@field AddToLoadQueue fun(self: self, key: string, data: table, f: function, add: boolean?) VR only (EHIDeployableManagerVR)
EHIDeployableManager = {}
---@param ehi_tracker EHITrackerManager
---@return EHIDeployableManager
function EHIDeployableManager:new(ehi_tracker)
    self._trackers = ehi_tracker
    self._deployables = {}
    return self
end

function EHIDeployableManager:init_finalize()
    EHI:AddOnAlarmCallback(callback(self, self, "SwitchToLoudMode"))
end

function EHIDeployableManager:SwitchToLoudMode()
    self._trackers:CallFunction("Deployables", "AddToIgnore", "bodybags_bag")
    self._deployables_ignore = { bodybags_bag = true }
end

---@param params AddTrackerTable
---@param pos integer?
function EHIDeployableManager:AddTracker(params, pos)
    self._trackers:AddTracker(params, pos)
end

---@param id string
---@return EHIAggregatedEquipmentTracker|EHIAggregatedHealthEquipmentTracker|EHIEquipmentTracker?
function EHIDeployableManager:GetTracker(id)
    return self._trackers:GetTracker(id) --[[@as EHIAggregatedEquipmentTracker|EHIAggregatedHealthEquipmentTracker|EHIEquipmentTracker]]
end

---@param id string
function EHIDeployableManager:TrackerDoesNotExist(id)
    return self._trackers:TrackerDoesNotExist(id)
end

---@param id string
function EHIDeployableManager:RemoveTracker(id)
    self._trackers:RemoveTracker(id)
end

---@param type string
---@param key string
---@param unit Unit
---@param tracker_type string?
function EHIDeployableManager:AddToDeployableCache(type, key, unit, tracker_type)
    if not key then
        return
    end
    self._deployables[type] = self._deployables[type] or {}
    self._deployables[type][key] = { unit = unit, tracker_type = tracker_type }
    local tracker = self:GetTracker(type)
    if tracker then
        if tracker_type then
            tracker:UpdateAmount(tracker_type, unit, key, 0) ---@diagnostic disable-line
        else
            tracker:UpdateAmount(unit, key, 0)
        end
    end
end

---@param type string
---@param key string
function EHIDeployableManager:LoadFromDeployableCache(type, key)
    if not key then
        return
    end
    self._deployables[type] = self._deployables[type] or {}
    if self._deployables[type][key] then
        if self:TrackerDoesNotExist(type) then
            self:CreateDeployableTracker(type)
        end
        local deployable = self._deployables[type][key]
        local unit = deployable.unit
        local tracker = self:GetTracker(type)
        if tracker then
            if deployable.tracker_type then
                tracker:UpdateAmount(deployable.tracker_type, unit, key, unit:base():GetRealAmount())
            else
                tracker:UpdateAmount(unit, key, unit:base():GetRealAmount())
            end
        end
        self._deployables[type][key] = nil
    end
end

---@param type string
---@param key string
function EHIDeployableManager:RemoveFromDeployableCache(type, key)
    if not key then
        return
    end
    self._deployables[type] = self._deployables[type] or {}
    self._deployables[type][key] = nil
end

---@param type string
function EHIDeployableManager:CreateDeployableTracker(type)
    if type == "Deployables" then
        self:AddAggregatedDeployablesTracker()
    elseif type == "Health" then
        self:AddAggregatedHealthTracker()
    elseif type == "DoctorBags" then
        self._trackers:AddTracker({
            id = "DoctorBags",
            icons = { "doctor_bag" },
            class = "EHIEquipmentTracker"
        })
    elseif type == "AmmoBags" then
        self._trackers:AddTracker({
            id = "AmmoBags",
            format = "percent",
            icons = { "ammo_bag" },
            class = "EHIEquipmentTracker"
        })
    elseif type == "BodyBags" then
        self._trackers:AddTracker({
            id = "BodyBags",
            icons = { "bodybags_bag" },
            class = "EHIEquipmentTracker"
        })
    elseif type == "FirstAidKits" then
        self._trackers:AddTracker({
            id = "FirstAidKits",
            icons = { "first_aid_kit" },
            dont_show_placed = true,
            class = "EHIEquipmentTracker"
        })
    end
end

function EHIDeployableManager:AddAggregatedDeployablesTracker()
    self._trackers:AddTracker({
        id = "Deployables",
        icons = { "deployables" },
        ignore = self._deployables_ignore or {},
        format = { ammo_bag = "percent" },
        class = "EHIAggregatedEquipmentTracker"
    })
end

function EHIDeployableManager:AddAggregatedHealthTracker()
    self._trackers:AddTracker({
        id = "Health",
        class = "EHIAggregatedHealthEquipmentTracker"
    })
end

---@param id string
---@param f string
---@param ... any
function EHIDeployableManager:CallFunction(id, f, ...)
    self._trackers:CallFunction(id, f, ...)
end