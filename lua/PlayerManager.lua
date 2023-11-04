---@class PlayerManager
---@field has_category_upgrade fun(self: self, category: string, upgrade: string): boolean
---@field upgrade_value fun(self: self, category: string, upgrade: string, default: any?): any|table|number|boolean
---@field _get_damage_health_ratio_threshold fun(self: self, category: string): number
---@field has_activate_temporary_upgrade fun(self: self, category: string, upgrade: string): boolean
---@field register_message fun(self: self, message: number|string, uid: string|number, func: function)
---@field player_unit fun(self: self): Unit
---@field add_listener fun(self: self, key: string, events: string[], clbk: function)
---@field remove_listener fun(self: self, key: string)

local EHI = EHI
if EHI:CheckLoadHook("PlayerManager") then
    return
end

local buffs = EHI:GetOption("show_buffs")

local original =
{
    spawn_smoke_screen = PlayerManager.spawn_smoke_screen,
    start_custom_cooldown = PlayerManager.start_custom_cooldown
}

if EHI:GetOption("show_bodybags_counter") then
    original._set_body_bags_amount = PlayerManager._set_body_bags_amount
    function PlayerManager:_set_body_bags_amount(...)
        original._set_body_bags_amount(self, ...)
        managers.ehi_tracker:CallFunction("BodybagsCounter", "SetCount", self._local_player_body_bags)
    end
end

function PlayerManager:spawn_smoke_screen(position, normal, grenade_unit, ...)
    original.spawn_smoke_screen(self, position, normal, grenade_unit, ...)
    if grenade_unit:base():thrower_unit() then
        local key, color_id, local_player
        if alive(grenade_unit:base():thrower_unit()) then
            local_player = grenade_unit:base():thrower_unit() == self:player_unit()
            key = tostring(grenade_unit:base():thrower_unit():key())
            color_id = managers.criminals:character_color_id_by_unit(grenade_unit:base():thrower_unit())
        else
            key = "ThrowerUnitInCustody_" .. TimerManager:game():time()
            color_id = #tweak_data.chat_colors
        end
	    local color = tweak_data.chat_colors[color_id] or Color.white
        local duration = tweak_data.projectiles.smoke_screen_grenade.duration
        managers.ehi_tracker:AddTracker({
            id = "SmokeScreenGrenade_" .. key,
            time = duration,
            icons = {
                {
                    icon = "smoke",
                    color = color
                }
            }
        })
        if local_player and buffs then
            managers.ehi_buff:AddBuff("SmokeScreen", duration)
        end
    end
end

function PlayerManager:start_custom_cooldown(category, upgrade, cooldown, ...)
    if upgrade == "crew_inspire" then
        managers.ehi_buff:SyncBuff("team_crew_inspire", cooldown)
    end
    original.start_custom_cooldown(self, category, upgrade, cooldown, ...)
end

if not buffs then
    return
end

original.init = PlayerManager.init
function PlayerManager:init(...)
    original.init(self, ...)
    if EHI:GetBuffOption("forced_friendship") then
        local hostage_limit = tweak_data.upgrades.values.team.damage.hostage_absorption_limit
        local absorption_gain = tweak_data.upgrades.values.team.damage.hostage_absorption[1]
        local max_absorption = hostage_limit * absorption_gain
        local _t = self._damage_absorption
        self._damage_absorption = {}
        local _mt = {
            __index = function(table, key)
                return _t[key]
            end,
            __newindex = function(table, key, value)
                _t[key] = value
                if key == "hostage_absorption" and value then
                    local raw = Application:digest_value(value, false)
                    if raw > 0 then
                        local ratio = raw / max_absorption
                        managers.ehi_buff:AddGauge("hostage_absorption", ratio, raw * 10)
                    else
                        managers.ehi_buff:RemoveBuff("hostage_absorption")
                    end
                end
            end
        }
        setmetatable(self._damage_absorption, _mt)
    end
    if EHI:GetBuffOption("regen_throwable_ai") then
        local value = tweak_data.upgrades.values.team.crew_throwable_regen
        local max = (value and value[1] or 35) + 1
        local progress = 0
        local function IncreaseProgress(...)
            progress = progress + 1
            if progress == max then
                progress = 0
            end
            managers.ehi_buff:AddGauge("crew_throwable_regen", progress / max, progress)
        end
        EHI:AddCallback(EHI.CallbackMessage.TeamAISkillBoostChange, function(boost, operation)
            if boost == "crew_generous" then
                if operation == "add" then
                    progress = self._throw_regen_kills or 0
                    managers.ehi_buff:AddGauge("crew_throwable_regen", progress / max, progress)
                    self:register_message(Message.OnEnemyKilled, "EHI_crew_throwable_regen", IncreaseProgress)
                else
                    managers.ehi_buff:RemoveBuff("crew_throwable_regen")
                    self:unregister_message(Message.OnEnemyKilled, "EHI_crew_throwable_regen")
                end
            end
        end)
    end
