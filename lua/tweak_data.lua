local EHI = EHI
if EHI:CheckHook("tweak_data") then
    return
end
core:import("CoreTable")
local deep_clone = CoreTable.deep_clone
local Icon = EHI.Icons

tweak_data.ehi =
{
    color =
    {
        Inaccurate = Color(255, 255, 165, 0) / 255,
        DrillAutorepair = Color(255, 137, 209, 254) / 255
    },
    icons =
    {
        default = { texture = "guis/textures/pd2/pd2_waypoints", texture_rect = {96, 64, 32, 32} },

        faster = { texture = "guis/textures/pd2/skilltree/drillgui_icon_faster" },
        silent = { texture = "guis/textures/pd2/skilltree/drillgui_icon_silent" },
        restarter = { texture = "guis/textures/pd2/skilltree/drillgui_icon_restarter" },

        xp = { texture = "guis/textures/pd2/blackmarket/xp_drop" },

        mad_scan = { texture = "guis/textures/pd2_mod_ehi/mad_scan" },
        boat = { texture = "guis/textures/pd2_mod_ehi/boat" },
        enemy = { texture = "guis/textures/pd2_mod_ehi/enemy" },
        piggy = { texture = "guis/textures/pd2_mod_ehi/piggy" },
        assaultbox = { texture = "guis/textures/pd2_mod_ehi/assaultbox" },
        deployables = { texture = "guis/textures/pd2_mod_ehi/deployables" },
        padlock = { texture = "guis/textures/pd2_mod_ehi/padlock" },

        reload = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {0, 576, 64, 64} },
        smoke = { texture = "guis/dlcs/max/textures/pd2/specialization/icons_atlas", texture_rect = {0, 0, 64, 64} },
        teargas = { texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2", texture_rect = {128, 256, 128, 128} },
        gage = { texture = "guis/dlcs/gage_pack_jobs/textures/pd2/endscreen/gage_assignment" },
        hostage = { texture = "guis/textures/pd2/hud_icon_hostage" },
        buff_shield = { texture = "guis/textures/pd2/hud_buff_shield" },

        doctor_bag = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/doctor_bag" },
        ammo_bag = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/ammo_bag" },
        first_aid_kit = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/first_aid_kit" },
        bodybags_bag = { texture = "guis/textures/pd2/blackmarket/icons/deployables/outline/bodybags_bag" },
        frag_grenade = { texture = tweak_data.hud_icons.frag_grenade.texture, texture_rect = tweak_data.hud_icons.frag_grenade.texture_rect },

        minion = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 512, 64, 64} },
        heavy = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {192, 64, 64, 64} },
        sniper = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 320, 64, 64} },
        camera_loop = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {256, 128, 64, 64} },
        pager_icon = { texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = {64, 256, 64, 64} },

        ecm_jammer = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {64, 256, 64, 64} },
        ecm_feedback = { texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {384, 128, 64, 64} },

        hoxton_character = { texture = "guis/dlcs/trk/textures/pd2/old_hoxton_unlock_icon" }
    },
    -- Broken units to be "fixed" during mission load
    units =
    {
        -- Doctor Bags
        ["units/payday2/props/stn_prop_medic_firstaid_box/stn_prop_medic_firstaid_box"] = { f = "SetDeployableOffset" }, -- CustomDoctorBagBase / cabinet 1
        ["units/pd2_dlc_casino/props/cas_prop_medic_firstaid_box/cas_prop_medic_firstaid_box"] = { f = "SetDeployableOffset" }, -- CustomDoctorBagBase / cabinet 2
        -- Ammo
        ["units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },
        ["units/pd2_dlc_spa/props/spa_prop_armory_shelf_ammo/spa_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },
        ["units/pd2_dlc_hvh/props/hvh_prop_armory_shelf_ammo/hvh_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },

        ["units/pd2_dlc_chas/equipment/chas_interactable_c4/chas_interactable_c4"] = { icons = { Icon.C4 }, warning = true },
        ["units/pd2_dlc_chas/equipment/chas_interactable_c4_placeable/chas_interactable_c4_placeable"] = { icons = { Icon.C4 }, f = "chasC4" },
        ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_01"] = { disable_set_visible = true },
        ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_02"] = { disable_set_visible = true },
        ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_03"] = { disable_set_visible = true }
    },
    -- Definitions for buffs and their icons
    buff =
    {
        DodgeChance =
        {
            u100skill = true,
            x = 1,
            y = 12,
            class = "EHIDodgeChanceBuffTracker",
            format = "percent",
            activate_after_spawn = true,
            option = "dodge",
            persistent = "dodge_persistent"
        },
        CritChance =
        {
            u100skill = true,
            x = 0,
            y = 12,
            text = "Crit",
            class = "EHICritChanceBuffTracker",
            format = "percent",
            activate_after_spawn = true,
            option = "crit",
            persistent = "crit_persistent"
        },
        Berserker =
        {
            skills = true,
            x = 2,
            y = 2,
            class = "EHIBerserkerBuffTracker",
            check_after_spawn = true,
            option = "berserker"
        },
        Reload =
        {
            skills = true,
            bad = true,
            y = 9,
            option = "reload"
        },
        Interact =
        {
            texture = "guis/textures/pd2/pd2_waypoints",
            texture_rect = {224, 32, 32, 32},
            option = "interact"
        },
        ArmorRegenDelay =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 4,
            option = "shield_regen"
        },
        MeleeCharge =
        {
            skills = true,
            x = 4,
            y = 12,
            class = "EHIMeleeChargeBuffTracker",
            option = "melee_charge"
        },
        headshot_regen_armor_bonus =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 11,
            option = "bullseye"
        },
        combat_medic_damage_multiplier =
        {
            skills = true,
            x = 5,
            y = 7,
            option = "combat_medic"
        },
        berserker_damage_multiplier =
        {
            skills = true,
            x = 5,
            y = 12,
            option = "swan_song"
        },
        dmg_multiplier_outnumbered =
        {
            skills = true,
            text = "Dmg+",
            x = 2,
            y = 1,
            option = "underdog"
        },
        first_aid_damage_reduction =
        {
            skills = true,
            text = "Dmg-",
            x = 1,
            y = 11,
            option = "quick_fix"
        },
        UppersRangeGauge =
        {
            u100skill = true,
            x = 2,
            y = 11,
            check_after_spawn = true,
            class = "EHIUppersRangeBuffTracker",
            option = "uppers_range"
        },
        fast_learner =
        {
            u100skill = true,
            text = "Dmg-",
            y = 10,
            option = "painkillers"
        },
        melee_life_leech =
        {
            deck = true,
            bad = true,
            x = 7,
            y = 4,
            option = "infiltrator"
        },
        dmg_dampener_close_contact =
        {
            deck = true,
            x = 5,
            y = 4,
            option = "underdog"
        },
        loose_ammo_give_team =
        {
            deck = true,
            bad = true,
            x = 5,
            y = 5,
            option = "gambler"
        },
        loose_ammo_restore_health =
        {
            deck = true,
            bad = true,
            x = 4,
            y = 5,
            option = "gambler"
        },
        damage_speed_multiplier =
        {
            u100skill = true,
            text = "Mov+",
            x = 10,
            y = 9,
            option = "second_wind"
        },
        revived_damage_resist =
        {
            u100skill = true,
            text = "Dmg-",
            x = 11,
            y = 4,
            option = "up_you_go"
        },
        swap_weapon_faster =
        {
            u100skill = true,
            text = "Spd+",
            x = 11,
            y = 3,
            option = "running_from_death_reload"
        },
        increased_movement_speed =
        {
            u100skill = true,
            text = "Mov+",
            x = 11,
            y = 3,
            option = "running_from_death_movement"
        },
        unseen_strike =
        {
            u100skill = true,
            text = "Crit+",
            x = 10,
            y = 11,
            option = "unseen_strike",
            --class = "EHIUnseenStrikeBuffTracker"
        },
        melee_damage_stacking =
        {
            u100skill = true,
            x = 11,
            y = 6,
            format = "multiplier",
            class = "EHIGaugeBuffTracker",
            option = "bloodthirst"
        },
        melee_kill_increase_reload_speed =
        {
            u100skill = true,
            x = 11,
            y = 6,
            text = "Rld+",
            option = "bloodthirst_reload"
        },
        standstill_omniscience_initial =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 10
        },
        standstill_omniscience =
        {
            skills = true,
            bad = true,
            x = 6,
            y = 10
        },
        standstill_omniscience_highlighted =
        {
            skills = true,
            x = 6,
            y = 10,
            class = "EHIGaugeBuffTracker"
        },
        bullet_storm =
        {
            u100skill = true,
            x = 4,
            y = 5,
            option = "bulletstorm"
        },
        hostage_absorption =
        {
            u100skill = true,
            x = 4,
            y = 7,
            class = "EHIGaugeBuffTracker"
        },
        ManiacStackTicks =
        {
            deck = true,
            folder = "coco",
            option = "maniac"
        },
        ManiacDecayTicks =
        {
            deck = true,
            folder = "coco",
            x = 2,
            option = "maniac"
        },
        ManiacAccumulatedStacks =
        {
            deck = true,
            folder = "coco",
            x = 3,
            class = "EHIGaugeBuffTracker",
            format = "percent",
            option = "maniac"
        },
        GrinderStackCooldown =
        {
            deck = true,
            bad = true,
            x = 5,
            y = 6,
            option = "grinder"
        },
        GrinderRegenPeriod =
        {
            deck = true,
            x = 5,
            y = 6,
            option = "grinder"
        },
        SicarioTwitchGauge =
        {
            deck = true,
            folder = "max",
            x = 1,
            class = "EHIGaugeBuffTracker",
            format = "percent"
        },
        SicarioTwitchCooldown =
        {
            deck = true,
            folder = "max",
            bad = true,
            x = 1
        },
        ammo_efficiency =
        {
            u100skill = true,
            x = 8,
            y = 4,
            option = "ammo_efficiency"
        },
        armor_break_invulnerable =
        {
            deck = true,
            bad = true,
            x = 6,
            y = 1,
            option = "anarchist"
        },
        single_shot_fast_reload =
        {
            u100skill = true,
            text = "Rld+",
            x = 8,
            y = 3,
            option = "aggressive_reload"
        },
        overkill_damage_multiplier =
        {
            skills = true,
            text = "Dmg+",
            x = 3,
            y = 2,
            option = "overkill"
        },
        morale_boost =
        {
            skills = true,
            bad = true,
            x = 4,
            y = 9,
            option = "inspire_basic"
        },
        long_dis_revive =
        {
            u100skill = true,
            bad = true,
            x = 4,
            y = 9,
            option = "inspire_ace"
        },
        DireNeed =
        {
            u100skill = true,
            text = "Stagger",
            no_progress = true,
            x = 10,
            y = 8,
            option = "dire_need"
        },
        Immunity =
        {
            deck = true,
            x = 6,
            option = "anarchist"
        },
        UppersCooldown =
        {
            u100skill = true,
            bad = true,
            x = 2,
            y = 11,
            option = "uppers"
        },
        armor_grinding =
        {
            deck = true,
            folder = "opera",
            option = "anarchist"
        },
        HealthRegen =
        {
            skills = true,
            x = 2,
            y = 10,
            class = "EHIHostageTakerMuscleRegenBuffTracker",
            option = "hostage_taker_muscle"
        },
        crew_throwable_regen =
        {
            texture = tweak_data.hud_icons.skill_7.texture,
            texture_rect = tweak_data.hud_icons.skill_7.texture_rect,
            class = "EHIGaugeBuffTracker",
            option = "regen_throwable_ai"
        },
        Stamina =
        {
            skills = true,
            x = 7,
            y = 3,
            class = "EHIStaminaBuffTracker",
            format = "percent",
            option = "stamina"
        },
        BikerBuff =
        {
            deck = true,
            folder = "wild",
            class = "EHIBikerBuffTracker",
            check_after_spawn = true,
            option = "biker"
        },
        chico_injector =
        {
            deck = true,
            folder = "chico",
            option = "kingpin"
        },
        SmokeScreen =
        {
            deck = true,
            folder = "max",
            option = "sicario"
        },
        damage_control =
        {
            deck = true,
            folder = "myh",
            class = "EHIStoicBuffTracker"
        },
        damage_control_cooldown =
        {
            bad = true,
            deck = true,
            folder = "myh",
            y = 1
        },
        TagTeamEffect =
        {
            deck = true,
            folder = "ecp",
            y = 1
        },
        pocket_ecm_kill_dodge =
        {
            deck = true,
            folder = "joy",
            x = 3,
            class = "EHIHackerTemporaryDodgeBuffTracker",
            option = "hacker"
        },
        HackerJammerEffect =
        {
            skills = true,
            x = 6,
            y = 3
        },
        HackerFeedbackEffect =
        {
            skills = true,
            x = 6,
            y = 2
        },
        copr_ability =
        {
            deck = true,
            folder = "copr",
            option = "leech"
        },
        headshot_regen_health_bonus =
        {
            deck = true,
            folder = "mrwi",
            bad = true,
            x = 1,
            option = "copycat"
        },
        mrwi_health_invulnerable =
        {
            deck = true,
            folder = "mrwi",
            x = 3,
            option = "copycat"
        }
    },
    functions =
    {
        IsBranchbankJobActive = function()
            local current_job = managers.job:current_job_id()
            for _, job in ipairs(tweak_data.achievement.complete_heist_achievements.uno_1.jobs) do
                if current_job == job then
                    return true
                end
            end
            return false
        end,
        ShowNumberOfLootbagsOnTheGround = function()
            local max = managers.ehi:CountLootbagsOnTheGround()
            if max == 0 then
                return
            end
            EHI:ShowLootCounterNoCheck({ max = max })
        end,
        ---@param weapons table
        GetNumberOfVisibleWeapons = function(weapons)
            local n = 0
            local world = managers.worlddefinition
            for _, index in ipairs(weapons or {}) do
                local weapon = world:get_unit(index)
                if weapon and weapon:damage() and weapon:damage()._state and weapon:damage()._state.graphic_group and weapon:damage()._state.graphic_group.grp_wpn then
                    local state = weapon:damage()._state.graphic_group.grp_wpn
                    if state[1] == "set_visibility" and state[2] then
                        n = n + 1
                    end
                end
            end
            return n
        end,
        ---Checks money, coke and gold and other loot which uses "var_hidden"
        ---@param loot table
        GetNumberOfVisibleOtherLoot = function(loot)
            local n = 0
            local world = managers.worlddefinition
            for _, index in ipairs(loot) do
                local unit = world:get_unit(index)
                if unit and unit:damage() and unit:damage()._variables and unit:damage()._variables.var_hidden == 0 then
                    n = n + 1
                end
            end
            return n
        end,
        FormatSecondsOnly = function(self)
            local t = math.floor(self._time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 1 then
                return string.format("%.2f", self._time)
            elseif t < 10 then
                return string.format("%.1f", t)
            else
                return string.format("%d", t)
            end
        end,
        FormatMinutesAndSeconds = function(self)
            local t = math.floor(self._time * 10) / 10
            if t < 0 then
                return string.format("%d", 0)
            elseif t < 1 then
                return string.format("%.2f", self._time)
            elseif t < 10 then
                return string.format("%.1f", t)
            elseif t < 60 then
                return string.format("%d", t)
            else
                return string.format("%d:%02d", t / 60, t % 60)
            end
        end
    }
}

