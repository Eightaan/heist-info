local EHI = EHI
if EHI:CheckLoadHook("IngameWaitingForPlayersState") then
    return
end

if EHI:GetOption("show_gage_tracker") then
    if EHI:GetOption("gage_tracker_panel") == 1 then
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            if managers.ehi:TrackerDoesNotExist("Gage") and EHI:AreGagePackagesSpawned() then
                managers.ehi:AddTracker({
                    id = "Gage",
                    icons = { "gage" },
                    progress = EHI._cache.GagePackagesProgress or 0,
                    max = tweak_data.gage_assignment:get_num_assignment_units(),
                    class = EHI.Trackers.Progress
                })
            end
        end)
    else
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            if EHI:AreGagePackagesSpawned() and EHI:IsPlayingFromStart() then
                local max = tweak_data.gage_assignment:get_num_assignment_units()
                managers.hud:custom_ingame_popup_text(managers.localization:text("ehi_popup_gage_packages"), "0/" .. tostring(max), "EHI_Gage")
            end
        end)
    end
end

local primary, secondary, melee, grenade, is_stealth = nil, nil, nil, nil, false
local VeryHardOrAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard)
local OVKOrAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
--local MayhemOrAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem)
local stats = {}

local function HasWeaponEquipped(weapon_id)
    return primary.weapon_id == weapon_id or secondary.weapon_id == weapon_id
end

local function HasWeaponTypeEquipped(type)
    local primary_categories = tweak_data.weapon[primary.weapon_id] and tweak_data.weapon[primary.weapon_id].categories or {}
    local secondary_categories = tweak_data.weapon[secondary.weapon_id] and tweak_data.weapon[secondary.weapon_id].categories or {}
    return table.contains(primary_categories, type) or table.contains(secondary_categories, type)
end

local function HasMeleeEquipped(melee_id)
    return melee == melee_id
end

local function HasMeleeTypeEquipped(type)
    local melee_tweak = tweak_data.blackmarket.melee_weapons[melee]
    return melee_tweak and melee_tweak.type and melee_tweak.type == type
end

local function HasGrenadeEquipped(grenade_id)
    return grenade == grenade_id
end

local function HasNonExplosiveGrenadeEquipped()
    local projectile = tweak_data.blackmarket.projectiles[grenade]
    local tweak = tweak_data.projectiles[grenade]
    if projectile and tweak then
        if projectile.ability then
            return false
        elseif not projectile.is_explosive then
            return tweak.damage and tweak.damage > 0
        end
    end
    return false
end

local function HasPlayerStyleEquipped(player_style_id)
    return managers.blackmarket:equipped_player_style() == player_style_id
end

local function HasSuitVariationEquipped(variation_id)
    return managers.blackmarket:equipped_suit_variation() == variation_id
end

local function WeaponsContainBlueprint(blueprint)
    local function CheckWeaponBlueprint(weapon_data)
        return table.contains(weapon_data.blueprint or {}, blueprint)
    end
    return CheckWeaponBlueprint(primary) or CheckWeaponBlueprint(secondary)
end

local function CheckWeaponsBlueprint(blueprint)
    local function CheckWeaponBlueprint(weapon_data)
        return table.contains(weapon_data.blueprint or {}, blueprint)
    end
    local pass, primary_pass, secondary_pass = false, false, false
    if CheckWeaponBlueprint(primary) then
        pass = true
        primary_pass = true
    end
    if CheckWeaponBlueprint(secondary) then
        pass = true
        secondary_pass = true
    end
    return pass, primary_pass, secondary_pass
end

local function ArbiterHasStandardAmmo()
    local function WeaponHasStandardAmmo(factory_id, blueprint)
        local t = managers.weapon_factory:get_ammo_data_from_weapon(factory_id, blueprint)
        return table.size(t or {}) == 0 -- Standard ammo type is not returned in the array, only the ammo upgrades
    end
    if primary.weapon_id == "arbiter" and WeaponHasStandardAmmo(primary.factory_id, primary.blueprint) then
        return true
    end
    if secondary.weapon_id == "arbiter" and WeaponHasStandardAmmo(secondary.factory_id, secondary.blueprint) then
        return true
    end
    return false
end

local function HasViperGrenadesOnLauncherEquipped()
    local function HasViperAmmo(factory_id, blueprint)
        local t = managers.weapon_factory:get_ammo_data_from_weapon(factory_id, blueprint)
        if table.size(t or {}) ~= 0 then
            return table.contains(t, "launcher_poison") or table.contains(t, "launcher_poison_ms3gl_conversion")
        end
        return false
    end
    return HasViperAmmo(primary.factory_id, primary.blueprint) or HasViperAmmo(secondary.factory_id, secondary.blueprint)
end

local function WeaponsContainFiremode(firemode)
    local function FireModeExists(weapon_id)
        local tweak_data = tweak_data.weapon[weapon_id]
        if not tweak_data then
            return false
        end
        local firemode_data = tweak_data.fire_mode_data
        if not firemode_data then
            return false
        end
        if firemode_data[firemode] then
            return true
        end
        local firemode_toggable = firemode_data.toggable
        if not firemode_toggable then
            return false
        end
        return table.contains(firemode_toggable, firemode)
    end
    return FireModeExists(primary.weapon_id) or FireModeExists(secondary.weapon_id)
end

local function CreateProgressTracker(id, progress, max, dont_flash, remove_after_reaching_target, status_is_overridable, icons)
    managers.ehi:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = icons or EHI:GetAchievementIcon(id),
        dont_flash = dont_flash,
        flash_times = 1,
        remove_after_reaching_target = remove_after_reaching_target,
        status_is_overridable = status_is_overridable,
        no_failure = true,
        class = EHI.Trackers.AchievementProgress
    })
end

local function HookKillFunctionNoCivilian(achievement, weapon_id)
    EHI:HookWithID(StatisticsManager, "killed", "EHI_" .. achievement .. "_" .. weapon_id .. "_killed", function(self, data)
        if data.variant ~= "melee" and not CopDamage.is_civilian(data.name) then
            local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
            if name_id == weapon_id then
                managers.ehi:IncreaseTrackerProgress(achievement)
            end
        end
    end)
end

local function ShowTrackerInLoud(f)
    if is_stealth then
        EHI:AddOnAlarmCallback(f)
    else
        f()
    end
end

local function ShowPopup(id, progress, max)
    managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text("achievement_" .. id), tostring(progress) .. "/" .. tostring(max), EHI:GetAchievementIconString(id))
end

