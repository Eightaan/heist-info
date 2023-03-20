local EHI = EHI
if EHI:CheckHook("BlackMarketGui") or not EHI:GetOption("show_inventory_detailed_description") then
    return
end

local function LoadClasses()
    if Global.load_level then
        return
    end
    local classes =
    {
        ECMJammerBase = "lib/units/equipment/ecm_jammer/ECMJammerBase",
        SentryGunBase = "lib/units/equipment/sentry_gun/SentryGunBase",
        SentryGunWeapon = "lib/units/weapons/SentryGunWeapon",
        PlayerDamage = "lib/units/beings/player/PlayerDamage"
    }
    if not UnitBase then
        require("lib/units/MenuScriptUnitData")
    end
    for class, path in pairs(classes) do
        if not _G[class] then
            require(path)
        end
    end
end
LoadClasses()

local hide_original_desc = EHI:GetOption("hide_original_desc")

local original =
{
    populate_deployables = BlackMarketGui.populate_deployables,
    populate_grenades = BlackMarketGui.populate_grenades
}

local strs = {}
local percent_format = "%"
EHI:AddCallback(EHI.CallbackMessage.LocLoaded, function(loc, loc_loaded)
    strs.poison = loc:text("ehi_bm_poison")
    strs.fire = loc:text("ehi_bm_fire")
    strs.explosion = loc:text("ehi_bm_explosion")
    strs.max_dmg = loc:text("ehi_bm_max_damage")
    strs.dmg = loc:text("ehi_bm_damage")
    strs.range = loc:text("ehi_bm_range")
    strs.instant = loc:text("ehi_bm_instant")
    strs.base_cooldown = loc:text("ehi_bm_base_cooldown")
    strs.duration = loc:text("ehi_bm_duration")
    strs.cooldown_drain = loc:text("ehi_bm_cooldown_drain")
    strs.dot = loc:text("ehi_bm_dot")
    strs.dot_tick_period = loc:text("ehi_bm_dot_tick_period")
    strs.dot_chance = loc:text("ehi_bm_dot_chance")
    strs.charges = loc:text("ehi_bm_charges")
    strs.charges_no_total = loc:text("ehi_bm_charges_no_total")
    if loc_loaded == "czech" then
        percent_format = " %"
    end
end)

local function RestoreVanillaText(id)
    LocalizationManager._custom_localizations[id] = nil
end

local function AddCustomText(id, t)
    LocalizationManager._custom_localizations[id] = t
end

local function FormatDOTData(dot_data, variant)
    local str = string.format("%s: (%s)", variant or "<Unknown>", strs.dot)
    if dot_data.dot_trigger_chance then
        local chance = dot_data.dot_trigger_chance
        if chance >= 0 and chance <= 1 then
            chance = chance * 100
        end
        str = string.format("%s\n>> %s: %d%s", str, strs.dot_chance, chance, percent_format)
    end
    local dot_damage = (dot_data.dot_damage or 0) * 10
    if dot_damage > 0 then
        str = string.format("%s\n>> %s: %d", str, strs.dmg, dot_damage)
    end
    local dot_length = dot_data.dot_length or 0
    if dot_length > 0 then
        str = string.format("%s\n>> %s: %ss", str, strs.duration, tostring(dot_length))
    end
    local dot_tick_period = dot_data.dot_tick_period or 0
    if dot_tick_period > 0 then
        str = string.format("%s\n>> %s", str, string.format(strs.dot_tick_period, tostring(dot_tick_period)))
    end
    local divider = dot_tick_period == 0 and 1 or dot_tick_period
    local dot_trigger_times = math.floor(dot_length / divider)
    local remainder = math.fmod(dot_length, divider)
    if remainder > 0 then -- Incendiary Grenade for some reason triggers 3 times and not 4 times, most likely due to grace period and fire dot counter in FireManager
        dot_trigger_times = dot_trigger_times - 1
    end
    local total_damage = dot_damage * dot_trigger_times
    if total_damage > 0 then
        str = string.format("%s\n>> %s: %d", str, strs.max_dmg, total_damage)
    end
    return str
end

