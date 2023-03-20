local EHI = EHI
if EHI:CheckLoadHook("PlayerInventory") then
    return
end

if EHI:GetBuffAndOption("hacker") then
    local buff_original =
    {
        _start_jammer_effect = PlayerInventory._start_jammer_effect,
        _start_feedback_effect = PlayerInventory._start_feedback_effect
    }
    function PlayerInventory:_start_jammer_effect(end_time, ...)
        local result = buff_original._start_jammer_effect(self, end_time, ...)
        end_time = end_time or self:get_jammer_time()
        if end_time ~= 0 and managers.player:player_unit() == self._unit and result then
            managers.ehi_buff:AddBuff("HackerJammerEffect", end_time)
        end
        return result
    end

    function PlayerInventory:_start_feedback_effect(end_time, ...)
        local result = buff_original._start_feedback_effect(self, end_time, ...)
        end_time = end_time or self:get_jammer_time()
        if end_time ~= 0 and managers.player:player_unit() == self._unit and result then
            managers.ehi_buff:AddBuff("HackerFeedbackEffect", end_time)
        end
        return result
    end
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

local jammer = EHI:GetOption("show_equipment_ecmjammer")

if not jammer then
    return
end

local original =
{
    load = PlayerInventory.load
}

function PlayerInventory:load(load_data, ...)
    original.load(self, load_data, ...)
    local my_load_data = load_data.inventory
    if not my_load_data then
        return
    end
    local jammer_data = my_load_data._jammer_data
    if jammer_data and jammer_data.effect == "jamming" and jammer then
        local peer = managers.network:session():peer_by_unit(self._unit)
        local peer_id = peer and peer:id() or 0
        if managers.ehi:TrackerExists("ECMJammer") then
            managers.ehi:CallFunction("ECMJammer", "SetTimeIfLower", jammer_data.t, peer_id)
        else
            managers.ehi:AddTracker({
                id = "ECMJammer",
                time = jammer_data.t,
                icons = { { icon = "ecm_jammer", color = EHI:GetPeerColorByPeerID(peer_id) } },
                class = "EHIECMTracker"
            })
        end
    end
end

original._start_jammer_effect = PlayerInventory._start_jammer_effect
function PlayerInventory:_start_jammer_effect(end_time, ...)
    local result = original._start_jammer_effect(self, end_time, ...)
    if result ~= true then
        return result
    end
    end_time = end_time or self:get_jammer_time()
    if end_time == 0 then
        return result
    end
    local peer = managers.network:session():peer_by_unit(self._unit)
    local peer_id = peer and peer:id() or 0
    if managers.ehi:TrackerExists("ECMJammer") then
        managers.ehi:CallFunction("ECMJammer", "SetTimeIfLower", end_time, peer_id)
    else
        managers.ehi:AddTracker({
            id = "ECMJammer",
            time = end_time,
            icons = { { icon = "ecm_jammer", color = EHI:GetPeerColorByPeerID(peer_id) } },
            class = "EHIECMTracker"
        })
    end
    return result
end