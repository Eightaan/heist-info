local EHI = EHI
if EHI:CheckLoadHook("ECMJammerBase") or not EHI:GetOption("show_equipment_tracker") then
    return
end

local BlockECMsWithoutPagerBlocking = EHI:GetOption("ecmjammer_block_ecm_without_pager_delay")
local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_ecmjammer")
local WWaypoint = EHI.Waypoints.Warning

local original =
{
    spawn = ECMJammerBase.spawn,
    set_server_information = ECMJammerBase.set_server_information,
    set_owner = ECMJammerBase.set_owner,
    sync_setup = ECMJammerBase.sync_setup,
    destroy = ECMJammerBase.destroy
}

function ECMJammerBase.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
    local unit = original.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
    unit:base():SetPeerID(peer_id)
	return unit
end

function ECMJammerBase:set_server_information(peer_id, ...)
    original.set_server_information(self, peer_id, ...)
    self:SetPeerID(peer_id)
end

function ECMJammerBase:sync_setup(upgrade_lvl, peer_id, ...)
    original.sync_setup(self, upgrade_lvl, peer_id, ...)
    self:SetPeerID(peer_id)
end

function ECMJammerBase:set_owner(...)
    original.set_owner(self, ...)
    self:SetPeerID(self._owner_id or 0)
    managers.ehi_tracker:CallFunction("ECMJammer", "UpdateOwnerID", self._ehi_peer_id)
    managers.ehi_tracker:CallFunction("ECMFeedback", "UpdateOwnerID", self._ehi_peer_id)
end

function ECMJammerBase:SetPeerID(peer_id)
    local id = peer_id or 0
    self._ehi_peer_id = id
    self._ehi_local_peer = id == managers.network:session():local_peer():id()
end

if EHI:GetOption("show_equipment_ecmjammer") then
    original.set_active = ECMJammerBase.set_active
    function ECMJammerBase:set_active(active, ...)
        original.set_active(self, active, ...)
        if active then
            local battery_life = self:battery_life()
            if battery_life == 0 then
                return
            end
            local jam_pagers = false
            if self._ehi_local_peer then
				jam_pagers = managers.player:has_category_upgrade("ecm_jammer", "affects_pagers")
			elseif self._ehi_peer_id ~= 0 then
                local peer = managers.network:session():peer(self._ehi_peer_id)
                if peer and peer._unit and peer._unit.base then
                    jam_pagers = peer._unit:base():upgrade_value("ecm_jammer", "affects_pagers")
                end
			end
            if BlockECMsWithoutPagerBlocking and not jam_pagers then
                return
            end
            if not show_waypoint_only then
                if managers.ehi_tracker:TrackerExists("ECMJammer") then
                    managers.ehi_tracker:CallFunction("ECMJammer", "SetTimeIfLower", battery_life, self._ehi_peer_id, self._unit)
                else
                    managers.ehi_tracker:AddTracker({
                        id = "ECMJammer",
                        time = battery_life,
                        icons = { { icon = "ecm_jammer", color = EHI:GetPeerColorByPeerID(self._ehi_peer_id) } },
                        unit = self._unit,
                        class = "EHIECMTracker"
                    })
                end
            end
            if show_waypoint then
                local body = self._unit:get_object(Idstring("g_ecm"))
                managers.ehi_waypoint:AddWaypoint(tostring(self._unit:key()), {
                    time = battery_life,
                    icon = "ecm_jammer",
                    position = body and body:position() or self._position,
                    class = WWaypoint
                })
            end
        end
    end
end

if EHI:GetOption("show_equipment_ecmfeedback") then
    original._set_feedback_active = ECMJammerBase._set_feedback_active
    function ECMJammerBase:_set_feedback_active(state, ...)
        original._set_feedback_active(self, state, ...)
        if state and self._feedback_duration then
            if managers.ehi_tracker:TrackerExists("ECMFeedback") then
                managers.ehi_tracker:CallFunction("ECMFeedback", "SetTimeIfLower", self._feedback_duration, self._ehi_peer_id, self._unit)
            else
                managers.ehi_tracker:AddTracker({
                    id = "ECMFeedback",
                    time = self._feedback_duration,
                    icons = { { icon = "ecm_feedback", color = EHI:GetPeerColorByPeerID(self._ehi_peer_id) } },
                    unit = self._unit,
                    class = "EHIECMTracker"
                })
            end
        end
    end
end

function ECMJammerBase:destroy(...)
    original.destroy(self, ...)
    managers.ehi_tracker:CallFunction("ECMJammer", "Destroyed", self._unit)
    managers.ehi_tracker:CallFunction("ECMFeedback", "Destroyed", self._unit)
    managers.ehi_waypoint:RemoveWaypoint(tostring(self._unit:key()))
end