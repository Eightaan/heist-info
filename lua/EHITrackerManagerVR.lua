local EHI = EHI
EHITrackerManagerVR = EHITrackerManager
EHITrackerManagerVR.old_new = EHITrackerManager.new
EHITrackerManagerVR.old_PreloadTracker = EHITrackerManager.PreloadTracker
EHITrackerManagerVR.old_AddLaserTracker = EHITrackerManager.AddLaserTracker
EHITrackerManagerVR.old_RemoveLaserTracker = EHITrackerManager.RemoveLaserTracker
function EHITrackerManagerVR:new()
    self:old_new()
    self._is_loading = true
    self._load_callback = {}
    return self
end

function EHITrackerManagerVR:CreateWorkspace()
    local x, y = managers.gui_data:safe_to_full(EHI:GetOption("vr_x_offset"), EHI:GetOption("vr_y_offset"))
    self._x = x
    self._y = y
    self._scale = EHI:GetOption("vr_scale")
end

function EHITrackerManagerVR:ShowPanel()
end

function EHITrackerManagerVR:HidePanel()
end

function EHITrackerManagerVR:SetPanel(panel)
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

function EHITrackerManagerVR:IsLoading()
    return self._is_loading
end

---@param params AddTrackerTable
function EHITrackerManagerVR:PreloadTracker(params)
    if self:IsLoading() then
        self:AddToLoadQueue(params.id, params, callback(self, self, "_PreloadTracker"))
        return
    end
    self:old_PreloadTracker(params)
end

---@param key string
---@param data AddTrackerTable
function EHITrackerManagerVR:_PreloadTracker(key, data)
    self:old_PreloadTracker(data)
end

---@param key string
---@param data table
---@param f function
---@param add boolean?
function EHITrackerManagerVR:AddToLoadQueue(key, data, f, add)
    if add then
        if self._load_callback[key] then
            if self._load_callback[key].table then
                table.insert(self._load_callback[key].table, { data = data, f = f })
            else
                local previous = self._load_callback[key]
                self._load_callback[key] = { table = {
                    { data = previous.data, f = previous.f },
                    { data = data, f = f }
                }}
            end
        else
            self._load_callback[key] = { table = { { data = data, f = f } } }
        end
    else
        self._load_callback[key] = { data = data, f = f }
    end
end

---@param params table
function EHITrackerManagerVR:AddLaserTracker(params)
    if self:IsLoading() then
        self:AddToLoadQueue(params.id, params, callback(self, self, "_AddLaserTracker"))
        return
    end
    self:old_AddLaserTracker(params)
end

---@param key string
---@param params table
function EHITrackerManagerVR:_AddLaserTracker(key, params)
    self:old_AddLaserTracker(params)
end

---@param id string
function EHITrackerManagerVR:RemoveLaserTracker(id)
    if self:IsLoading() then
        self._load_callback[id] = nil
        return
    end
    self:old_RemoveLaserTracker(id)
end