end

if EHI:GetBuffAndOption("unseen_strike_initial") then
    EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
        local self = managers.player
        if self:has_category_upgrade("player", "unseen_increased_crit_chance") then
            local data = self:upgrade_value("player", "unseen_increased_crit_chance", 0) --[[@as table|number]]
            if data == 0 then
                return
            end
            local min_time = data.min_time or 4
            self:register_message(Message.OnPlayerDamage, "EHI_UnseenStrike_Initial", function()
                if not self:has_activate_temporary_upgrade("temporary", "unseen_strike") then
                    managers.ehi_buff:AddBuff("unseen_strike_initial", min_time)
                end
            end)
        end
    end)
end

local AbilityKey, AbilitySpeedUp
EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
    local self = managers.player
    local grenade = managers.blackmarket:equipped_grenade()
    if grenade == "chico_injector" then -- Kingpin
        AbilityKey = "chico_injector"
        AbilitySpeedUp = "speed_up_chico_injector"
    elseif grenade == "smoke_screen_grenade" then -- Sicario
        AbilityKey = "smoke_screen_grenade"
    elseif grenade == "damage_control" then -- Stoic
        AbilityKey = "damage_control"
        if self:has_category_upgrade("player", "damage_control_auto_shrug") then
            tweak_data.ehi.buff.damage_control.x = 2 -- 128px
            managers.ehi_buff:UpdateBuffIcon("damage_control")
            managers.ehi_buff:CallFunction("damage_control", "SetAutoShrug", self:upgrade_value("player", "damage_control_auto_shrug"))
        end
        self:register_message("ability_activated", "EHI_Stoic_Ability_Activated", function(ability_name)
            if ability_name == "damage_control" then
                managers.ehi_buff:RemoveBuff("damage_control")
            end
        end)
    elseif grenade == "tag_team" then -- Tag Team
        AbilityKey = "tag_team"
    elseif grenade == "pocket_ecm_jammer" then -- Hacker
        AbilityKey = "pocket_ecm_jammer"
        AbilitySpeedUp = "speed_up_pocket_ecm_jammer"
    elseif grenade == "copr_ability" then -- Leech
        AbilityKey = "copr_ability"
        AbilitySpeedUp = "speed_up_copr_ability"
    end
    if AbilityKey then
        AbilityKey = AbilityKey .. "_cooldown"
        managers.ehi_buff._cache.Ability = AbilityKey
    end
end)

original.activate_temporary_upgrade = PlayerManager.activate_temporary_upgrade
function PlayerManager:activate_temporary_upgrade(category, upgrade, ...)
    original.activate_temporary_upgrade(self, category, upgrade, ...)
    local end_time = self._temporary_upgrades[category] and self._temporary_upgrades[category][upgrade] and self._temporary_upgrades[category][upgrade].expire_time
    if not end_time then
        return
    end
    managers.ehi_buff:AddBuff2(upgrade, Application:time(), end_time)
end

original.start_timer = PlayerManager.start_timer
function PlayerManager:start_timer(key, duration, ...)
    if key == "replenish_grenades" and AbilityKey then
        managers.ehi_buff:AddBuff(AbilityKey, duration)
    elseif key == "team_crew_inspire" then
        managers.ehi_buff:AddBuff(key, duration)
    end
    original.start_timer(self, key, duration, ...)
end

original.speed_up_grenade_cooldown = PlayerManager.speed_up_grenade_cooldown
function PlayerManager:speed_up_grenade_cooldown(time, ...)
    if not self._timers.replenish_grenades then
        return
    end
    if not AbilityKey then
        return original.speed_up_grenade_cooldown(self, time, ...)
    end
    managers.ehi_buff:ShortenBuffTime(AbilityKey, time)
    original.speed_up_grenade_cooldown(self, time, ...)
end

