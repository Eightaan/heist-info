local EHI = EHI
if EHI:CheckLoadHook("InteractionExt") then
    return
end

if EHI:GetOption("show_pager_callback") then
    EHIPagerTracker = class(EHIWarningTracker)
    EHIPagerTracker._forced_icons = { "pager_icon" }
    function EHIPagerTracker:init(panel, params)
        params.time = 12
        EHIPagerTracker.super.init(self, panel, params)
    end

    function EHIPagerTracker:SetAnswered()
        self:RemoveTrackerFromUpdate()
        self._text:stop()
        self:SetTextColor(Color.green)
        self:AnimateBG()
    end

    function EHIPagerTracker:delete()
        self._parent_class:RemovePager(self._id)
        EHIPagerTracker.super.delete(self)
    end

    EHIPagerWaypoint = class(EHIWarningWaypoint)
    function EHIPagerWaypoint:SetAnswered()
        self:RemoveWaypointFromUpdate()
        self:StopAnim()
        self:SetColor(Color.green)
    end

    function EHIPagerWaypoint:StopAnim()
        self._timer:stop()
        self._bitmap:stop()
        self._arrow:stop()
        if self._bitmap_world then
            self._bitmap_world:stop()
        end
    end

    local show_waypoint = EHI:GetWaypointOption("show_waypoints_pager")
    local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")
    EHI:HookWithID(IntimitateInteractionExt, "init", "EHI_pager_init", function(self, unit, ...)
        self._ehi_key = "pager_" .. tostring(unit:key())
    end)

    EHI:HookWithID(IntimitateInteractionExt, "set_tweak_data", "EHI_pager_set_tweak_data", function(self, id)
        if id == "corpse_alarm_pager" and not self._pager_has_run then
            if not show_waypoint_only then
                managers.ehi:AddPagerTracker(self._ehi_key)
            end
            if show_waypoint then
                managers.ehi_waypoint:AddPagerWaypoint({
                    id = self._ehi_key,
                    time = 12,
                    texture = "guis/textures/pd2/specialization/icons_atlas",
                    text_rect = {64, 256, 64, 64},
                    position = self._unit:position(),
                    warning = true,
                    class = "EHIPagerWaypoint"
                })
            end
            self._pager_has_run = true
        end
    end)

    EHI:PreHookWithID(IntimitateInteractionExt, "interact", "EHI_pager_interact", function(self, ...)
        if self.tweak_data == "corpse_alarm_pager" then
            managers.ehi:RemoveTracker(self._ehi_key)
            managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
        end
    end)

    EHI:HookWithID(IntimitateInteractionExt, "_at_interact_start", "EHI_pager_at_interact_start", function(self, ...)
        if self.tweak_data == "corpse_alarm_pager" then
            managers.ehi:CallFunction(self._ehi_key, "SetAnswered")
            managers.ehi_waypoint:CallFunction(self._ehi_key, "SetAnswered")
        end
    end)

    EHI:PreHookWithID(IntimitateInteractionExt, "sync_interacted", "EHI_pager_sync_interacted", function(self, peer, player, status, ...)
        if self.tweak_data == "corpse_alarm_pager" then
            if status == "started" or status == 1 then
                managers.ehi:CallFunction(self._ehi_key, "SetAnswered")
                managers.ehi_waypoint:CallFunction(self._ehi_key, "SetAnswered")
            else -- complete or interrupted
                managers.ehi:RemoveTracker(self._ehi_key)
                managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
            end
        end
    end)

    EHI:AddOnAlarmCallback(function()
        EHI:Unhook("pager_init")
        EHI:Unhook("pager_set_tweak_data")
        EHI:Unhook("pager_interact")
        EHI:Unhook("pager_at_interact_start")
        EHI:Unhook("pager_sync_interacted")
    end)
end

if EHI:GetOption("show_enemy_count_tracker") and EHI:GetOption("show_enemy_count_show_pagers") then
    local CallbackKey = "EnemyCount"
    local function PagerEnemyKilled(unit)
        managers.ehi:CallFunction(CallbackKey, "AlarmEnemyPagerKilled")
        unit:base():remove_destroy_listener(CallbackKey)
        unit:character_damage():remove_listener(CallbackKey)
    end

    EHI:HookWithID(IntimitateInteractionExt, "_at_interact_start", "EHI_EnemyCounter_pager_at_interact_start", function(self, ...)
        if self.tweak_data == "corpse_alarm_pager" and not self._unit:character_damage():dead() then
            managers.ehi:CallFunction(CallbackKey, "AlarmEnemyPagerAnswered")
            self._unit:base():add_destroy_listener(CallbackKey, PagerEnemyKilled)
            self._unit:character_damage():add_listener(CallbackKey, { "death" }, PagerEnemyKilled)
        end
    end)

    EHI:PreHookWithID(IntimitateInteractionExt, "sync_interacted", "EHI_EnemyCounter_pager_sync_interacted", function(self, peer, player, status, ...)
        if self.tweak_data == "corpse_alarm_pager" then
            if (status == "started" or status == 1) and not self._unit:character_damage():dead() then
                managers.ehi:CallFunction(CallbackKey, "AlarmEnemyPagerAnswered")
                self._unit:base():add_destroy_listener(CallbackKey, PagerEnemyKilled)
                self._unit:character_damage():add_listener(CallbackKey, { "death" }, PagerEnemyKilled)
            end
        end
    end)

    EHI:AddOnAlarmCallback(function()
        EHI:Unhook("EnemyCounter_pager_at_interact_start")
        EHI:Unhook("EnemyCounter_pager_sync_interacted")
    end)
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

