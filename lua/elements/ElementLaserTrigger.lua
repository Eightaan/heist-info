local EHI = EHI
if EHI:CheckLoadHook("ElementLaserTrigger") then
    return
end

if not EHI:GetOption("show_laser_tracker") then
    return
end

EHILaserTracker = class(EHITracker)
EHILaserTracker._forced_icons = { EHI.Icons.Lasers }
function EHILaserTracker:init(panel, params)
    self._next_cycle_t = params.time
    EHILaserTracker.super.init(self, panel, params)
end

function EHILaserTracker:update(t, dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self._time = self._next_cycle_t
    end
end

function EHILaserTracker:UpdateInterval(t)
    self._time = t
end

function EHILaserTracker:delete()
    self._parent_class:RemoveLaser(self._id)
    EHILaserTracker.super.delete(self)
end

local original =
{
    init = ElementLaserTrigger.init,
    add_callback = ElementLaserTrigger.add_callback,
    remove_callback = ElementLaserTrigger.remove_callback,
    load = ElementLaserTrigger.load
}

function ElementLaserTrigger:init(...)
    original.init(self, ...)
    self._ehi_id = self._id .. "_laser"
end

function ElementLaserTrigger:add_callback(...)
    if not self._callback and self._is_cycled then
        managers.ehi:AddLaserTracker({
            id = self._ehi_id,
            time = self._values.cycle_interval,
            class = "EHILaserTracker"
        })
    end
    original.add_callback(self, ...)
end

function ElementLaserTrigger:remove_callback(...)
    original.remove_callback(self, ...)
	managers.ehi:RemoveTracker(self._ehi_id)
end

function ElementLaserTrigger:load(...)
    original.load(self, ...)
    managers.ehi:CallFunction(self._ehi_id, "UpdateInterval", self._next_cycle_t)
end