local meele_boost_tweak = tweak_data.upgrades.values.player.melee_damage_stacking[1]
if meele_boost_tweak then
    local not_bloodthirst = not EHI:GetBuffOption("bloodthirst")
    local bloodthirst_reload = EHI:GetBuffOption("bloodthirst_reload")
    local bloodthirst_ratio = EHI:GetBuffOption("bloodthirst_ratio") / 100
    local max_multiplier = meele_boost_tweak.max_multiplier or 16
    local bloodthirst_max = false
    tweak_data.ehi.buff.melee_damage_stacking.max = max_multiplier
    if bloodthirst_ratio == 0 then
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            if managers.player:has_category_upgrade("player", "melee_damage_stacking") then
                managers.ehi_buff:AddGauge("melee_damage_stacking", 1 / max_multiplier, 1)
            end
        end)
    end
    original.set_melee_dmg_multiplier = PlayerManager.set_melee_dmg_multiplier
    function PlayerManager:set_melee_dmg_multiplier(multiplier, ...)
        original.set_melee_dmg_multiplier(self, multiplier, ...)
        if bloodthirst_max or not_bloodthirst then
            return -- Avoid doing expensive call below because the multiplier is full
        end
        local ratio = multiplier / max_multiplier
        if ratio >= bloodthirst_ratio then
            bloodthirst_max = ratio == 1
            managers.ehi_buff:AddGauge("melee_damage_stacking", ratio, multiplier)
        end
    end
    original.reset_melee_dmg_multiplier = PlayerManager.reset_melee_dmg_multiplier
    function PlayerManager:reset_melee_dmg_multiplier(...)
        original.reset_melee_dmg_multiplier(self, ...)
        if bloodthirst_ratio > 0 then
            managers.ehi_buff:RemoveBuff("melee_damage_stacking")
        else
            managers.ehi_buff:AddGauge("melee_damage_stacking", self._melee_dmg_mul / max_multiplier, self._melee_dmg_mul)
        end
        bloodthirst_max = false -- Reset the lock
        if self:has_category_upgrade("player", "melee_kill_increase_reload_speed") then
            local data = self:upgrade_value("player", "melee_kill_increase_reload_speed", 0)
            if data ~= 0 and bloodthirst_reload then
                managers.ehi_buff:AddBuff("melee_kill_increase_reload_speed", data[2])
            end
        end
    end
end

if EHI:GetBuffOption("painkillers") or EHI:GetBuffOption("copycat") then
    original.activate_temporary_property = PlayerManager.activate_temporary_property
    function PlayerManager:activate_temporary_property(name, time, ...)
        original.activate_temporary_property(self, name, time, ...)
        if name == "revived_damage_reduction" then -- "Painkillers"
            managers.ehi_buff:AddBuff("fast_learner", time)
        elseif name == "mrwi_health_invulnerable" then -- "Grace Period" (Copycat)
            managers.ehi_buff:AddBuff("mrwi_health_invulnerable_cooldown", time)
        end
    end
end

if EHI:GetBuffOption("second_wind") then
    original.activate_synced_temporary_team_upgrade = PlayerManager.activate_synced_temporary_team_upgrade
    function PlayerManager:activate_synced_temporary_team_upgrade(peer_id, category, upgrade, ...)
        original.activate_synced_temporary_team_upgrade(self, peer_id, category, upgrade, ...)
        if category ~= "temporary" or upgrade ~= "team_damage_speed_multiplier_received" then
            return
        end
        local upgrade_value = self:upgrade_value(category, upgrade)
        if upgrade_value == 0 then
            return
        end
        managers.ehi_buff:AddBuff("damage_speed_multiplier", upgrade_value[2])
    end
end

if EHI:GetBuffOption("inspire_ace") then
    original.disable_cooldown_upgrade = PlayerManager.disable_cooldown_upgrade
    function PlayerManager:disable_cooldown_upgrade(category, upgrade, ...)
        local upgrade_value = self:upgrade_value(category, upgrade)
        if upgrade_value == 0 then
            return
        end
        original.disable_cooldown_upgrade(self, category, upgrade, ...)
        if category ~= "cooldown" or upgrade ~= "long_dis_revive" then
            return
        end
        managers.ehi_buff:AddBuff("long_dis_revive", upgrade_value[2])
    end
end

