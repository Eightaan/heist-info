if not _G.IS_VR then
    return
end

local EHI = EHI
EHIManagerVR = EHIManager
EHIManagerVR.old_init = EHIManager.init
EHIManagerVR.old_AddToDeployableCache = EHIManager.AddToDeployableCache
EHIManagerVR.old_LoadFromDeployableCache = EHIManager.LoadFromDeployableCache
EHIManagerVR.old_RemoveFromDeployableCache = EHIManager.RemoveFromDeployableCache
EHIManagerVR.old_PreloadTracker = EHIManager.PreloadTracker

function EHIManagerVR:init()
    self:old_init()
    self._is_loading = true
    self._load_callback = {}
end

function EHIManagerVR:ShowPanel()
end

function EHIManagerVR:HidePanel()
end

function EHIManagerVR:CreateWorkspace()
    self._scale = EHI:GetOption("vr_scale")
end

function EHIManagerVR:SetPanel(panel)
    self._hud_panel = panel
    self._is_loading = false
    for key, queue in pairs(self._load_callback) do
        if queue.table then
            for _, q in ipairs(queue.table) do
                q.f(key, q.data)
            end
        else
            queue.f(key, queue.data)
        end
    end
    self._load_callback = nil
end

function EHIManagerVR:IsLoading()
    return self._is_loading
end

function EHIManagerVR:PreloadTracker(params)
    if self:IsLoading() then
        self:AddToLoadQueue(params.id, params, callback(self, self, "_PreloadTracker"))
        return
    end
    self:old_PreloadTracker(params)
end

function EHIManagerVR:_PreloadTracker(key, data)
    self:old_PreloadTracker(data)
end

function EHIManagerVR:AddToLoadQueue(key, data, f, add)
    if add then
        if self._load_callback[key] then
            if self._load_callback[key].table then
                table.insert(self._load_callback[key].table, { data = data, f = f })
            else
                local previous = self._load_callback[key]
                self._load_callback[key] = { table = {
                    [1] = { data = previous.data, f = previous.f },
                    [2] = { data = data, f = f }
                }}
            end
        else
            self._load_callback[key] = { table = { [1] = { data = data, f = f } } }
        end
    else
        self._load_callback[key] = { data = data, f = f }
    end
end

function EHIManagerVR:ReturnLoadCall(key, data)
    self[data.f](self, data.type, key, data.unit, data.tracker_type)
end

function EHIManagerVR:AddToDeployableCache(type, key, unit, tracker_type)
    if key and self:IsLoading() then
        self:AddToLoadQueue(key, { type = type, unit = unit, tracker_type = tracker_type, f = "AddToDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_AddToDeployableCache(type, key, unit, tracker_type)
end

function EHIManagerVR:LoadFromDeployableCache(type, key)
    if key and self:IsLoading() then
        self:AddToLoadQueue(key, { type = type, f = "LoadFromDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_LoadFromDeployableCache(type, key)
end

function EHIManagerVR:RemoveFromDeployableCache(type, key)
    if key and self:IsLoading() then
        self:AddToLoadQueue(key, { type = type, f = "RemoveFromDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_RemoveFromDeployableCache(type, key)
end