local tweak_upgrades = tweak_data.upgrades
local FormatAmount =
{
    doctor_bag = { base_amount = tweak_upgrades.doctor_bag_base, upgrade = "amount_increase" },
    bodybags_bag = { base_amount = tweak_upgrades.bodybag_crate_base },
    grenade_crate = { base_amount = 4 } -- Hardcoded in GrenadeCrateDeployableBase
}
local JackOfAllTradesOverride =
{
    grenade_crate = 1 -- Not reduced
}
local DeployableFormattingFunction =
{
    doctor_bag = function()
        local str = "> " .. managers.localization:text("ehi_bm_doctor_bag")
        if managers.player:upgrade_level("first_aid_kit", "damage_reduction_upgrade") == 1 then
            local values = tweak_upgrades.values.temporary.first_aid_damage_reduction[1] or {}
            local dmg = 1 - (values[1] or 0)
            str = string.format("%s\n> %s", str, managers.localization:text("ehi_bm_doctor_bag_2", { multiplier = tostring(dmg * 100) .. percent_format, duration = (values[2] or 0) }))
        end
        return str
    end,
    ammo_bag = function(second_deployable)
        local str = ""
        local amount = tweak_upgrades.ammo_bag_base + managers.player:upgrade_value_by_level("ammo_bag", "ammo_increase", 1)
        local equipment_amount = (tweak_data.equipments.ammo_bag.quantity[1] or 0) + managers.player:equiptment_upgrade_value("ammo_bag", "quantity", 0)
        local percent = "%s (%s%s)"
        if second_deployable then
            amount = amount / 2
        end
        local uses = string.format(percent, tostring(amount), tostring(amount * 100), percent_format)
        if equipment_amount > 1 then
            local total = amount * 2
            str = string.format("> " .. managers.localization:text("ehi_bm_charges"), uses, string.format(percent, tostring(total), tostring(total * 100), percent_format))
        else
            str = string.format("> " .. managers.localization:text("ehi_bm_charges_no_total"), uses)
        end
        str = string.format("%s\n> %s", str, managers.localization:text("ehi_bm_ammo_bag"))
        local bulletstorm = managers.player:upgrade_level("player", "no_ammo_cost")
        if bulletstorm ~= 0 then
            local duration = bulletstorm == 1 and 5 or 20
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_ammo_bag_2"), duration))
        end
        return str
    end,
    armor_kit = function()
        return string.format("> %s\n> %s", string.format(strs.charges_no_total, "1"), managers.localization:text("ehi_bm_armor_kit"))
    end,
    bodybags_bag = function()
        return string.format("> %s", managers.localization:text("ehi_bm_bodybags_bag"))
    end,
    ecm_jammer = function()
        local battery_life_level = managers.player:upgrade_level("ecm_jammer", "duration_multiplier", 0) + managers.player:upgrade_level("ecm_jammer", "duration_multiplier_2", 0) + 1
        local duration = tweak_upgrades.ecm_jammer_base_battery_life * ECMJammerBase.battery_life_multiplier[battery_life_level]
        local str = string.format("> %s: %ss", string.format(strs.duration), tostring(duration))
        if managers.player:has_category_upgrade("ecm_jammer", "can_open_sec_doors") then
            str = string.format("%s\n> %s", str, managers.localization:text("ehi_bm_ecm_jammer"))
        end
        if managers.player:has_category_upgrade("ecm_jammer", "affects_pagers") then
            str = string.format("%s\n> %s", str, managers.localization:text("ehi_bm_ecm_jammer_2"))
        end
        return str
    end,
    trip_mine = function()
        local tweak = tweak_data.weapon.trip_mines
        local damage_multiplier = managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)
        local damage = (tweak.damage or 0) * damage_multiplier
        local radius = (tweak.damage_size or 0) * managers.player:upgrade_value("trip_mine", "explosion_size_multiplier_1", 1) * damage_multiplier
        local str = string.format("> %s\n>> %s: %s\n>> %s: %sm", strs.explosion, strs.dmg, tostring(damage * 10), strs.range, tostring(radius * 0.01))
        if managers.player:has_category_upgrade("trip_mine", "fire_trap") then
            local fire_trap_data = managers.player:upgrade_value("trip_mine", "fire_trap", nil)
            if fire_trap_data then
                local fire_trap_tweak = tweak_data.env_effect:trip_mine_fire()
                str = string.format("%s\n> %s (%s):\n>> %s: %s\n>> %s: %ss\n>> %s: %sm", str, managers.localization:text("ehi_bm_trip_mine"), strs.fire,
                strs.dmg, tostring((fire_trap_tweak.damage or 0) * 10), strs.duration, tostring((fire_trap_tweak.burn_duration or 0) + fire_trap_data[1]),
                strs.range, tostring(((fire_trap_tweak.range or 0) * fire_trap_data[2]) * 0.01))
                str = string.format("%s\n> %s", str, FormatDOTData(fire_trap_tweak.fire_dot_data or {}, strs.fire))
            end
        end
        return str
    end,
    sentry_gun = function()
        local accuracy_level = math.min(managers.player:upgrade_level("sentry_gun", "spread_multiplier", 0) + 1, 2)
        local sentry_accuracy = tweak_data.weapon.sentry_gun.SPREAD * SentryGunBase.SPREAD_MUL[accuracy_level]
        local ap_bullets = managers.player:has_category_upgrade("sentry_gun", "ap_bullets")
        local damage = (tweak_data.weapon.sentry_gun.DAMAGE or 0) * 10
        local hp = tweak_data.upgrades.sentry_gun_base_armor * managers.player:upgrade_value("sentry_gun", "armor_multiplier", 1) * managers.player:upgrade_value("sentry_gun", "armor_multiplier2", 1)
        local ammo_level = managers.player:upgrade_value("sentry_gun", "extra_ammo_multiplier", 1)
        local ammo = tweak_data.upgrades.sentry_gun_base_ammo * SentryGunBase.AMMO_MUL[ammo_level]
        local str = ""
        if ap_bullets then
            str = string.format("> %s\n", managers.localization:text("ehi_bm_sentry_gun_3"))
        end
        if managers.player:has_category_upgrade("sentry_gun", "shield") then
            str = string.format("%s> %s\n", str, managers.localization:text("ehi_bm_sentry_gun_5"))
        end
        str = string.format("%s> %s: %s\n> %s: %s", str, managers.localization:text("ehi_bm_sentry_gun"), tostring(hp * 10),
            managers.localization:text("ehi_bm_sentry_gun_2"), tostring(ammo))
        if ap_bullets then
            str = string.format("%s\n> %s: %s (%s: %s)", str, strs.dmg, tostring(damage), managers.localization:text("ehi_bm_sentry_gun_4"), tostring(damage * SentryGunWeapon._AP_ROUNDS_DAMAGE_MULTIPLIER))
        else
            str = string.format("%s\n> %s: %s", str, strs.dmg, tostring(damage))
        end
        local cost_reduction = managers.player:upgrade_value("sentry_gun", "cost_reduction", 1)
        str = string.format("%s\n> %s: %s%s", str, managers.localization:text("ehi_bm_sentry_gun_6"), tostring((1 - SentryGunBase.DEPLOYEMENT_COST[cost_reduction]) * 100), percent_format)
        str = string.format("%s\n> %s: %s %s", str, managers.localization:text("ehi_bm_sentry_gun_7"), tostring(sentry_accuracy), managers.localization:text("ehi_bm_sentry_gun_8"))
        return str
    end,
    first_aid_kit = function()
        local str = "> " .. managers.localization:text("ehi_bm_first_aid_kit")
        if managers.player:upgrade_level("first_aid_kit", "damage_reduction_upgrade") == 1 then
            local values = tweak_upgrades.values.temporary.first_aid_damage_reduction[1] or {}
            local dmg = 1 - (values[1] or 0)
            str = string.format("%s\n> %s", str, managers.localization:text("ehi_bm_doctor_bag_2", { multiplier = tostring(dmg * 100) .. percent_format, duration = (values[2] or 0) }))
        end
        if managers.player:has_category_upgrade("first_aid_kit", "first_aid_kit_auto_recovery") then
            local range = tweak_upgrades.values.first_aid_kit.first_aid_kit_auto_recovery[1] or 0
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_first_aid_kit_2"), tostring(range * 0.01), PlayerDamage._UPPERS_COOLDOWN))
        end
        return str
    end,
    grenade_crate = function()
        return string.format("> %s\n> %s", managers.localization:text("ehi_bm_grenade_crate"), managers.localization:text("ehi_bm_grenade_crate_2"))
    end
}
DeployableFormattingFunction.sentry_gun_silent = function()
    return string.format("> %s\n%s", managers.localization:text("ehi_bm_sentry_gun_silent"), DeployableFormattingFunction.sentry_gun())