--////////////////--
--//  Tag Team  //--
--////////////////--
if EHI:GetBuffOption("tag_team") then
    local TagTeam =
    {
        Effect =
        {
            Priority = 1,
            Function = function(tagged, owner)
                local base_values = managers.player:upgrade_value("player", "tag_team_base")
                local timer = TimerManager:game()
                local kill_extension = base_values.kill_extension
                local duration = base_values.duration
                local end_time = timer:time() + base_values.duration
                local function on_damage(damage_info)
                    local was_killed = damage_info.result.type == "death"
                    local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged
                    if was_killed and valid_player then
                        end_time = math.min(end_time + kill_extension, timer:time() + duration)
                        managers.ehi_buff:AppendTimeCeil("TagTeamEffect", kill_extension, duration)
                    end
                end
                local on_damage_key = "TagTeam_EHI_on_damage"
                CopDamage.register_listener(on_damage_key, { "on_damage" }, on_damage)
                while alive(owner) and timer:time() < end_time do
                    coroutine.yield()
                end
                CopDamage.unregister_listener(on_damage_key)
            end
        },
        Tagged =
        {
            Priority = 1,
            Function = function (tagged, owner, BuffKey)
                local base_values = owner:base():upgrade_value("player", "tag_team_base")
                local timer = TimerManager:game()
                local kill_extension = base_values.kill_extension
                local duration = base_values.duration
                local end_time = timer:time() + duration
                local on_damage_key = "on_damage_" .. BuffKey .. "_EHI"
                local function on_damage(damage_info)
                    local was_killed = damage_info.result.type == "death"
                    local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged
                    if was_killed and valid_player then
                        end_time = math.min(end_time + kill_extension, timer:time() + duration)
                        managers.ehi_buff:AppendTimeCeil(BuffKey, kill_extension, duration)
                    end
                end
                CopDamage.register_listener(on_damage_key, { "on_damage" }, on_damage)
                local ended_by_owner = false
                local on_end_key = "on_end_tag_" .. BuffKey .. "_EHI"
                local function on_action_end(end_tagged, end_owner)
                    local tagged_match = tagged == end_tagged
                    local owner_match = owner == end_owner
                    ended_by_owner = tagged_match and owner_match
                    if ended_by_owner then
                        managers.ehi_buff:RemoveBuff(BuffKey)
                    end
                end
                managers.player:add_listener(on_end_key, { "tag_team_end" }, on_action_end)
                while not ended_by_owner and alive(tagged) and (alive(owner) or timer:time() < end_time) do
                    coroutine.yield()
                end
                CopDamage.unregister_listener(on_damage_key)
                managers.player:remove_listener(on_end_key)
            end
        }
    }

    original._attempt_tag_team = PlayerManager._attempt_tag_team
    function PlayerManager:_attempt_tag_team(...)
        local result = original._attempt_tag_team(self, ...)
        if result then
            local duration = self:upgrade_value("player", "tag_team_base", {}).duration
            if not duration then -- No duration ? How ?
                return
            end
            managers.ehi_buff:AddBuff("TagTeamEffect", duration)
            local args = self._coroutine_mgr._buffer.tag_team.arg
            local tagged, owner = unpack(args)
            self:add_coroutine("tag_team_EHI", TagTeam.Effect, tagged, owner)
        end
        return result
    end

    original.sync_tag_team = PlayerManager.sync_tag_team
    function PlayerManager:sync_tag_team(tagged, owner, ...)
        original.sync_tag_team(self, tagged, owner, ...)
        if tagged == self:local_player() then
            local base_values = owner:base():upgrade_value("player", "tag_team_base") or {}
            local duration = base_values.duration
            if not duration then -- No duration ? Is the owner running a rebalance or cheating ?
                -- Other possible explanation is that the local player is running a rebalance,
                -- making synced upgrades from client marked as invalid
                -- End the execution here because the vanilla coroutine will crash too (but silently)
                return
            end
            local tagged_id = managers.network:session():peer_by_unit(tagged):id()
            local owner_id = managers.network:session():peer_by_unit(owner):id()
            local coroutine_key = "TagTeamTagged_" .. owner_id .. tagged_id
            managers.ehi_buff:AddBuff(coroutine_key, duration)
            self:add_coroutine(coroutine_key, TagTeam.Tagged, tagged, owner, coroutine_key)
        end
    end
end

--/////////////--
--//  Leech  //--
--/////////////--
if EHI:GetBuffOption("leech") then
    original.force_end_copr_ability = PlayerManager.force_end_copr_ability
    function PlayerManager:force_end_copr_ability(...)
        original.force_end_copr_ability(self, ...)
        managers.ehi_buff:RemoveBuff("copr_ability")
    end
