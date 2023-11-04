local EHI = EHI
if EHI:CheckLoadHook("PlayerDamage") then
    return
end

if not EHI:GetOption("show_buffs") then
    return
end

local original = {}

if EHI:GetBuffOption("dire_need") then
    original.init = PlayerDamage.init
    function PlayerDamage:init(...)
        original.init(self, ...)
        if self._dire_need then
            managers.player:register_message(Message.SetWeaponStagger, "EHI_Buff_DireNeed", function(stagger)
                if stagger then
                    managers.ehi_buff:AddBuffNoUpdate("DireNeed")
                else
                    managers.ehi_buff:RemoveBuff("DireNeed")
                end
            end)
        end
    end
end

--//////////////////////////////--
--//  Muscle / Hostage Taker  //--
--//////////////////////////////--
if EHI:GetBuffOption("hostage_taker_muscle") then
    local TeamAIHealhRegen = false
    EHI:AddCallback(EHI.CallbackMessage.TeamAISkillBoostChange, function(boost, operation)
        if boost == "crew_regen" then
            TeamAIHealhRegen = operation == "add"
        end
    end)
    original._upd_health_regen = PlayerDamage._upd_health_regen
    function PlayerDamage:_upd_health_regen(t, dt, ...)
        local previoustimer = self._health_regen_update_timer or 0

        original._upd_health_regen(self, t, dt, ...)

        if not self._health_regen_update_timer or self._health_regen_update_timer <= previoustimer then
            return
        end

        local playermanager = managers.player
        -- Yes, PlayerManager:health_regen() appears to be a rather expensive function to call, but the saving grace here is
        -- that this code only runs when self._health_regen_update_timer reaches 0, which is at most once every few seconds
        if playermanager:health_regen() <= 0 then
            -- OVK changed the function in U135 to no longer check that PlayerManager:health_regen() returns > 0, no idea
            -- exactly why they decided to make that change, but the end result is that self._health_regen_update_timer now
            -- continually ticks after the player takes health damage for the first time (similar to Anarchist) for as long
            -- as their health is not full. If the Frenzy skill is active, this means that the ticking is perpetual since
            -- they effectively take health damage immediately upon spawning, and can never heal back up to 100% (note that
            -- this behavior has not changed in U135)
            return
        end

        -- Determine which icon to use. This is fine to do here since this code only runs once every few seconds (thanks to the
        -- above checks)
        local icon = "muscle"
        if TeamAIHealhRegen then
            icon = "team_ai_health_regen"
        else
            local hostage_taker = playermanager:has_category_upgrade("player", "hostage_health_regen_addend")
            if hostage_taker then
                -- Sure the player has the skill, but are there actually any hostages around to provide that regen benefit?
                local state = managers.groupai and managers.groupai:state()
                hostage_taker = ((state and state:hostage_count() or 0) + (playermanager:num_local_minions() or 0) > 0)
            end
            if hostage_taker then
                icon = "hostage_taker"
            end
        end
        managers.ehi_buff:CallFunction("HealthRegen", "SetIcon", icon)
        managers.ehi_buff:AddBuff("HealthRegen", self._health_regen_update_timer + 0.2)
    end
end

--////////////////////--
--//  Ex-President  //--
--////////////////////--
if EHI:GetBuffOption("expresident") then
    original.update_armor_stored_health = PlayerDamage.update_armor_stored_health
    function PlayerDamage:update_armor_stored_health(...)
        original.update_armor_stored_health(self, ...)
        if managers.hud then -- Vanilla check
            managers.ehi_buff:CallFunction("ExPresident", "SetStoredHealthMaxAndUpdateRatio", self:max_armor_stored_health(), self._armor_stored_health)
        end
    end

    original.add_armor_stored_health = PlayerDamage.add_armor_stored_health
    function PlayerDamage:add_armor_stored_health(...)
        local previous = self._armor_stored_health
        original.add_armor_stored_health(self, ...)
        if previous ~= self._armor_stored_health and not self._check_berserker_done then
            managers.ehi_buff:CallFunction("ExPresident", "SetRatio", nil, self._armor_stored_health)
        end
    end

    original.clear_armor_stored_health = PlayerDamage.clear_armor_stored_health
    function PlayerDamage:clear_armor_stored_health(...)
        original.clear_armor_stored_health(self, ...)
        managers.ehi_buff:CallFunction("ExPresident", "SetRatio", nil, self._armor_stored_health)
    end
end