tweak_data.ehi.buff.team_crew_inspire = deep_clone(tweak_data.ehi.buff.long_dis_revive)
tweak_data.ehi.buff.team_crew_inspire.text = "AI"
tweak_data.ehi.buff.team_crew_inspire.option = "inspire_ai"
tweak_data.ehi.buff.reload_weapon_faster = deep_clone(tweak_data.ehi.buff.swap_weapon_faster)
tweak_data.ehi.buff.reload_weapon_faster.text = "Rld+"
tweak_data.ehi.buff.chico_injector_cooldown = deep_clone(tweak_data.ehi.buff.chico_injector)
tweak_data.ehi.buff.chico_injector_cooldown.bad = true
tweak_data.ehi.buff.tag_team_cooldown = deep_clone(tweak_data.ehi.buff.chico_injector_cooldown)
tweak_data.ehi.buff.tag_team_cooldown.folder = "ecp"
tweak_data.ehi.buff.tag_team_cooldown.option = "tag_team"
tweak_data.ehi.buff.pocket_ecm_jammer_cooldown = deep_clone(tweak_data.ehi.buff.chico_injector_cooldown)
tweak_data.ehi.buff.pocket_ecm_jammer_cooldown.folder = "joy"
tweak_data.ehi.buff.pocket_ecm_jammer_cooldown.option = "hacker"
tweak_data.ehi.buff.copr_ability_cooldown = deep_clone(tweak_data.ehi.buff.chico_injector_cooldown)
tweak_data.ehi.buff.copr_ability_cooldown.folder = "copr"
tweak_data.ehi.buff.copr_ability_cooldown.option = "leech"
tweak_data.ehi.buff.mrwi_health_invulnerable_cooldown = deep_clone(tweak_data.ehi.buff.mrwi_health_invulnerable)
tweak_data.ehi.buff.mrwi_health_invulnerable_cooldown.bad = true

tweak_data.hud_icons.EHI_XP = { texture = tweak_data.ehi.icons.xp.texture }
tweak_data.hud_icons.EHI_Gage = { texture = tweak_data.ehi.icons.gage.texture }
tweak_data.hud_icons.EHI_Minion = tweak_data.ehi.icons.minion
tweak_data.hud_icons.EHI_Loot = tweak_data.hud_icons.pd2_loot

do
    local preplanning = tweak_data.preplanning
    local path = preplanning.gui.type_icons_path
    local text_rect_blimp = preplanning:get_type_texture_rect(preplanning.types.kenaz_faster_blimp.icon)
    text_rect_blimp[1] = text_rect_blimp[1] + text_rect_blimp[3] -- Add the negated "w" value so it will correctly show blimp
    text_rect_blimp[3] = -text_rect_blimp[3] -- Flip the image so it will face correctly
    tweak_data.ehi.icons.blimp = { texture = path, texture_rect = text_rect_blimp }
    tweak_data.ehi.icons.heli = { texture = path, texture_rect = preplanning:get_type_texture_rect(preplanning.types.kenaz_ace_pilot.icon) }
    tweak_data.hud_icons.EHI_Heli = tweak_data.ehi.icons.heli
end