end

--//////////////////////////////////--
--//  Bullseye / Ammo Efficiency  //--
--//////////////////////////////////--
--[[local TrackBullseye = O:get("buff", "showBullseyeCooldown")
local TrackAmmoEfficiencyDuration = O:get("buff", "showAmmoEfficiencyDuration")
local TrackAmmoEfficiencyStack = O:get("buff", "showAmmoEfficiencyStack")
local ammo_efficiency_counter = 0
local ammo_efficiency_text_tbl = {{}, {}}
local function ResetAmmoEfficiencyStack()
    ammo_efficiency_counter = 0
    me:RemoveBuff("AmmoEfficiencyStack")
end]]
if EHI:GetBuffOption("bullseye") or EHI:GetBuffOption("copycat") then
    original.on_headshot_dealt = PlayerManager.on_headshot_dealt
    function PlayerManager:on_headshot_dealt(...)
        local previouscooldown = self._on_headshot_dealt_t or 0
        --local isgametracking = self._coroutine_mgr:is_running("ammo_efficiency")

        original.on_headshot_dealt(self, ...)

        if self:has_category_upgrade("player", "headshot_regen_armor_bonus") then-- and TrackBullseye then
            local t = Application:time()
            if t >= previouscooldown then
                managers.ehi_buff:AddBuff2("headshot_regen_armor_bonus", t, self._on_headshot_dealt_t)
            end
        end

        if self:has_category_upgrade("player", "headshot_regen_health_bonus") then
            local t = Application:time()
            if t >= previouscooldown then
                managers.ehi_buff:AddBuff2("headshot_regen_health_bonus", t, self._on_headshot_dealt_t)
            end
        end

        -- Derived from PlayerManager:_on_enter_ammo_efficiency_event()
        --[[if self._ammo_efficiency ~= nil and (TrackAmmoEfficiencyDuration or TrackAmmoEfficiencyStack) then
            local weaponunit = self:equipped_weapon_unit()
            if weaponunit then
                local weaponunitbase = weaponunit:base()
                if weaponunitbase and weaponunitbase:fire_mode() == "single" and weaponunitbase:is_category("smg", "assault_rifle", "snp") then
                    ammo_efficiency_counter = (ammo_efficiency_counter or 0) + 1

                    if TrackAmmoEfficiencyStack then
                        local text = nil
                        -- The buff title must not be specified for the 'Vanilla' style when et is 1
                        if buff_style ~= 2 then
                            -- Recycling tables to prevent memory wastage since this code runs frequently
                            text = ammo_efficiency_text_tbl
                            text[1][1] = L("_buff_ammo_efficiency_stack")
                            text[2][1] = string_format(" %s", tostring(ammo_efficiency_counter))
                            text[2][2] = clGood
                        else
                            text = tostring(ammo_efficiency_counter)
                        end
                        local maxheadshots = (self._ammo_efficiency.headshots or 3)
                        local ratio = ammo_efficiency_counter / maxheadshots
                        if ratio > 1 then
                            -- Probably never, but just in case
                            ratio = 1
                        end
                        me:GaugeBuff3({
                            key = "AmmoEfficiencyStack",
                            good = true,
                            icon = U100SkillIcons,
                            iconRect = {(8 * 80) + 8, (4 * 80) + 12, 64, 64},
                            text = text,
                            st = buff_style == 2 and ratio or 1 - ratio
                        })
                        -- Add only one delayed callback, not two or three
                        if not isgametracking then
                            DC:Add("ResetAmmoEfficiencyStack", (self._ammo_efficiency.time or 6), ResetAmmoEfficiencyStack)
                        end
                    end
                else
                    me:RemoveBuff("AmmoEfficiencyDuration")
                    ResetAmmoEfficiencyStack()
                end
            end
        end]]
    end
end

--///////////////////////--
--//  Ammo Efficiency  //--
--///////////////////////--
original.on_ammo_increase = PlayerManager.on_ammo_increase
function PlayerManager:on_ammo_increase(...)
    original.on_ammo_increase(self, ...)
    managers.ehi_buff:RemoveBuff("ammo_efficiency")
end

