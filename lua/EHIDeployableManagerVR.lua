EHIDeployableManagerVR = EHIDeployableManager
EHIDeployableManagerVR.old_AddToDeployableCache = EHIDeployableManager.AddToDeployableCache
EHIDeployableManagerVR.old_LoadFromDeployableCache = EHIDeployableManager.LoadFromDeployableCache
EHIDeployableManagerVR.old_RemoveFromDeployableCache = EHIDeployableManager.RemoveFromDeployableCache
function EHIDeployableManagerVR:IsLoading()
    return self._trackers:IsLoading()
end

---@param key string
---@param data table
---@param f function
---@param add boolean
function EHIDeployableManagerVR:AddToLoadQueue(key, data, f, add)
    self._trackers:AddToLoadQueue(key, data, f, add)
end

---@param key string
---@param data table
function EHIDeployableManagerVR:ReturnLoadCall(key, data)
    self[data.f](self, data.type, key, data.unit, data.tracker_type)
end

---@param type string
---@param key string
---@param unit Unit
---@param tracker_type string
function EHIDeployableManagerVR:AddToDeployableCache(type, key, unit, tracker_type)
    if key and self:IsLoading() then
        self:AddToLoadQueue(key, { type = type, unit = unit, tracker_type = tracker_type, f = "AddToDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_AddToDeployableCache(type, key, unit, tracker_type)
end

---@param type string
---@param key string
function EHIDeployableManagerVR:LoadFromDeployableCache(type, key)
    if key and self:IsLoading() then
        self:AddToLoadQueue(key, { type = type, f = "LoadFromDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_LoadFromDeployableCache(type, key)
end

---@param type string
---@param key string
function EHIDeployableManagerVR:RemoveFromDeployableCache(type, key)
    if key and self:IsLoading() then
        self:AddToLoadQueue(key, { type = type, f = "RemoveFromDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_RemoveFromDeployableCache(type, key)
end