local all = EHI:GetOption("show_equipment_aggregate_all")

local function set_active(self, ...)
    self._ehi_active = self._active
end

if EHI:GetOption("show_equipment_ammobag") then
    EHI:PreHook(AmmoBagInteractionExt, "init", function(self, unit, ...)
        self._ehi_key = unit:base():GetEHIKey()
        self._tracker_id = all and "Deployables" or "AmmoBags"
    end)

    EHI:PreHook(AmmoBagInteractionExt, "set_active", set_active)

    EHI:Hook(AmmoBagInteractionExt, "set_active", function(self, ...)
        if self._ehi_active ~= self._active then
            if self._active then -- Active
                if self._unit:base():GetRealAmount() > 0 then -- The unit is active now, load it from cache and show it on screen
                    managers.ehi:LoadFromDeployableCache(self._tracker_id, self._ehi_key)
                end
            else -- Not Active
                if self._unit:base():GetRealAmount() > 0 then -- There is some ammo in the unit, let's cache the unit
                    if all then
                        managers.ehi:AddToDeployableCache(self._tracker_id, self._ehi_key, self._unit, "ammo_bag")
                    else
                        managers.ehi:AddToDeployableCache(self._tracker_id, self._ehi_key, self._unit)
                    end
                end
            end
            self._ehi_active = self._active
        end
    end)

    EHI:Hook(AmmoBagInteractionExt, "destroy", function(self, ...)
        managers.ehi:RemoveFromDeployableCache(self._tracker_id, self._ehi_key)
    end)
end

if EHI:GetOption("show_equipment_bodybags") then
    EHI:PreHook(BodyBagsBagInteractionExt, "init", function(self, unit, ...)
        self._ehi_key = unit:base():GetEHIKey()
        self._tracker_id = all and "Deployables" or "BodyBags"
    end)

    EHI:PreHook(BodyBagsBagInteractionExt, "set_active", set_active)

    EHI:Hook(BodyBagsBagInteractionExt, "set_active", function(self, ...)
        if self._ehi_active ~= self._active then
            if self._active then -- Active
                if self._unit:base():GetRealAmount() > 0 and managers.groupai:state():whisper_mode() then -- The unit is active now, load it from cache and show it on screen
                    managers.ehi:LoadFromDeployableCache(self._tracker_id, self._ehi_key)
                end
            else -- Not Active
                if self._unit:base():GetRealAmount() > 0 then -- There are some body bags in the unit, let's cache the unit
                    if all then
                        managers.ehi:AddToDeployableCache("Deployables", self._ehi_key, self._unit, "bodybags_bag")
                    else
                        managers.ehi:AddToDeployableCache(self._tracker_id, self._ehi_key, self._unit)
                    end
                end
            end
            self._ehi_active = self._active
        end
    end)

    EHI:Hook(BodyBagsBagInteractionExt, "destroy", function(self, ...)
        managers.ehi:RemoveFromDeployableCache(self._tracker_id, self._ehi_key)
    end)
end

if EHI:GetOption("show_equipment_doctorbag") or EHI:GetOption("show_equipment_firstaidkit") then
    local aggregate = EHI:GetOption("show_equipment_aggregate_health")
    EHI:PreHook(DoctorBagBaseInteractionExt, "init", function(self, unit, ...)
        self._ehi_key = unit:base().GetEHIKey and unit:base():GetEHIKey()
        self._ehi_tweak = self.tweak_data == "first_aid_kit" and "FirstAidKits" or "DoctorBags"
        self._ehi_unit_tweak = self.tweak_data == "first_aid_kit" and "first_aid_kit" or "doctor_bag"
        if all then
            self._tracker_id = "Deployables"
        elseif aggregate then
            self._tracker_id = "Health"
        else
            self._tracker_id = self._ehi_tweak
        end
    end)

    EHI:PreHook(DoctorBagBaseInteractionExt, "set_active", set_active)

    EHI:Hook(DoctorBagBaseInteractionExt, "set_active", function(self, ...)
        if self._ehi_active ~= self._active then
            if self._active then -- Active
                if self._unit:base().GetRealAmount and self._unit:base():GetRealAmount() > 0 then -- The unit is active now, load it from cache and show it on screen
                    managers.ehi:LoadFromDeployableCache(self._tracker_id, self._ehi_key)
                end
            else -- Not Active
                if self._unit:base().GetRealAmount and self._unit:base():GetRealAmount() > 0 then -- There are some charges left in the unit, let's cache the unit
                    if aggregate or all then
                        managers.ehi:AddToDeployableCache(self._tracker_id, self._ehi_key, self._unit, self._ehi_unit_tweak)
                    else
                        managers.ehi:AddToDeployableCache(self._ehi_tweak, self._ehi_key, self._unit)
                    end
                end
            end
            self._ehi_active = self._active
        end
    end)

    EHI:Hook(DoctorBagBaseInteractionExt, "destroy", function(self, ...)
        managers.ehi:RemoveFromDeployableCache(self._tracker_id, self._ehi_key)
    end)
end