local EHI = EHI
if EHI:CheckLoadHook("PlayerStandard") then
    return
end

if not EHI:GetOption("show_buffs") then
    return
end

local original =
{
    _update_omniscience = PlayerStandard._update_omniscience
}

--///////////////////--
--//  Sixth Sense  //--
--///////////////////--
-- Assume default, recomputed after spawn
local computed_duration_civilian = 4.5
local computed_duration_security = 13.5
local target_resense_delay = tweak_data.player.omniscience.target_resense_t or 15
local sense_latch = false
EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
    local playermanager = managers.player
    local ContourExt = ContourExt
    local tmp = ContourExt._types
    if tmp then
        local multiplier = playermanager:upgrade_value("player", "mark_enemy_time_multiplier", 1)
        local contour_type = playermanager:has_category_upgrade("player", "marked_enemy_extra_damage") and "mark_enemy_damage_bonus" or "mark_enemy"
        tmp = tmp[contour_type]
        if tmp then
            computed_duration_civilian = tmp.fadeout and (tmp.fadeout * multiplier) or 4.5
            computed_duration_security = tmp.fadeout_silent and (tmp.fadeout_silent * multiplier) or 13.5
        end
    end
end)

local DoNotTrackSixthSenseInitial = not EHI:GetBuffOption("sixth_sense_initial")
local TrackSixthSenseSubsequent = EHI:GetBuffOption("sixth_sense_refresh")
local TrackSixthSenseHighlighted = EHI:GetBuffOption("sixth_sense_marked")
local latch_t = 0
function PlayerStandard:_update_omniscience(t, dt, ...)
    local previoustime = self._state_data.omniscience_t

    original._update_omniscience(self, t, dt, ...)

    if previoustime and self._state_data.omniscience_t == nil then
        -- The game forbade the skill, kill the buffs (this does not run every frame due to the combined check in the above
        -- conditional clause)
        managers.ehi_buff:RemoveBuff("standstill_omniscience_initial")
        managers.ehi_buff:RemoveBuff("standstill_omniscience")
        managers.ehi_buff:RemoveBuff("standstill_omniscience_highlighted")
        sense_latch = false
        return
    end

    -- Player does not have the skill or alarm has been raised
    if previoustime == nil and self._state_data.omniscience_t == nil then
        return
    end

    if previoustime == nil and self._state_data.omniscience_t then
        -- Delay prior to initial poll
        if DoNotTrackSixthSenseInitial then
            return
        end
        managers.ehi_buff:AddBuff("standstill_omniscience_initial", tweak_data.player.omniscience.start_t)
    elseif previoustime ~= self._state_data.omniscience_t then
        -- Subsequent poll (called once every second)
        local detected = 0
        local tmp = self._state_data.omniscience_units_detected
        local civilians = managers.enemy:all_civilians() or {}
        if tmp then
            local begin_t = 0
            local end_t = 0
            for key, data in pairs(tmp) do
                -- Since only expiry times are stored, work backwards to figure out when the start time was, and calculate the
                -- time the highlight will expire
                begin_t = data - target_resense_delay
                end_t = begin_t + (civilians[key] and computed_duration_civilian or computed_duration_security)
                if t >= begin_t and t < end_t then
                    detected = detected + 1
                end
            end
        end

        if detected > 0 and TrackSixthSenseSubsequent then
            if sense_latch then
                if t >= latch_t then
                    managers.ehi_buff:AddBuff("standstill_omniscience", target_resense_delay)
                    latch_t = t + target_resense_delay
                end
            else
                managers.ehi_buff:AddBuff("standstill_omniscience", target_resense_delay)
                sense_latch = true
                latch_t = t + target_resense_delay
            end
        end

        if TrackSixthSenseHighlighted then
            managers.ehi_buff:AddGauge("standstill_omniscience_highlighted", detected)
        end
    end
end

if EHI:GetBuffOption("reload") then
    original._start_action_reload = PlayerStandard._start_action_reload
    function PlayerStandard:_start_action_reload(t, ...)
        original._start_action_reload(self, t, ...)
        if self._state_data.reload_expire_t then
            managers.ehi_buff:AddBuff2("Reload", t, self._state_data.reload_expire_t)
        end
    end

    original._interupt_action_reload = PlayerStandard._interupt_action_reload
    function PlayerStandard:_interupt_action_reload(...)
        original._interupt_action_reload(self, ...)
        managers.ehi_buff:RemoveBuff("Reload")
    end
end

if EHI:GetBuffOption("interact") then
    original._start_action_interact = PlayerStandard._start_action_interact
    function PlayerStandard:_start_action_interact(...)
        original._start_action_interact(self, ...)
        if self._interact_expire_t > 0 then
            managers.ehi_buff:AddBuff("Interact", self._interact_expire_t)
        end
    end

    original._interupt_action_interact = PlayerStandard._interupt_action_interact
    function PlayerStandard:_interupt_action_interact(t, input, complete, ...)
        original._interupt_action_interact(self, t, input, complete, ...)
        if not complete then
            managers.ehi_buff:RemoveBuff("Interact")
        end
    end
end

if EHI:GetBuffOption("melee_charge") then
    original._start_action_melee = PlayerStandard._start_action_melee
    function PlayerStandard:_start_action_melee(t, input, instant, ...)
        original._start_action_melee(self, t, input, instant, ...)
        if instant then
            return
        end
        local melee_entry = managers.blackmarket:equipped_melee_weapon()
        local current_state_name = self._camera_unit:anim_state_machine():segment_state(self:get_animation("base"))
        local tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
        local attack_allowed_expire_t = tweak.attack_allowed_expire_t or 0.15
        local offset = current_state_name == self:get_animation("melee_attack_state") and 0 or attack_allowed_expire_t
        local max_charge_time = tweak.stats.charge_time
        local t_charge = offset + max_charge_time
        managers.ehi_buff:AddBuff("MeleeCharge", t_charge)
    end

    original._do_melee_damage = PlayerStandard._do_melee_damage
    function PlayerStandard:_do_melee_damage(...)
        local col_ray = original._do_melee_damage(self, ...)
        managers.ehi_buff:RemoveBuff("MeleeCharge")
        return col_ray
    end

    original._interupt_action_melee = PlayerStandard._interupt_action_melee
    function PlayerStandard:_interupt_action_melee(...)
        original._interupt_action_melee(self, ...)
        managers.ehi_buff:RemoveBuff("MeleeCharge")
    end
end