end

function BlackMarketGui:populate_deployables(data, ...)
    original.populate_deployables(self, data, ...)
    local equipment = tweak_data.equipments
    local blackmarket = tweak_data.blackmarket.deployables
    for _, deployable_data in ipairs(data) do
        if type(deployable_data) == "table" and deployable_data.name ~= "empty" then
            local second_deployable = deployable_data.slot == 2
            local name = deployable_data.name
            local deployable_tweak = equipment[name] or {}
            local deployable_desc = blackmarket[name].desc_id
            RestoreVanillaText(deployable_desc)
            local equipment_amount = 0
            if deployable_tweak.upgrade_name then
                local quantity = deployable_tweak.quantity
                local size_quantity = #quantity
                local n_of_dividers = size_quantity - 1
                local upgrades = deployable_tweak.upgrade_name
                local str = ""
                for j = 1, size_quantity, 1 do
                    local amount = (quantity[j] or 1) + managers.player:equiptment_upgrade_value(upgrades[j], "quantity", 0)
                    if second_deployable then -- Deployable marked as secondary
                        amount = math.ceil(amount / (JackOfAllTradesOverride[name] or 2))
                    end
                    str = str .. "x" .. tostring(amount)
                    if j <= n_of_dividers then
                        str = str .. "|"
                    end
                end
                deployable_data.name_localized = string.format("%s (%s)", deployable_data.name_localized, str)
            else
                equipment_amount = (deployable_tweak.quantity[1] or 1) + managers.player:equiptment_upgrade_value(name, "quantity", 0)
                if second_deployable then -- Deployable marked as secondary
                    equipment_amount = math.ceil(equipment_amount / (JackOfAllTradesOverride[name] or 2))
                end
                deployable_data.name_localized = string.format("%s (x%s)", deployable_data.name_localized, tostring(equipment_amount))
            end
            local str = ""
            if FormatAmount[name] then
                local params = FormatAmount[name]
                local amount = params.base_amount
                local upgrade = 0
                if params.upgrade then
                    local upgrade_level = managers.player:upgrade_level(name, params.upgrade, 0)
                    upgrade = managers.player:upgrade_value_by_level(name, params.upgrade, upgrade_level)
                end
                amount = amount + upgrade
                if second_deployable and params.base_amount ~= amount and equipment_amount > 1 then
                    amount = amount / (JackOfAllTradesOverride[name] or 2)
                end
                if equipment_amount > 1 then
                    str = string.format("> " .. strs.charges, tostring(amount), tostring(amount * 2))
                else
                    str = string.format("> " .. strs.charges_no_total, tostring(amount))
                end
            end
            if DeployableFormattingFunction[name] then
                local s = DeployableFormattingFunction[name](second_deployable)
                if str == "" then
                    str = s
                else
                    str = string.format("%s\n%s", str, s)
                end
            end
            if hide_original_desc then
                AddCustomText(deployable_desc, str)
            else
                local desc = managers.localization:text(deployable_desc)
                AddCustomText(deployable_desc, string.format("%s\n%s", desc, str))
            end
        end
    end