local pxp_1_checked = false
-- "Plague Doctor" achievement
local function pxp_1()
    if pxp_1_checked then
        return
    end
    if EHI:IsAchievementLocked2("pxp1_1") then
        local grenade_data = tweak_data.achievement.grenade_achievements.pxp1_1
        local grenade_pass = table.index_of(grenade_data.grenade_types, grenade) ~= -1
        local enemy_kills_data = tweak_data.achievement.enemy_kill_achievements.pxp1_1
        local parts_pass, _, _ = CheckWeaponsBlueprint(enemy_kills_data.parts)
        local melee_pass = table.index_of(tweak_data.achievement.enemy_melee_hit_achievements.pxp1_1.melee_weapons, melee) ~= 1
        local player_style_pass = HasPlayerStyleEquipped(grenade_data.player_style.style)
        local variation_pass = HasSuitVariationEquipped(grenade_data.player_style.variation)
        if (grenade_pass or parts_pass or melee_pass or HasViperGrenadesOnLauncherEquipped()) and player_style_pass and variation_pass then
            CreateProgressTracker("pxp1_1", EHI:GetAchievementProgress("pxp1_1_stats"), 200, false)
            stats.pxp1_1_stats = "pxp1_1"
        end
    end
    pxp_1_checked = true
end

local original =
{
    at_exit = IngameWaitingForPlayersState.at_exit
}
function IngameWaitingForPlayersState:at_exit(...)
    original.at_exit(self, ...)
    if not Global.hud_disabled then
        managers.ehi:ShowPanel()
    end
    --[[if level == "flat" and EHI:IsAchievementLocked("flat_5") then
        managers.ehi:AddTracker({
            id = "flat_5",
            icons = { "C_Classics_H_PanicRoom_DontYouDare" },
            dont_flash = true,
            class = "EHIChanceTracker"
        })
    else]]
    EHI:CallCallbackOnce(EHI.CallbackMessage.Spawned)
    if not EHI:GetUnlockableAndOption("show_achievements") or EHI._cache.UnlockablesAreDisabled or GunGameGame or TIM then -- Twitch Integration Mod
        return
    end
    primary = managers.blackmarket:equipped_primary()
    secondary = managers.blackmarket:equipped_secondary()
    melee = managers.blackmarket:equipped_melee_weapon()
    grenade = managers.blackmarket:equipped_grenade()
    is_stealth = managers.groupai:state():whisper_mode()
    local level = Global.game_settings.level_id
    local mask_id = managers.blackmarket:equipped_mask().mask_id
    if EHI:GetUnlockableOption("show_achievements_weapon") then -- Kill with weapons (primary or secondary)
        if EHI:IsAchievementLocked2("halloween_6") and mask_id == tweak_data.achievement.pump_action.mask and HasWeaponTypeEquipped("shotgun") then -- "Pump-Action" achievement
            CreateProgressTracker("halloween_6", EHI:GetAchievementProgress("halloween_6_stats"), 666, false, true)
            stats.halloween_6_stats = "halloween_6"
        end
        if EHI:IsAchievementLocked2("halloween_8") and HasWeaponEquipped("usp") then -- "The Pumpkin King Made Me Do It!" achievement
            CreateProgressTracker("halloween_8", EHI:GetAchievementProgress("halloween_8_stats"), 666, false, true)
            stats.halloween_8_stats = "halloween_8"
        end
        if EHI:IsAchievementLocked2("armored_5") and HasWeaponEquipped("ppk") then -- "License to Kill" achievement
            CreateProgressTracker("armored_5", EHI:GetAchievementProgress("armored_5_stat"), 378, false, true)
            stats.armored_5_stat = "armored_5"
        end
        if EHI:IsAchievementLocked2("armored_7") and HasWeaponEquipped("s552") and mask_id == tweak_data.achievement.enemy_kill_achievements.im_not_a_crook.mask then -- "I'm Not a Crook!" achievement
            local function f()
                CreateProgressTracker("armored_7", EHI:GetAchievementProgress("armored_7_stat"), 69, false, true)
            end
            ShowTrackerInLoud(f)
            stats.armored_7_stat = "armored_7"
        end
        if EHI:IsAchievementLocked2("armored_9") and HasWeaponEquipped("m45") and mask_id == tweak_data.achievement.enemy_kill_achievements.fool_me_once.mask then -- "Fool Me Once, Shame on -Shame on You. Fool Me - You Can't Get Fooled Again" achievement
            local function f()
                CreateProgressTracker("armored_9", EHI:GetAchievementProgress("armored_9_stat"), 95, false, true)
            end
            ShowTrackerInLoud(f)
            stats.armored_9_stat = "armored_9"
        end
        if EHI:IsAchievementLocked2("gage_1") and HasWeaponEquipped("ak5") and mask_id == tweak_data.achievement.enemy_kill_achievements.wanted.mask then -- "Wanted" achievement
            CreateProgressTracker("gage_1", EHI:GetAchievementProgress("gage_1_stats"), 100, false, true)
            stats.gage_1_stats = "gage_1"
        end
        if EHI:IsAchievementLocked2("gage_2") and HasWeaponEquipped("p90") and mask_id == tweak_data.achievement.enemy_kill_achievements.three_thousand_miles.mask then -- "3000 Miles to the Safe House" achievement
            CreateProgressTracker("gage_2", EHI:GetAchievementProgress("gage_2_stats"), 100, false, true)
            stats.gage_2_stats = "gage_2"
        end
        if EHI:IsAchievementLocked2("gage_3") and HasWeaponEquipped("aug") and mask_id == tweak_data.achievement.enemy_kill_achievements.commando.mask then -- "Commando" achievement
            CreateProgressTracker("gage_3", EHI:GetAchievementProgress("gage_3_stats"), 100, false, true)
            stats.gage_3_stats = "gage_3"
        end
        if EHI:IsAchievementLocked2("gage_4") and HasWeaponEquipped("m45") and mask_id == tweak_data.achievement.enemy_kill_achievements.public_enemies.mask then -- "Public Enemies" achievement
            CreateProgressTracker("gage_4", EHI:GetAchievementProgress("gage_4_stats"), 100, false, true)
            stats.gage_4_stats = "gage_4"
        end
        if EHI:IsAchievementLocked2("gage_5") and HasWeaponEquipped("scar") then -- "Inception" achievement
            CreateProgressTracker("gage_5", EHI:GetAchievementProgress("gage_5_stats"), 100, false, true)
            stats.gage_5_stats = "gage_5"
        end
        if EHI:IsAchievementLocked2("gage_6") and HasWeaponEquipped("mp7") then -- "Hard Corps" achievement
            CreateProgressTracker("gage_6", EHI:GetAchievementProgress("gage_6_stats"), 100, false, true)
            stats.gage_6_stats = "gage_6"
        end
        if EHI:IsAchievementLocked2("gage_7") and HasWeaponEquipped("p226") then -- "Above the Law" achievement
            CreateProgressTracker("gage_7", EHI:GetAchievementProgress("gage_7_stats"), 100, false, true)
            stats.gage_7_stats = "gage_7"
        end
        if EHI:IsAchievementLocked2("gage2_5") and HasWeaponTypeEquipped("lmg") then -- "The Eighth and Final Rule" achievement
            CreateProgressTracker("gage2_5", 0, 220, false, true)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_gage2_5_killed", function(self, data)
                if data.variant ~= "melee" and data.weapon_unit and data.weapon_unit:base().is_category and data.weapon_unit:base():is_category("lmg") and not CopDamage.is_civilian(data.name) then
                    managers.ehi:IncreaseTrackerProgress("gage2_5")
                end
            end)
        end
        if EHI:IsAchievementLocked2("gage3_6") and HasWeaponTypeEquipped("snp") then
            if EHI:IsAchievementLocked2("gage3_3") then -- "Lord of the Flies" achievement
                CreateProgressTracker("gage3_3", EHI:GetAchievementProgress("gage3_3_stats"), 50, false, true)
                stats.gage3_3_stats = "gage3_3"
            end
            if EHI:IsAchievementLocked2("gage3_4") then -- "Arachne's Curse" achievement
                CreateProgressTracker("gage3_4", EHI:GetAchievementProgress("gage3_4_stats"), 100, false, true)
                stats.gage3_4_stats = "gage3_4"
            end
            if EHI:IsAchievementLocked2("gage3_5") then -- "Pest Control" achievement
                CreateProgressTracker("gage3_5", EHI:GetAchievementProgress("gage3_5_stats"), 250, false, true)
                stats.gage3_5_stats = "gage3_5"
            end
            CreateProgressTracker("gage3_6", EHI:GetAchievementProgress("gage3_6_stats"), 500, false, true) -- "Seer of Death" achievement
            stats.gage3_6_stats = "gage3_6"
        end
        if EHI:IsAchievementLocked2("gage3_7") and HasWeaponEquipped("m95") then -- "Far, Far Away" achievement
            CreateProgressTracker("gage3_7", EHI:GetAchievementProgress("gage3_7_stats"), 25, false, true)
            stats.gage3_7_stats = "gage3_7"
        end
        if EHI:IsAchievementLocked2("gage3_10") and HasWeaponEquipped("r93") then -- "Maximum Penetration" achievement
            CreateProgressTracker("gage3_10", EHI:GetAchievementProgress("gage3_10_stats"), 10, false, true)
            stats.gage3_10_stats = "gage3_10"
        end
        if EHI:IsAchievementLocked2("gage3_11") and HasWeaponEquipped("m95") then -- "Dodge This" achievement
            local function f()
                CreateProgressTracker("gage3_11", EHI:GetAchievementProgress("gage3_11_stats"), 10, false, true)
            end
            ShowTrackerInLoud(f)
            stats.gage3_11_stats = "gage3_11"
        end
        if EHI:IsAchievementLocked2("gage3_12") and HasWeaponEquipped("m95") then -- "Surprise Motherfucker" achievement
            local function f()
                CreateProgressTracker("gage3_12", EHI:GetAchievementProgress("gage3_12_stats"), 10, false, true)
            end
            ShowTrackerInLoud(f)
            stats.gage3_12_stats = "gage3_12"
        end
        if EHI:IsAchievementLocked2("gage3_13") and HasWeaponTypeEquipped("snp") then -- "Didn't See That Coming Did You?" achievement
            local pass = false
            for _, unit in ipairs(ZipLine.ziplines) do
                if unit:zipline():is_usage_type_person() then
                    pass = true
                    break
                end
            end
            if pass then
                local progress = EHI:GetAchievementProgress("gage3_13_stats")
                if level == "pbr" or level == "shoutout_raid" or level == "pent" then
                    EHI:HookWithID(AchievmentManager, "award_progress", "EHI_gage3_13_AwardProgress", function(am, stat, value)
                        if stat == "gage3_13_stats" then
                            progress = progress + (value or 1)
                            if progress >= 10 then
                                EHI:Unhook("gage3_13_AwardProgress")
                                return
                            end
                            ShowPopup("gage3_13", progress, 10)
                        end
                    end)
                else
                    CreateProgressTracker("gage3_13", progress, 10, false, true)
                    stats.gage3_13_stats = "gage3_13"
                end
            end
        end
        if EHI:IsAchievementLocked2("gage3_14") and HasWeaponEquipped("msr") then -- "Return to Sender" achievement
            local function f()
                CreateProgressTracker("gage3_14", EHI:GetAchievementProgress("gage3_14_stats"), 25, false, true)
            end
            ShowTrackerInLoud(f)
            stats.gage3_14_stats = "gage3_14"
        end
        if EHI:IsAchievementLocked2("gage3_15") and HasWeaponEquipped("r93") then -- "You Can't Hide" achievement
            CreateProgressTracker("gage3_15", EHI:GetAchievementProgress("gage3_15_stats"), 25, false, true)
            stats.gage3_15_stats = "gage3_15"
        end
        if EHI:IsAchievementLocked2("gage3_16") and HasWeaponEquipped("msr") then -- "Double Kill" achievement
            CreateProgressTracker("gage3_16", EHI:GetAchievementProgress("gage3_16_stats"), 25, false, true)
            stats.gage3_15_stats = "gage3_16"
        end
        if EHI:IsAchievementLocked2("gage3_17") and HasWeaponEquipped("msr") then -- "Public Enemy No. 1" achievement
            CreateProgressTracker("gage3_17", EHI:GetAchievementProgress("gage3_17_stats"), 250, false, true)
            stats.gage3_17_stats = "gage3_17"
        end
        if EHI:IsAchievementLocked2("gage4_6") and HasWeaponTypeEquipped("shotgun") and WeaponsContainBlueprint("wpn_fps_upg_a_slug") then -- "Knock, Knock" achievement
            local function f()
                CreateProgressTracker("gage4_6", EHI:GetAchievementProgress("gage4_6_stats"), 50, false, true)
            end
            ShowTrackerInLoud(f)
            stats.gage4_6_stats = "gage4_6"
        end
        if EHI:IsAchievementLocked2("gage4_8") and HasWeaponTypeEquipped("shotgun") and WeaponsContainBlueprint("wpn_fps_upg_a_piercing") then -- "Clay Pigeon Shooting" achievement
            local function f()
                CreateProgressTracker("gage4_8", EHI:GetAchievementProgress("gage4_8_stats"), 10, false, true)
            end
            ShowTrackerInLoud(f)
            stats.gage4_8_stats = "gage4_8"
        end
        if EHI:IsAchievementLocked2("gage4_10") and HasWeaponTypeEquipped("shotgun") then -- "Bang for the Buck" achievement
            if WeaponsContainBlueprint("wpn_fps_upg_a_custom") or WeaponsContainBlueprint("wpn_fps_upg_a_custom_free") then
                local function f()
                    CreateProgressTracker("gage4_10", EHI:GetAchievementProgress("gage4_10_stats"), 10, false, true)
                end
                ShowTrackerInLoud(f)
                stats.gage4_10_stats = "gage4_10"
            end
        end
        if EHI:IsAchievementLocked2("gage5_1") and HasWeaponEquipped("g3") then -- "Precision Aiming" achievement
            local function f()
                CreateProgressTracker("gage5_1", EHI:GetAchievementProgress("gage5_1_stats"), 25, false, true)
            end
            ShowTrackerInLoud(f)
            stats.gage5_1_stats = "gage5_1"
        end
        if EHI:IsAchievementLocked2("gage5_5") and HasWeaponEquipped("gre_m79") then -- "Artillery Barrage" achievement
            CreateProgressTracker("gage5_5", EHI:GetAchievementProgress("gage5_5_stats"), 25, false, true)
            stats.gage5_1_stats = "gage5_5"
        end
        if EHI:IsAchievementLocked2("gage5_9") and HasWeaponEquipped("galil") then -- "Rabbit Hunting" achievement
            local function f()
                CreateProgressTracker("gage5_9", EHI:GetAchievementProgress("gage5_9_stats"), 10, false, true)
            end
            ShowTrackerInLoud(f)
            stats.gage5_9_stats = "gage5_9"
        end
        if EHI:IsAchievementLocked2("gage5_10") and HasWeaponEquipped("famas") then -- "Tour de Clarion" achievement
            CreateProgressTracker("gage5_10", EHI:GetAchievementProgress("gage5_10_stats"), 200, false, true)
            stats.gage5_10_stats = "gage5_10"
        end
        if EHI:IsAchievementLocked2("eagle_1") and HasWeaponEquipped("mosin") then -- "Death From Below" achievement
            local function f()
                CreateProgressTracker("eagle_1", EHI:GetAchievementProgress("eagle_1_stats"), 25, false, true)
            end
            ShowTrackerInLoud(f)
            stats.eagle_1_stats = "eagle_1"
        end
        if EHI:IsAchievementLocked2("ameno_8") then -- "The Collector" achievement
            local needed_weapons = tweak_data.achievement.enemy_kill_achievements.akm4_shootout.weapons
            local primary_pass = table.index_of(needed_weapons, primary.weapon_id) ~= -1
            local secondary_pass = table.index_of(needed_weapons, secondary.weapon_id) ~= -1
            if primary_pass or secondary_pass then
                CreateProgressTracker("ameno_8", EHI:GetAchievementProgress("ameno_08_stats"), 100, false, true)
                stats.ameno_08_stats = "ameno_8"
            end
        end
        if EHI:IsAchievementLocked2("turtles_1") and HasWeaponEquipped("wa2000") then -- "Names Are for Friends, so I Don't Need One" achievement
            CreateProgressTracker("turtles_1", 0, 11, false, true)
            HookKillFunctionNoCivilian("turtles_1", "wa2000")
            EHI:Hook(RaycastWeaponBase, "on_reload", function(self, amount)
                if self:get_name_id() == "wa2000" then
                    managers.ehi:SetTrackerProgress("turtles_1", 0)
                end
            end)
        end
        if EHI:IsAchievementLocked2("turtles_2") and HasWeaponEquipped("polymer") then -- "Swiss Cheese" achievement
            CreateProgressTracker("turtles_2", 0, 100, false, true)
            HookKillFunctionNoCivilian("turtles_2", "polymer")
        end
        if EHI:IsAchievementLocked2("tango_achieve_2") and HasWeaponEquipped("arbiter") and ArbiterHasStandardAmmo() then -- "Let Them Fly" achievement
            local function f()
                CreateProgressTracker("tango_achieve_2", EHI:GetAchievementProgress("tango_2_stats"), 50, false, true)
            end
            ShowTrackerInLoud(f)
            stats.tango_2_stats = "tango_achieve_2"
        end
        if EHI:IsAchievementLocked2("grv_2") and HasWeaponEquipped("coal") then -- "Spray Control" achievement
            CreateProgressTracker("grv_2", 0, 32, false, true)
            HookKillFunctionNoCivilian("grv_2", "coal")
            EHI:Hook(RaycastWeaponBase, "on_reload", function(self, amount)
                if self:get_name_id() == "coal" then
                    managers.ehi:SetTrackerProgress("grv_2", 0)
                end
            end)
        end
        if EHI:IsAchievementLocked2("grv_3") then -- "Have Nice Day!" achievement
            local weapons_required = tweak_data.achievement.enemy_kill_achievements.grv_3.weapons
            local pass = table.index_of(weapons_required, primary.weapon_id) ~= -1
            local pass2 = table.index_of(weapons_required, secondary.weapon_id) ~= -1
            if pass or pass2 then
                CreateProgressTracker("grv_3", EHI:GetAchievementProgress("grv_3_stats"), 300, false, true)
                stats.grv_3_stats = "grv_3"
            end
        end
        if EHI:IsAchievementLocked2("cac_2") then -- "Human Sentry Gun" achievement
            local pass, _, _ = CheckWeaponsBlueprint("wpn_fps_upg_bp_lmg_lionbipod")
            if pass then
                local function f()
                    local enemy_killed_key = "EHI_cac_2_enemy_killed"
                    CreateProgressTracker("cac_2", 0, 20, false, true)
                    local function on_enemy_killed(...)
                        managers.ehi:IncreaseTrackerProgress("cac_2")
                    end
                    local function on_player_state_changed(state_name)
                        managers.ehi:SetTrackerProgress("cac_2", 0)
                        if state_name == "bipod" then
                            managers.player:register_message(Message.OnEnemyKilled, enemy_killed_key, on_enemy_killed)
                        else
                            managers.player:unregister_message(Message.OnEnemyKilled, enemy_killed_key)
                        end
                    end
                    managers.player:register_message("player_state_changed", "EHI_cac_2_state_changed_key", on_player_state_changed)
                end
                ShowTrackerInLoud(f)
            end
        end
        if EHI:IsAchievementLocked2("pxp2_1") and HasWeaponEquipped("hailstorm") and WeaponsContainFiremode("volley") then -- "Field Test" achievement
            CreateProgressTracker("pxp2_1", EHI:GetAchievementProgress("pxp2_1_stats"), 500, false, true)
            stats.pxp2_1_stats = "pxp2_1"
        end
        if EHI:IsAchievementLocked2("pxp2_2") and (HasWeaponEquipped("sko12") or HasWeaponEquipped("x_sko12")) then -- "Heister With A Shotgun" achievement
            CreateProgressTracker("pxp2_2", EHI:GetAchievementProgress("pxp2_2_stats"), 1000, false, true)
            stats.pxp2_2_stats = "pxp2_2"
        end
        if VeryHardOrAbove then
            if EHI:IsAchievementLocked2("tango_achieve_3") and managers.ehi:GetStartedFromBeginning() then -- "The Reckoning" achievement
                local pass, primary_index, secondary_index = CheckWeaponsBlueprint(tweak_data.achievement.complete_heist_achievements.tango_3.killed_by_blueprint.blueprint)
                if pass then
                    if primary_index and secondary_index then
                        EHItango_achieve_3Tracker = class(EHIAchievementProgressTracker)
                        EHItango_achieve_3Tracker._forced_icons = EHI:GetAchievementIcon("tango_achieve_3")
                        function EHItango_achieve_3Tracker:init(panel, params)
                            self._kills =
                            {
                                primary = 0,
                                secondary = 0
                            }
                            self._weapon_id = 0
                            EHItango_achieve_3Tracker.super.init(self, panel, params)
                        end
                        function EHItango_achieve_3Tracker:WeaponSwitched(id)
                            if self._weapon_id == id or self._finished then
                                return
                            end
                            local previous_weapon_id = self._weapon_id
                            self._weapon_id = id
                            local current_selection = id == 0 and "secondary" or "primary"
                            local previous_selection = previous_weapon_id == 0 and "secondary" or "primary"
                            self._kills[previous_selection] = self._progress
                            self._progress = self._kills[current_selection]
                            self._text:set_text(self:Format())
                            self:FitTheText()
                            self:AnimateBG(1)
                        end
                        function EHItango_achieve_3Tracker:SetCompleted(force)
                            EHItango_achieve_3Tracker.super.SetCompleted(self, force)
                            if self._status == "completed" then
                                self._finished = true
                            end
                        end
                        managers.ehi:AddTracker({
                            id = "tango_achieve_3",
                            progress = 0,
                            max = 200,
                            flash_times = 1,
                            remove_after_reaching_target = false,
                            class = "EHItango_achieve_3Tracker"
                        })
                        local primary_weapon = primary.weapon_id
                        local secondary_weapon = secondary.weapon_id
                        HookKillFunctionNoCivilian("tango_achieve_3", primary_weapon)
                        HookKillFunctionNoCivilian("tango_achieve_3", secondary_weapon)
                        local function switch()
                            local player = managers.player:local_player()
                            if not player then
                                return
                            end
                            local weapon = player:inventory():equipped_unit():base():selection_index()
                            if weapon and (weapon == 1 or weapon == 2) then
                                managers.ehi:CallFunction("tango_achieve_3", "WeaponSwitched", weapon - 1)
                            end
                        end
                        managers.player:register_message(Message.OnSwitchWeapon, "EHI_tango_achieve_3", switch)
                    else
                        CreateProgressTracker("tango_achieve_3", 0, 200, false, false)
                        local weapon_required = nil
                        if primary_index then
                            weapon_required = primary.weapon_id
                        else
                            weapon_required = secondary.weapon_id
                        end
                        HookKillFunctionNoCivilian("tango_achieve_3", weapon_required)
                    end
                end
            end
        end
        if OVKOrAbove then
            if EHI:IsAchievementLocked2("pim_1") and HasWeaponEquipped("desertfox") then -- "Nothing Personal" achievement
                local function f()
                    CreateProgressTracker("pim_1", EHI:GetAchievementProgress("pim_1_stats"), 30, false, true)
                end
                ShowTrackerInLoud(f)
                stats.pim_1_stats = "pim_1"
            end
            pxp_1()
            if level == "mad" and EHI:IsAchievementLocked2("pim_3") and HasWeaponEquipped("schakal") then -- "UMP for Me, UMP for You" achievement
                CreateProgressTracker("pim_3", EHI:GetAchievementProgress("pim_3_stats"), 45, false, true)
                stats.pim_3_stats = "pim_3"
            end
            if level == "sand" and EHI:IsAchievementLocked2("sand_11") and HasWeaponTypeEquipped("snp") then -- "This Calls for a Round of Sputniks!" achievement
                managers.ehi:AddTracker({
                    id = "sand_11",
                    flash_times = 1,
                    class = "EHIsand11Tracker"
                })
                EHI:HookWithID(StatisticsManager, "killed", "EHI_sand_11_killed", function (_, data)
                    if data.variant ~= "melee" and data.weapon_unit and data.weapon_unit:base().is_category and data.weapon_unit:base():is_category("snp") then
                        managers.ehi:IncreaseTrackerProgress("sand_11")
                    end
                end)
                EHI:HookWithID(StatisticsManager, "shot_fired", "EHI_sand_11_accuracy", function(self, data)
                    managers.ehi:SetChance("sand_11", self:session_hit_accuracy())
                end)
            end
        end
        if EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) and EHI:IsAchievementLocked2("gage3_2") and HasWeaponEquipped("akm_gold") then -- "The Man With the Golden Gun" achievement
            local function f()
                CreateProgressTracker("gage3_2", EHI:GetAchievementProgress("gage3_2_stats"), 6, false, true)
            end
            ShowTrackerInLoud(f)
            stats.gage3_2_stats = "gage3_2"
        end
    end
    if EHI:GetUnlockableOption("show_achievements_melee") then -- Kill with melee
        if EHI:IsAchievementLocked2("halloween_7") and mask_id == tweak_data.achievement.cant_hear_you_scream.mask then -- "No One Can Hear You Scream" achievement
            if is_stealth then
                CreateProgressTracker("halloween_7", EHI:GetAchievementProgress("halloween_7_stats"), 50, false, true)
                stats.halloween_7_stats = "halloween_7"
                EHI:AddOnAlarmCallback(function()
                    EHI:Unhook("halloween_7_killed")
                    managers.ehi:RemoveTracker("halloween_7")
                    stats.halloween_7_stats = nil
                end)
            end
            if EHI:IsAchievementLocked2("gsu_01") and HasMeleeEquipped("spoon") then -- "For all you legends" achievement
                CreateProgressTracker("gsu_01", EHI:GetAchievementProgress("gsu_stat"), 100, false, true)
                stats.gsu_stat = "gsu_01"
            end
        end
        if EHI:IsAchievementLocked2("gage5_8") and HasMeleeEquipped("dingdong") then -- "Hammertime" achievement
            CreateProgressTracker("gage5_8", EHI:GetAchievementProgress("gage5_8_stats"), 25, false, true)
            stats.gage5_8_stats = "gage5_8"
        end
        if EHI:IsAchievementLocked2("eagle_2") and HasMeleeEquipped("fairbair") then -- "Special Operations Execution" achievement
            if is_stealth then
                CreateProgressTracker("eagle_2", EHI:GetAchievementProgress("eagle_2_stats"), 25, false, true)
                stats.eagle_2_stats = "eagle_2"
                EHI:AddOnAlarmCallback(function()
                    EHI:Unhook("eagle_2_killed")
                    managers.ehi:RemoveTracker("eagle_2")
                    stats.eagle_2_stats = nil
                end)
            end
        end
        if EHI:IsAchievementLocked2("steel_2") then -- "Their Armor Is Thick and Their Shields Broad" achievement
            local melee_required = tweak_data.achievement.enemy_melee_hit_achievements.steel_2.melee_weapons
            local pass = table.index_of(melee_required, melee) ~= -1
            if pass then
                CreateProgressTracker("steel_2", 0, 10, false, true)
                EHI:HookWithID(StatisticsManager, "killed", "EHI_steel_2_killed", function (self, data)
                    if data.variant == "melee" and data.name == "shield" then
                        managers.ehi:IncreaseTrackerProgress("steel_2")
                    end
                end)
            end
        end
        if level == "nightclub" then
            if EHI:IsAchievementLocked2("gage2_3") and HasMeleeEquipped("fists") then -- "The Eighth and Final Rule" achievement
                local function f()
                    CreateProgressTracker("gage2_3", EHI:GetAchievementProgress("gage2_3_stats"), 50, false, true)
                end
                ShowTrackerInLoud(f)
                stats.gage2_3_stats = "gage2_3"
            end
            if EHI:IsAchievementLocked2("gage4_7") and HasMeleeEquipped("shovel") then -- "Every day I'm Shovelin'" achievement
                local function f()
                    CreateProgressTracker("gage4_7", EHI:GetAchievementProgress("gage4_7_stats"), 25, false, true)
                end
                ShowTrackerInLoud(f)
                stats.gage4_7_stats = "gage4_7"
            end
        end
        if (level == "mia_1" or level == "mia_2") and EHI:IsAchievementLocked2("pig_3") and HasMeleeEquipped("baseballbat") then -- "Do You Like Hurting Other People?" achievement
            CreateProgressTracker("pig_3", EHI:GetAchievementProgress("pig_3_stats"), 30, false, true)
            stats.pig_3_stats = "pig_3"
        end
        if OVKOrAbove then
            if EHI:IsAchievementLocked2("gage2_9") and HasMeleeTypeEquipped("knife") then -- "I Ain't Got Time to Bleed" achievement
                local function f()
                    CreateProgressTracker("gage2_9", EHI:GetAchievementProgress("gage2_9_stats"), 15, false, true)
                end
                ShowTrackerInLoud(f)
                stats.gage2_9_stats = "gage2_9"
            end
            if EHI:IsAchievementLocked2("sawp_1") then -- "Buzzbomb" achievement
                local achievement_data = tweak_data.achievement.enemy_melee_hit_achievements.sawp_1
                local melee_pass = table.index_of(achievement_data.melee_weapons, melee) ~= -1
                local player_style_pass = HasPlayerStyleEquipped(achievement_data.player_style.style)
                local variation_pass = HasSuitVariationEquipped(achievement_data.player_style.variation)
                if melee_pass and player_style_pass and variation_pass then
                    CreateProgressTracker("sawp_1", EHI:GetAchievementProgress("sawp_stat"), 200, false, true)
                    stats.sawp_stat = "sawp_1"
                end
            end
            pxp_1()
            if (level == "rvd1" or level == "rvd2") and EHI:IsAchievementLocked2("rvd_12") and HasMeleeEquipped("clean") then -- "Close Shave" achievement
                CreateProgressTracker("rvd_12", EHI:GetAchievementProgress("rvd_12_stats"), 92, false, true)
                stats.rvd_12_stats = "rvd_12"
            end
            if level == "bph" and EHI:IsAchievementLocked2("bph_9") and HasMeleeEquipped("toothbrush") then -- "Prison Rules, Bitch!" achievement
                CreateProgressTracker("bph_9", EHI:GetAchievementProgress("bph_9_stat"), 13, false, true)
                stats.bph_9_stat = "bph_9"
            end
        end
    end
    if EHI:GetUnlockableOption("show_achievements_grenade") then -- Kill with grenades
        if EHI:IsAchievementLocked2("gage_9") then -- "Fire in the Hole!" achievement
            local eligible_grenades = tweak_data.achievement.fire_in_the_hole.grenade
            for _, eligible_grenade in ipairs(eligible_grenades) do
                if grenade == eligible_grenade then
                    local progress = EHI:GetAchievementProgress("gage_9_stats")
                    EHI:HookWithID(AchievmentManager, "award_progress", "EHI_gage_9_achievement", function(am, stat, value)
                        if stat == "gage_9_stats" then
                            progress = progress + (value or 1)
                            if progress >= 100 then
                                EHI:Unhook("gage_9_achievement")
                                return
                            end
                            ShowPopup("gage_9", progress, 100)
                        end
                    end)
                    ShowPopup("gage_9", progress, 100)
                    break
                end
            end
        end
        if EHI:IsAchievementLocked2("dec21_02") and HasNonExplosiveGrenadeEquipped() then -- "Gift Giver" achievement
            CreateProgressTracker("dec21_02", EHI:GetAchievementProgress("dec21_02_stat"), 75, false, true)
            stats.dec21_02_stat = "dec21_02"
        end
        if level == "dark" and EHI:IsAchievementLocked2("pim_2") and HasGrenadeEquipped("wpn_prj_target") then -- Crouched and Hidden, Flying Dagger
            local progress = EHI:GetAchievementProgress("pim_2_stats")
            CreateProgressTracker("pim_2", progress, 8, false, false, true)
            EHI:Hook(AchievmentManager, "add_heist_success_award_progress", function(am, id)
                if id == "pim_2_stats" then
                    progress = progress + 1
                    managers.ehi:SetTrackerProgress("pim_2", progress)
                end
            end)
            EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                if success and progress < 8 then
                    managers.hud:custom_ingame_popup_text("SAVED", "Progress Saved: " .. tostring(progress) .. "/8", "C_Jimmy_H_MurkyStation_CrouchedandHidden")
                elseif not success then
                    managers.hud:custom_ingame_popup_text("LOST", "Progress Lost: " .. tostring(progress) .. "/8", "C_Jimmy_H_MurkyStation_CrouchedandHidden")
                end
            end)
        end
        if OVKOrAbove then
            pxp_1()
            if EHI:IsAchievementLocked2("pxp2_3") and HasGrenadeEquipped("poison_gas_grenade") then -- "Snake Charmer" achievement
                CreateProgressTracker("pxp2_3", EHI:GetAchievementProgress("pxp2_3_stats"), 100, false)
                stats.pxp2_3_stats = "pxp2_3"
            end
        end
    end
    if EHI:GetUnlockableOption("show_achievements_other") then
        if EHI:IsAchievementLocked2("halloween_4") and mask_id == tweak_data.achievement.witch_doctor.mask then -- "Witch Doctor" achievement
            CreateProgressTracker("halloween_4", EHI:GetAchievementProgress("halloween_4_stats"), 50, false, true)
            stats.halloween_4_stats = "halloween_4"
        end
        if EHI:IsAchievementLocked2("halloween_5") and mask_id == tweak_data.achievement.its_alive_its_alive.mask then -- "It's Alive! IT'S ALIVE!" achievement
            local function f()
                CreateProgressTracker("halloween_5", EHI:GetAchievementProgress("halloween_5_stats"), 25, false, true)
            end
            ShowTrackerInLoud(f)
            stats.halloween_5_stats = "halloween_5"
        end
        if EHI:IsAchievementLocked2("armored_8") and mask_id == tweak_data.achievement.relation_with_bulldozer.mask then -- "I Did Not Have Sexual Relations With That Bulldozer" achievement
            local function f()
                CreateProgressTracker("armored_8", EHI:GetAchievementProgress("armored_8_stat"), 7, false, true)
            end
            ShowTrackerInLoud(f)
            stats.armored_8_stat = "armored_8"
        end
        if EHI:IsAchievementLocked2("armored_10") and mask_id == tweak_data.achievement.no_we_cant.mask then -- "Affordable Healthcare" achievement
            local progress = EHI:GetAchievementProgress("armored_10_stat")
            ShowTrackerInLoud(function()
                ShowPopup("armored_10", progress, 61)
            end)
            EHI:HookWithID(AchievmentManager, "award_progress", "EHI_armored_10_award_progress", function(am, stat, value)
                if stat == "armored_10_stat" and progress < 61 then
                    progress = progress + (value or 1)
                    ShowPopup("armored_10", progress, 61)
                end
            end)
        end
        if EHI:IsAchievementLocked2("gmod_1") then -- "Praying Mantis" achievement
            local progress = EHI:GetAchievementProgress("gmod_1_stats")
            EHI:HookWithID(AchievmentManager, "award_progress", "EHI_gmod_1_achievement", function(am, stat, value)
                if stat == "gmod_1_stats" then
                    progress = progress + value
                    if progress < 5 then
                        ShowPopup("gmod_1", progress, 5)
                    end
                end
            end)
        end
        if EHI:IsAchievementLocked2("gmod_2") then -- "Bullseye" achievement
            local progress = EHI:GetAchievementProgress("gmod_2_stats")
            EHI:HookWithID(AchievmentManager, "award_progress", "EHI_gmod_2_achievement", function(am, stat, value)
                if stat == "gmod_2_stats" then
                    progress = progress + value
                    if progress < 10 then
                        ShowPopup("gmod_2", progress, 10)
                    end
                end
            end)
        end
        if EHI:IsAchievementLocked2("gmod_3") then -- "My Spider Sense is Tingling" achievement
            local progress = EHI:GetAchievementProgress("gmod_3_stats")
            EHI:HookWithID(AchievmentManager, "award_progress", "EHI_gmod_3_achievement", function(am, stat, value)
                if stat == "gmod_3_stats" then
                    progress = progress + value
                    if progress < 15 then
                        ShowPopup("gmod_3", progress, 15)
                    end
                end
            end)
        end
        if EHI:IsAchievementLocked2("gmod_4") then -- "Eagle Eyes" achievement
            local progress = EHI:GetAchievementProgress("gmod_4_stats")
            EHI:HookWithID(AchievmentManager, "award_progress", "EHI_gmod_4_achievement", function(am, stat, value)
                if stat == "gmod_4_stats" then
                    progress = progress + value
                    if progress < 20 then
                        ShowPopup("gmod_4", progress, 20)
                    end
                end
            end)
        end
        if EHI:IsAchievementLocked2("gmod_5") then -- "Like A Boy Killing Snakes" achievement
            local progress = EHI:GetAchievementProgress("gmod_5_stats")
            EHI:HookWithID(AchievmentManager, "award_progress", "EHI_gmod_5_achievement", function(am, stat, value)
                if stat == "gmod_5_stats" then
                    progress = progress + value
                    if progress < 25 then
                        ShowPopup("gmod_5", progress, 25)
                    end
                end
            end)
        end
        if EHI:IsAchievementLocked2("gmod_6") then -- "There and Back Again" achievement
            EHI:HookWithID(GageAssignmentManager, "_give_rewards", "EHI_gmod_6_achievement", function(gam, assignment, ...)
                local progress = 0
                for i, dvalue in pairs(gam._global.completed_assignments) do
                    if Application:digest_value(dvalue, false) >= tweak_data.achievement.gonna_find_them_all then
                        progress = progress + 1
                    end
                end
                if progress < 5 then
                    ShowPopup("gmod_6", progress, 5)
                end
            end)
        end
        if EHI:IsAchievementLocked("ovk_3") and HasWeaponEquipped("m134") and (level == "chill" or level == "safehouse") then -- "Oh, That's How You Do It" achievement
            -- Only tracked in Safehouse to prevent tracker spam in heists
            EHIovk3Tracker = class(EHIAchievementUnlockTracker)
            EHIovk3Tracker._forced_icons = EHI:GetAchievementIcon("ovk_3")
            function EHIovk3Tracker:ResetTime()
                self:SetTime(25)
            end
            function EHIovk3Tracker:ResetFadeTime()
                self._fade_time = 5
                self:SetTextColor(Color.white)
                self.update = self.super.update
            end
            EHI:HookWithID(RaycastWeaponBase, "start_shooting", "EHI_ovk_3_start_shooting", function(self, ...)
                if self._shooting and self:get_name_id() == "m134" then
                    if managers.ehi:TrackerExists("ovk_3") then
                        managers.ehi:CallFunction("ovk_3", "ResetTime")
                        managers.ehi:CallFunction("ovk_3", "ResetFadeTime")
                    else
                        managers.ehi:AddTracker({
                            id = "ovk_3",
                            time = 25,
                            status_is_overridable = false,
                            class = "EHIovk3Tracker"
                        })
                    end
                end
            end)
            EHI:HookWithID(RaycastWeaponBase, "stop_shooting", "EHI_ovk_3_stop_shooting", function(self, ...)
                managers.ehi:SetAchievementFailed("ovk_3")
            end)
            EHI:HookWithID(AchievmentManager, "award", "EHI_ovk_3_award", function(self, id)
                if id == "ovk_3" then
                    EHI:Unhook("ovk_3_start_shooting")
                    EHI:Unhook("ovk_3_stop_shooting")
                    EHI:Unhook("ovk_3_award")
                end
            end)
        end
        if EHI:IsAchievementLocked2("cac_3") then -- "Denied" achievement
            local listener_key = "EHI_cac_3_listener"
            local progress = EHI:GetAchievementProgress("cac_3_stats")
            local function on_flash_grenade_destroyed(attacker_unit)
                local local_player = managers.player:player_unit()
                if local_player and attacker_unit == local_player then
                    progress = progress + 1
                    if progress < 30 then
                        ShowPopup("cac_3", progress, 30)
                    else
                        managers.player:unregister_message("flash_grenade_destroyed", listener_key)
                    end
                end
            end
            managers.player:register_message("flash_grenade_destroyed", listener_key, on_flash_grenade_destroyed)
            ShowTrackerInLoud(function() -- Show progress when alarm went off
                ShowPopup("cac_3", progress, 30)
            end)
        end
        if EHI:IsAchievementLocked2("cac_34") then -- "Lieutenant Colonel" achievement
            local listener_key = "EHI_cac_34_listener_key"
            local progress = EHI:GetAchievementProgress("cac_34_stats")
            local function on_cop_converted(converted_unit, converting_unit)
                if not alive(converting_unit) then
                    return
                end
                progress = progress + 1
                if progress >= 300 then
                    managers.player:unregister_message("cop_converted", listener_key)
                    return
                end
                ShowPopup("cac_34", progress, 300)
            end
            managers.player:register_message("cop_converted", listener_key, on_cop_converted)
            ShowPopup("cac_34", progress, 300)
        end
        if level == "branchbank" or level == "branchbank_gold" or level == "branchbank_cash" or level == "branchbank_deposit" or level == "jewelry_store" then
            if EHI:IsAchievementLocked2("eng_1") then -- "The only one that is true" achievement
                local progress = EHI:GetAchievementProgress("eng_1_stats") + 1
                EHI:HookWithID(AchievmentManager, "award_progress", "EHI_eng_1_award_progress", function(am, stat, value)
                    if stat == "eng_1_stats" and progress < 5 then
                        ShowPopup("eng_1", progress, 5)
                    end
                end)
            end
        end
        if level == "kosugi" or level == "red2" then
            if EHI:IsAchievementLocked2("eng_2") then -- "The one that had many names" achievement
                local progress = EHI:GetAchievementProgress("eng_2_stats") + 1
                EHI:HookWithID(AchievmentManager, "award_progress", "EHI_eng_2_award_progress", function(am, stat, value)
                    if stat == "eng_2_stats" and progress < 5 then
                        ShowPopup("eng_2", progress, 5)
                    end
                end)
            end
        end
        if level == "roberts" or level == "four_stores" then
            if EHI:IsAchievementLocked2("eng_3") then -- "The one that survived" achievement
                local progress = EHI:GetAchievementProgress("eng_3_stats") + 1
                EHI:HookWithID(AchievmentManager, "award_progress", "EHI_eng_3_award_progress", function(am, stat, value)
                    if stat == "eng_3_stats" and progress < 5 then
                        ShowPopup("eng_3", progress, 5)
                    end
                end)
            end
        end
        if level == "family" or level == "hox_1" then
            if EHI:IsAchievementLocked2("eng_4") then -- "The one who declared himself the hero" achievement
                local progress = EHI:GetAchievementProgress("eng_4_stats") + 1
                EHI:HookWithID(AchievmentManager, "award_progress", "EHI_eng_4_award_progress", function(am, stat, value)
                    if stat == "eng_4_stats" and progress < 5 then
                        ShowPopup("eng_4", progress, 5)
                    end
                end)
            end
        end
        if EHI:IsAchievementLocked2("xm20_1") and (level == "mex" or level == "bex" or level == "pex" or level == "fex") then
            EHI:PreHookWithID(MissionManager, "on_set_saved_job_value", "EHI_xm20_1_achievement", function(mm, key, value)
                if (key == "present_mex" or key == "present_bex" or key == "present_pex" or key == "present_bex") and value == 1 then
                    local progress = 0
                    local to_secure = tweak_data.achievement.collection_achievements.xm20_1.collection
                    for _, item in pairs(to_secure) do
                        if Global.mission_manager.saved_job_values[item] then
                            progress = progress + 1
                        end
                    end
                    if progress == 4 then
                        return
                    end
                    ShowPopup("xm20_1", progress, 4)
                end
            end)
        end
        if EHI:IsAchievementLocked2("pent_11") and (level == "chas" or level == "sand" or level == "chca" or level == "pent") then
            EHI:PreHookWithID(MissionManager, "on_set_saved_job_value", "EHI_pent_11_achievement", function(mm, key, value)
                if (key == "tea_chas" or key == "tea_sand" or key == "tea_chca" or key == "tea_pent") and value == 1 then
                    local progress = 0
                    local to_secure = tweak_data.achievement.collection_achievements.pent_11.collection
                    for _, item in pairs(to_secure) do
                        if Global.mission_manager.saved_job_values[item] then
                            progress = progress + 1
                        end
                    end
                    if progress == 4 then
                        return
                    end
                    ShowPopup("pent_11", progress, 4)
                end
            end)
        end
        if VeryHardOrAbove then
            if level == "help" and EHI:IsAchievementLocked2("tawp_1") and mask_id == tweak_data.achievement.complete_heist_achievements.tawp_1.mask then -- "Cloaker Charmer" achievement
                CreateProgressTracker("tawp_1", 0, 1, false, false)
                EHI:HookWithID(StatisticsManager, "killed", "EHI_tawp_1_killed", function (self, data)
                    if data.name == "spooc" then
                        managers.ehi:IncreaseTrackerProgress("tawp_1")
                    end
                end)
            end
        end
        if OVKOrAbove then
            if (level == "arm_cro" or level == "arm_und" or level == "arm_hcm" or level == "arm_par" or level == "arm_fac") and EHI:IsAchievementLocked2("armored_4") and mask_id == tweak_data.achievement.complete_heist_achievements.i_take_scores.mask and managers.ehi:GetStartedFromBeginning() then -- I Do What I Do Best, I Take Scores
                local progress = EHI:GetAchievementProgress("armored_4_stat")
                EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                    if success and progress < 15 and managers.job:on_last_stage() then
                        ShowPopup("armored_4", progress + 1, 15)
                    end
                end)
            end
            if EHI:IsAchievementLocked2("halloween_10") and managers.job:current_contact_id() == "vlad" and mask_id == tweak_data.achievement.complete_heist_achievements.in_soviet_russia.mask and managers.ehi:GetStartedFromBeginning() then -- From Russia With Love
                local progress = EHI:GetAchievementProgress("halloween_10_stats")
                EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                    if success and progress < 25 and managers.job:on_last_stage() then
                        ShowPopup("halloween_10", progress + 1, 25)
                    end
                end)
            end
        end
    end
    --[[if EHI:IsAchievementLocked2("gage4_3") then -- "Swing Dancing" achievement
        CreateProgressTracker("gage4_3", 0, 50, false, true)
        EHI:HookWithID(StatisticsManager, "killed", "EHI_gage4_3_killed", function (self, data)
            if data.variant == "melee" then
                if not CopDamage.is_civilian(data.name) then
                    managers.ehi:IncreaseTrackerProgress("gage4_3")
                end
            else
                managers.ehi:SetAchievementFailed("gage4_3")
                EHI:Unhook("gage4_3_killed")
            end
        end)
    end]]
    if next(stats) then
        EHI:HookWithID(AchievmentManager, "award_progress", "EHI_IngameWaitingForPlayers_AwardProgress", function(am, stat, value)
            if stats[stat] then
                managers.ehi:IncreaseTrackerProgress(stats[stat], value)
            end
        end)
    end
end