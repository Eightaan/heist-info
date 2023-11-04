local EHI = EHI
if EHI:CheckLoadHook("InteractionExt") then
    return
end

if EHI:GetOption("show_pager_callback") then
    ---@class EHIPagerTracker : EHIWarningTracker
    ---@field super EHIWarningTracker
    EHIPagerTracker = class(EHIWarningTracker)
    EHIPagerTracker._forced_icons = { "pager_icon" }
    EHIPagerTracker._forced_time = 12
    function EHIPagerTracker:SetAnswered()
        self:RemoveTrackerFromUpdate()
        self._text:stop()
        self:SetTextColor(Color.green)
        self:AnimateBG()
    end

    ---@class EHIPagerWaypoint : EHIWarningWaypoint
    ---@field super EHIWarningWaypoint
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

    local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_pager")
    EHI:HookWithID(IntimitateInteractionExt, "init", "EHI_pager_init", function(self, unit, ...)
        self._ehi_key = "pager_" .. tostring(unit:key())
    end)

    EHI:HookWithID(IntimitateInteractionExt, "set_tweak_data", "EHI_pager_set_tweak_data", function(self, id)
        if id == "corpse_alarm_pager" and not self._pager_has_run then
            if not show_waypoint_only then
                managers.ehi_tracker:AddPagerTracker(self._ehi_key)
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
            managers.ehi_manager:RemovePager(self._ehi_key)
        end
    end)

    EHI:HookWithID(IntimitateInteractionExt, "_at_interact_start", "EHI_pager_at_interact_start", function(self, ...)
        if self.tweak_data == "corpse_alarm_pager" then
            managers.ehi_manager:Call(self._ehi_key, "SetAnswered")
        end
    end)

    EHI:PreHookWithID(IntimitateInteractionExt, "sync_interacted", "EHI_pager_sync_interacted", function(self, peer, player, status, ...)
        if self.tweak_data == "corpse_alarm_pager" then
            if status == "started" or status == 1 then
                managers.ehi_manager:Call(self._ehi_key, "SetAnswered")
            else -- complete or interrupted
                managers.ehi_manager:RemovePager(self._ehi_key)
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
        managers.ehi_tracker:CallFunction(CallbackKey, "AlarmEnemyPagerKilled")
        unit:base():remove_destroy_listener(CallbackKey)
        unit:character_damage():remove_listener(CallbackKey)
    end

    EHI:HookWithID(IntimitateInteractionExt, "_at_interact_start", "EHI_EnemyCounter_pager_at_interact_start", function(self, ...)
        if self.tweak_data == "corpse_alarm_pager" and not self._unit:character_damage():dead() then
            managers.ehi_tracker:CallFunction(CallbackKey, "AlarmEnemyPagerAnswered")
            self._unit:base():add_destroy_listener(CallbackKey, PagerEnemyKilled)
            self._unit:character_damage():add_listener(CallbackKey, { "death" }, PagerEnemyKilled)
        end
    end)

    EHI:PreHookWithID(IntimitateInteractionExt, "sync_interacted", "EHI_EnemyCounter_pager_sync_interacted", function(self, peer, player, status, ...)
        if self.tweak_data == "corpse_alarm_pager" then
            if (status == "started" or status == 1) and not self._unit:character_damage():dead() then
                managers.ehi_tracker:CallFunction(CallbackKey, "AlarmEnemyPagerAnswered")
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

local function StealthCheck()
    return managers.groupai:state():whisper_mode()
end

local function pre_set_active(self, ...)
    self._ehi_active = self._active
end

local function post_set_active(self, ...)
    if self._ehi_active ~= self._active then
        if self._active then -- Active
            if self._unit:base().GetRealAmount and self._unit:base():GetRealAmount() > 0 and (not self._ehi_load_check or self._ehi_load_check()) then -- The unit is active now, load it from cache and show it on screen
                managers.ehi_deployable:LoadFromDeployableCache(self._ehi_tracker_id, self._ehi_key)
            end
        else -- Not Active
            if self._unit:base().GetRealAmount and self._unit:base():GetRealAmount() > 0 then -- There is some amount left in the unit, let's cache it
                managers.ehi_deployable:AddToDeployableCache(self._ehi_tracker_id, self._ehi_key, self._unit, self._ehi_unit_check and self._ehi_unit)
            end
        end
        self._ehi_active = self._active
    end
end

local function destroy(self, ...)
    managers.ehi_deployable:RemoveFromDeployableCache(self._ehi_tracker_id, self._ehi_key)
end

if EHI:GetOption("show_equipment_ammobag") then
    EHI:PreHook(AmmoBagInteractionExt, "init", function(self, unit, ...)
        self._ehi_key = unit:base():GetEHIKey()
        self._ehi_tracker_id = all and "Deployables" or "AmmoBags"
        self._ehi_unit = "ammo_bag"
        self._ehi_unit_check = all
    end)
    EHI:PreHook(AmmoBagInteractionExt, "set_active", pre_set_active)
    EHI:Hook(AmmoBagInteractionExt, "set_active", post_set_active)
    EHI:Hook(AmmoBagInteractionExt, "destroy", destroy)
end

if EHI:GetOption("show_equipment_bodybags") then
    EHI:PreHook(BodyBagsBagInteractionExt, "init", function(self, unit, ...)
        self._ehi_key = unit:base():GetEHIKey()
        self._ehi_tracker_id = all and "Deployables" or "BodyBags"
        self._ehi_unit = "bodybags_bag"
        self._ehi_load_check = StealthCheck
        self._ehi_unit_check = all
    end)
    EHI:PreHook(BodyBagsBagInteractionExt, "set_active", pre_set_active)
    EHI:Hook(BodyBagsBagInteractionExt, "set_active", post_set_active)
    EHI:Hook(BodyBagsBagInteractionExt, "destroy", destroy)
end

if EHI:GetOption("show_equipment_doctorbag") or EHI:GetOption("show_equipment_firstaidkit") then
    local aggregate = EHI:GetOption("show_equipment_aggregate_health")
    EHI:PreHook(DoctorBagBaseInteractionExt, "init", function(self, unit, ...)
        self._ehi_key = unit:base().GetEHIKey and unit:base():GetEHIKey()
        if all then
            self._ehi_tracker_id = "Deployables"
        elseif aggregate then
            self._ehi_tracker_id = "Health"
        elseif self.tweak_data == "first_aid_kit" then
            self._ehi_tracker_id = "FirstAidKits"
        else
            self._ehi_tracker_id = "DoctorBags"
        end
        self._ehi_unit = self.tweak_data == "first_aid_kit" and "first_aid_kit" or "doctor_bag"
        self._ehi_unit_check = aggregate or all
    end)
    EHI:PreHook(DoctorBagBaseInteractionExt, "set_active", pre_set_active)
    EHI:Hook(DoctorBagBaseInteractionExt, "set_active", post_set_active)
    EHI:Hook(DoctorBagBaseInteractionExt, "destroy", destroy)
end