end

local player_upgrades = tweak_data.upgrades.values.player
local team_upgrades = tweak_data.upgrades.values.team
local temp_upgrades = tweak_data.upgrades.values.temporary
local AbilityDuration =
{
    chico_injector = temp_upgrades.chico_injector[1][2],
    smoke_screen_grenade = tweak_data.projectiles.smoke_screen_grenade.duration,
    damage_control = -1,
    tag_team = player_upgrades.tag_team_base[1].duration,
    pocket_ecm_jammer = player_upgrades.pocket_ecm_jammer_base[1].duration
    --copr_ability is checked in the function
}

local CooldownDrain =
{
    pocket_ecm_jammer = player_upgrades.pocket_ecm_jammer_base[1].cooldown_drain,
    copr_ability = player_upgrades.copr_speed_up_on_kill[1]
}

local GrenadeFormattingFunction =
{
    molotov = function()
        local tweak = tweak_data.projectiles.molotov or {}
        return string.format("\n> %s: %ss\n> %s", strs.duration, tostring(tweak.burn_duration or 0), FormatDOTData(tweak.fire_dot_data or {}, strs.fire))
    end,
    wpn_prj_four = function()
        local str = string.format("\n> %s", FormatDOTData({
            -- Hardcoded from DOTBulletBase, PoisonBulletBase inherits the class
            dot_damage = 0.5,
            dot_length = 6,
            dot_tick_period = 0.5
        }, strs.poison))
        return str
    end,
    concussion = function()
        local accuracy = 0.5
        local accuracy_reset = 5
        if CopDamage then
            accuracy = CopDamage._ON_STUN_ACCURACY_DECREASE or accuracy
            accuracy_reset = CopDamage._ON_STUN_ACCURACY_DECREASE_TIME or accuracy_reset
        end
        return string.format("\n> %s\n> %s", managers.localization:text("ehi_bm_concussion_1"), string.format(
            managers.localization:text("ehi_bm_concussion_2"), tostring(accuracy * 100), percent_format, accuracy_reset
        ))
    end,
    fir_com = function()
        local tweak = tweak_data.projectiles.fir_com or {}
        return string.format("\n> %s\n> %s", managers.localization:text("ehi_bm_fir_com"), FormatDOTData(tweak.fire_dot_data or {}, strs.fire))
    end,
    poison_gas_grenade = function()
        local tweak = tweak_data.projectiles.poison_gas_grenade or {}
        local str = string.format("\n> %s\n> %s", managers.localization:text("ehi_bm_poison_gas_grenade_1"), string.format("%s: (%s)", strs.poison, managers.localization:text("ehi_bm_poison_gas_grenade_2")))
        local cloud_range = tweak.poison_gas_range or 0
        if cloud_range > 0 then
            str = string.format("%s\n>> %s: %sm", str, strs.range, tostring(cloud_range * 0.01))
        end
        local cloud_duration = tweak.poison_gas_duration or 0
        if cloud_duration > 0 then
            str = string.format("%s\n>> %s: %ds", str, strs.duration, cloud_duration)
        end
        str = string.format("%s\n> %s", str, FormatDOTData(tweak.poison_gas_dot_data or {}, strs.poison))
        return str
    end,
    sticky_grenade = function()
        return string.format("\n> %s", managers.localization:text("ehi_bm_sticky_grenade"))
    end,
    ---
    chico_injector = function()
        local str = string.format("\n> %s\n> %s", string.format(strs.cooldown_drain, "1"),
        string.format(managers.localization:text("ehi_bm_kingpin_1"), tostring((temp_upgrades.chico_injector[1][1] or 0) * 100), percent_format))
        if managers.player:upgrade_level("player", "chico_preferred_target") ~= 0 then
            str = string.format("%s\n> %s", str, managers.localization:text("ehi_bm_kingpin_2"))
        end
        if managers.player:upgrade_level("player", "chico_injector_low_health_multiplier") ~= 0 then
            local values = player_upgrades.chico_injector_low_health_multiplier[1]
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_kingpin_3"),
            tostring((values[1] or 0) * 100), percent_format, tostring((values[2] or 0) * 100), percent_format))
        end
        if managers.player:upgrade_level("player", "chico_injector_health_to_speed") ~= 0 then
            local values = player_upgrades.chico_injector_health_to_speed[1]
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_kingpin_4"),
            tostring(values[2] or 0), tostring((values[1] or 0) * 10)))
        end
        return str
    end,
    smoke_screen_grenade = function()
        local grenade = tweak_data.projectiles.smoke_screen_grenade
        local str = string.format("\n> %s\n> %s\n> %s", string.format(strs.cooldown_drain, "1"),
        string.format(managers.localization:text("ehi_bm_sicario_1"), tostring((grenade.dodge_chance or 0) * 100), percent_format),
        string.format(managers.localization:text("ehi_bm_sicario_2"), tostring((grenade.accuracy_roll_chance or 0) * 100), percent_format))
        if managers.player:upgrade_level("player", "sicario_multiplier") ~= 0 then
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_sicario_3"), "100", percent_format))
        end
        if managers.player:upgrade_level("player", "smoke_screen_ally_dodge_bonus") ~= 0 then
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_sicario_4"), tostring((player_upgrades.smoke_screen_ally_dodge_bonus[1] or 0) * 100), percent_format))
        end
        return str
    end,
    damage_control = function()
        local str = string.format("\n> %s\n> %s", string.format(strs.cooldown_drain, "1"), string.format(managers.localization:text("ehi_bm_stoic_1")))
        if managers.player:upgrade_level("player", "damage_control_cooldown_drain") == 2 then
            local damage_control_cooldown_drain = player_upgrades.damage_control_cooldown_drain
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_stoic_2"), tostring(damage_control_cooldown_drain[2][1] or 0), percent_format,
            tostring(damage_control_cooldown_drain[2][2] or 0), tostring(damage_control_cooldown_drain[1][2] or 0)))
        end
        return str
    end,
    tag_team = function()
        local health_gain = player_upgrades.tag_team_base[1].kill_health_gain or 0
        local str = string.format("\n> %s", string.format(managers.localization:text("ehi_bm_tagteam_1"),
        health_gain * 10, health_gain * (player_upgrades.tag_team_base[1].tagged_health_gain_ratio or 0) * 10))
        local tag_team_cooldown_drain_level = managers.player:upgrade_level("player", "tag_team_cooldown_drain")
        if tag_team_cooldown_drain_level ~= 0 then
            local values = player_upgrades.tag_team_cooldown_drain[tag_team_cooldown_drain_level] or {}
            local kill_extension = player_upgrades.tag_team_base[1].kill_extension or 0
            if tag_team_cooldown_drain_level == 1 then -- Basic, only your kills reduce cooldown
                str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_tagteam_2_a"), tostring(kill_extension), tostring(values.owner or 0)))
            else -- Max, both your and tagged units reduce cooldown
                str = string.format("%s\n> %s\n> %s\n> %s", str, string.format(managers.localization:text("ehi_bm_tagteam_2_b"), tostring(kill_extension)),
                string.format(managers.localization:text("ehi_bm_tagteam_2_c"), tostring(values.owner or 0)),
                string.format(managers.localization:text("ehi_bm_tagteam_2_d"), tostring(values.tagged or 0)))
            end
        end
        if managers.player:upgrade_level("player", "tag_team_damage_absorption") ~= 0 then
            local values = player_upgrades.tag_team_damage_absorption[1]
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_tagteam_3"), tostring((values.kill_gain or 0) * 10), tostring((values.max or 0) * 10)))
        end
        return str
    end,
    pocket_ecm_jammer = function()
        local str = string.format("\n> %s", string.format(strs.cooldown_drain, tostring(CooldownDrain.pocket_ecm_jammer)))
        if managers.player:upgrade_level("player", "pocket_ecm_heal_on_kill") ~= 0 then
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_hacker_1"), (player_upgrades.pocket_ecm_heal_on_kill[1] or 0) * 10))
        end
        if managers.player:upgrade_level("temporary", "pocket_ecm_kill_dodge") ~= 0 then
            local values = temp_upgrades.pocket_ecm_kill_dodge[1]
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_hacker_2"), tostring((values[1] or 0) * 100),
            percent_format, tostring(values[2] or 0)))
        end
        if managers.player:upgrade_level("team", "pocket_ecm_heal_on_kill") ~= 0 then
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_hacker_3"), (team_upgrades.pocket_ecm_heal_on_kill[1] or 0) * 10))
        end
        return str
    end,
    copr_ability = function()
        local copr_high_damage_multiplier = tweak_data.upgrades.copr_high_damage_multiplier or {}
        local copr_static_damage_ratio = player_upgrades.copr_static_damage_ratio
        local copr_static_damage_ratio_level = managers.player:upgrade_level("player", "copr_static_damage_ratio", 1)
        local segments = 1 / copr_static_damage_ratio[copr_static_damage_ratio_level]
        local str = string.format("\n> %s\n> %s\n> %s\n> %s", string.format(managers.localization:text("ehi_bm_leech_1"), tostring((player_upgrades.copr_activate_bonus_health_ratio[1] or 0) * 100), percent_format),
        string.format(managers.localization:text("ehi_bm_leech_2")),
        string.format(managers.localization:text("ehi_bm_leech_3"), tostring(player_upgrades.copr_kill_life_leech[1] or 0), "1"),
        string.format(managers.localization:text("ehi_bm_leech_4"), tostring(segments), tostring(player_upgrades.copr_kill_life_leech[1] or 0), tostring((copr_high_damage_multiplier[1] or 0) * 10), tostring(copr_high_damage_multiplier[2] or 0)))
        if managers.player:upgrade_level("player", "copr_speed_up_on_kill") ~= 0 then
            str = string.format("%s\n> %s", str, string.format(strs.cooldown_drain, tostring(CooldownDrain.copr_ability)))
        end
        if managers.player:upgrade_level("player", "copr_out_of_health_move_slow") ~= 0 then
            local multiplier = 1 - (player_upgrades.copr_out_of_health_move_slow[1] or 0)
            str = string.format("%s\n> %s", str, string.format(managers.localization:text("ehi_bm_leech_5"), tostring(multiplier * 100), percent_format))
        end
        if managers.player:upgrade_level("player", "activate_ability_downed") ~= 0 then
            str = string.format("%s\n> %s", str, managers.localization:text("ehi_bm_leech_6"))
        end
        return str
    end
}