--/////////////////--
--//  Anarchist  //--
--/////////////////--
if EHI:GetBuffOption("anarchist") then
    -- This is necessary because of the incredibly awkward way OVK implemented this skill. It does not begin ticking until the very
    -- first time the player takes damage, after which it ticks forever - even when the player's armor is already at its maximum
    -- It does, however, get paused when the player is in bleedout, and is resumed the first time they take damage after they are
    -- revived (and not immediately upon revive)
    local TrackAnarchistRegenTick = true
    original._on_damage_armor_grinding = PlayerDamage._on_damage_armor_grinding
    function PlayerDamage:_on_damage_armor_grinding(...)
        original._on_damage_armor_grinding(self, ...)
        if self._current_state == self._update_armor_grinding then
            managers.ehi_buff:AddBuff("armor_grinding", self._armor_grinding.target_tick - self._armor_grinding.elapsed)
        end
    end

    original._remove_on_damage_event = PlayerDamage._remove_on_damage_event
    function PlayerDamage:_remove_on_damage_event(...)
        original._remove_on_damage_event(self, ...)
        -- Getting downed or entering swan song pauses the timer, reflect this
        managers.ehi_buff:RemoveBuff("armor_grinding")
    end

    original._update_armor_grinding = PlayerDamage._update_armor_grinding
    function PlayerDamage:_update_armor_grinding(...)
        local before = self:get_real_armor()
        original._update_armor_grinding(self, ...)
        -- This can only occur once every several seconds so it doesn't need to be optimized as aggressively
        if self._armor_grinding.elapsed == 0 then
            local after = self:get_real_armor()
            local delta = after - before
            if delta > 0 then
                managers.ehi_buff:AddBuff("armor_grinding", self._armor_grinding.target_tick)
            end
        end
    end

    --///////////////////////////--
    --//  Armorer / Anarchist  //--
    --///////////////////////////--
    original._calc_armor_damage = PlayerDamage._calc_armor_damage
    function PlayerDamage:_calc_armor_damage(...)
        local previous = self._can_take_dmg_timer
        local result = original._calc_armor_damage(self, ...)
        if self._can_take_dmg_timer > previous then
            managers.ehi_buff:AddBuff("Immunity", self._can_take_dmg_timer)
        end
        return result
    end
end

--/////////////--
--//  Stoic  //--
--/////////////--
if EHI:GetBuffOption("stoic") then
    original.delay_damage = PlayerDamage.delay_damage
    function PlayerDamage:delay_damage(damage, seconds, ...)
        managers.ehi_buff:AddBuff("damage_control", seconds)
        original.delay_damage(self, damage, seconds, ...)
    end

    original.clear_delayed_damage = PlayerDamage.clear_delayed_damage
    function PlayerDamage:clear_delayed_damage(...)
        managers.ehi_buff:RemoveBuff("damage_control")
        return original.clear_delayed_damage(self, ...)
    end
end

--//////////////--
--//  Uppers  //--
--//////////////--
if EHI:GetBuffOption("uppers") then
    original._check_bleed_out = PlayerDamage._check_bleed_out
    function PlayerDamage:_check_bleed_out(...)
        local previous = self._uppers_elapsed
        original._check_bleed_out(self, ...)
        if previous < self._uppers_elapsed then
            managers.ehi_buff:AddBuff("UppersCooldown", self._UPPERS_COOLDOWN)
        end
    end
end

--///////////////--
--//  Grinder  //--
--///////////////--
if EHI:GetBuffOption("grinder") then
    original.add_damage_to_hot = PlayerDamage.add_damage_to_hot
    function PlayerDamage:add_damage_to_hot(...)
        if self:got_max_doh_stacks() or self:need_revive() or self:dead() or self._check_berserker_done then
            return original.add_damage_to_hot(self, ...)
        end
        original.add_damage_to_hot(self, ...)
        local stack = self._damage_to_hot_stack
        local last_entry = #stack
        if last_entry < 1 then
            return
        end
        last_entry = stack[last_entry]
        local duration = last_entry.ticks_left * (self._doh_data.tick_time or 1)
        managers.ehi_buff:AddBuff("GrinderRegenPeriod", duration)
    end
end

--///////////////////--
--//  Armor Regen  //--
--///////////////////--
if EHI:GetBuffOption("shield_regen") then
    --/////////////--
    --//  Leech  //--
    --/////////////--
    original.on_copr_ability_activated = PlayerDamage.on_copr_ability_activated
    function PlayerDamage:on_copr_ability_activated(...)
        original.on_copr_ability_activated(self, ...)
        managers.ehi_buff:RemoveBuff("ArmorRegenDelay")
    end

    original.set_regenerate_timer_to_max = PlayerDamage.set_regenerate_timer_to_max
    function PlayerDamage:set_regenerate_timer_to_max(...)
        original.set_regenerate_timer_to_max(self, ...)
        if self._armor_change_blocked then
            return
        end
        local final_time = self._regenerate_timer / self._regenerate_speed
        if self._supperssion_data and self._supperssion_data.decay_start_t then
            final_time = final_time + math.max(0, self._supperssion_data.decay_start_t - managers.player:player_timer():time())
        end
        managers.ehi_buff:AddBuff("ArmorRegenDelay", final_time)
    end
end

--//////////////--
--//  Health  //--
--//////////////--
if EHI:GetBuffOption("health") then
    original._send_set_health = PlayerDamage._send_set_health
    function PlayerDamage:_send_set_health(...)
        original._send_set_health(self, ...)
        local max_health = self:_max_health()
        local current_health = self:get_real_health()
        local ratio = current_health / max_health
        managers.ehi_buff:AddGauge("Health", ratio, current_health)
    end

    original._send_set_revives = PlayerDamage._send_set_revives
    function PlayerDamage:_send_set_revives(...)
        original._send_set_revives(self, ...)
        local revives = math.max(Application:digest_value(self._revives, false) - 1, 0)
        managers.ehi_buff:CallFunction("Health", "SetHintText", tostring(revives))
    end
end

--/////////////--
--//  Armor  //--
--/////////////--
if EHI:GetBuffOption("armor") then
    original._send_set_armor = PlayerDamage._send_set_armor
    function PlayerDamage:_send_set_armor(...)
        original._send_set_armor(self, ...)
        local max_armor = self:_max_armor()
        local current_armor = self:get_real_armor()
        local ratio = current_armor / max_armor
        managers.ehi_buff:AddGauge("Armor", ratio, current_armor)
    end
end