--///////////////////--
--//  Bulletstorm  //--
--///////////////////--
if EHI:GetBuffOption("bulletstorm") then
    original.add_to_temporary_property = PlayerManager.add_to_temporary_property
    function PlayerManager:add_to_temporary_property(name, time, ...)
        original.add_to_temporary_property(self, name, time, ...)
        if name == "bullet_storm" then
            managers.ehi_buff:AddBuff("bullet_storm", time)
        end
    end
end

--//////////////--
--//  Maniac  //--
--//////////////--
if EHI:GetBuffOption("maniac") then
    local next_maniac_stack_poll = 0
    local ShowManiacStackTicks = true--O:get("buff", "showManiacStackTicks")
    local ShowManiacDecayTicks = ShowManiacStackTicks--O:get("buff", "showManiacDecayTicks")
    local ShowManiacAccumulatedStacks = ShowManiacStackTicks--O:get("buff", "showManiacAccumulatedStacks")
    original._update_damage_dealt = PlayerManager._update_damage_dealt
    function PlayerManager:_update_damage_dealt(t, dt, ...)
        local previousstack = self._damage_dealt_to_cops_t or 0
        local previousdecay = self._damage_dealt_to_cops_decay_t or 0

        original._update_damage_dealt(self, t, dt, ...)

        if not self:has_category_upgrade("player", "cocaine_stacking") or self:local_player() == nil or self._damage_dealt_to_cops_t == nil or self._damage_dealt_to_cops_decay_t == nil then
            return
        end

        -- t here is identical to the timestamp returned by PlayerManager:player_timer():time() so do not bother calling the latter
        if t >= previousstack and ShowManiacStackTicks then
            managers.ehi_buff:AddBuff3("ManiacStackTicks", t, self._damage_dealt_to_cops_t)
        end

        if t >= previousdecay and ShowManiacDecayTicks then
            managers.ehi_buff:AddBuff3("ManiacDecayTicks", t, self._damage_dealt_to_cops_decay_t)
        end

        -- Poll accumulated hysteria stacks, but not every frame
        if t >= next_maniac_stack_poll then
            if ShowManiacAccumulatedStacks then
                local newstacks = (self._damage_dealt_to_cops or 0) * (tweak_data.gui.stats_present_multiplier or 10) * self:upgrade_value("player", "cocaine_stacking", 0)
                local maxstacks = tweak_data.upgrades.max_cocaine_stacks_per_tick or 20
                if newstacks > maxstacks then
                    newstacks = maxstacks
                end
                local ratio = newstacks / maxstacks
                if ratio > 0 then
                    managers.ehi_buff:AddGauge("ManiacAccumulatedStacks", EHI:RoundNumber(ratio, 0.01))
                else
                    managers.ehi_buff:RemoveBuff("ManiacAccumulatedStacks")
                end
            end
            next_maniac_stack_poll = t + 1
        end
    end
end

--///////////////--
--//  Grinder  //--
--///////////////--
if EHI:GetBuffOption("grinder") then
    original._check_damage_to_hot = PlayerManager._check_damage_to_hot
    function PlayerManager:_check_damage_to_hot(t, ...)
        local previouscooldown = self._next_allowed_doh_t or 0
        original._check_damage_to_hot(self, t, ...)
        if not self._next_allowed_doh_t or not self:has_category_upgrade("player", "damage_to_hot") then
            return
        end
        if self._next_allowed_doh_t > previouscooldown then
            managers.ehi_buff:AddBuff2("GrinderStackCooldown", t, self._next_allowed_doh_t)
        end
    end
end

--///////////////--
--//  Sicario  //--
--///////////////--
if EHI:GetBuffOption("sicario") then
    local twitch_gauge_previous = 0
    local cooldown = tweak_data.upgrades.values.player.dodge_shot_gain[1][2] or 4
    original._dodge_shot_gain = PlayerManager._dodge_shot_gain
    function PlayerManager:_dodge_shot_gain(gain_value, ...)
        local dodge_value = gain_value or self._dodge_shot_gain_value or 0
        if twitch_gauge_previous ~= dodge_value then
            twitch_gauge_previous = dodge_value
            if dodge_value > 0 then
                managers.ehi_buff:AddGauge("SicarioTwitchGauge", dodge_value)
            else
                managers.ehi_buff:RemoveBuff("SicarioTwitchGauge")
            end
        end
        if dodge_value > 0 and dodge_value ~= self._dodge_shot_gain_value then
            managers.ehi_buff:AddBuff("SicarioTwitchCooldown", cooldown)
        end
        return original._dodge_shot_gain(self, gain_value, ...)
    end
end