function BlackMarketGui:populate_grenades(data, ...)
    original.populate_grenades(self, data, ...)
    --EHI:PrintTable(data, "data")
    --local sort_data = managers.blackmarket:get_sorted_grenades()
    --local max_items = math.ceil(#sort_data / (data.override_slots[1] or 3)) * (data.override_slots[1] or 3)
    AbilityDuration.copr_ability = managers.player:upgrade_value("temporary", "copr_ability", temp_upgrades.copr_ability[1] or {})[2] or 0
    local projectile_tweak = tweak_data.blackmarket.projectiles
    local grenade_tweak = tweak_data.projectiles
    for _, grenade_data in ipairs(data) do
        if type(grenade_data) == "table" and grenade_data.name ~= "empty" then
            local grenade = grenade_data.name
            local projectile = projectile_tweak[grenade] or {}
            local grenade_desc = projectile.desc_id
            grenade_data.name_localized = string.format("%s (x%s)", grenade_data.name_localized, tostring(projectile.max_amount or 1))
            RestoreVanillaText(grenade_desc)
            if projectile.ability or grenade == "smoke_screen_grenade" then
                local duration = AbilityDuration[grenade] or 0
                if duration < 0 then
                    duration = strs.instant
                elseif duration == 0 then
                    duration = "???"
                else
                    duration = duration .. "s"
                end
                local str = string.format("> %s: %ds\n> %s: %s", strs.base_cooldown, (projectile.base_cooldown or 0), strs.duration, duration)
                if GrenadeFormattingFunction[grenade] then
                    str = str .. GrenadeFormattingFunction[grenade]()
                end
                if hide_original_desc then
                    AddCustomText(grenade_desc, str)
                else
                    local desc = managers.localization:text(grenade_desc)
                    AddCustomText(grenade_desc, string.format("%s\n%s", desc, str))
                end
            else
                local tweak = grenade_tweak[grenade] or {}
                local damage = tweak.damage or 0
                local str = string.format("> %s: %d", (tweak.curve_pow and damage > 0) and strs.max_dmg or strs.dmg, (damage * 10))
                if tweak.range then
                    str = string.format("%s\n> %s: %sm", str, strs.range, tostring(tweak.range * 0.01))
                end
                if GrenadeFormattingFunction[grenade] then
                    str = str .. GrenadeFormattingFunction[grenade]()
                end
                if hide_original_desc then
                    AddCustomText(grenade_desc, str)
                else
                    local desc = managers.localization:text(grenade_desc)
                    AddCustomText(grenade_desc, string.format("%s\n%s", desc, str))
                end
            end
        end
    end
end