local EHI = EHI
if EHI:CheckLoadHook("HUDManagerPD2") then
    return
end

local level_id = Global.game_settings.level_id

local original =
{
    _setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2,
    sync_set_assault_mode = HUDManager.sync_set_assault_mode,
    destroy = HUDManager.destroy,
    mark_cheater = HUDManager.mark_cheater,
    set_disabled = HUDManager.set_disabled,
    set_enabled = HUDManager.set_enabled
}

local EHIWaypoints = EHI:GetOption("show_waypoints")
local server = EHI:IsHost()

function HUDManager:_setup_player_info_hud_pd2(...)
    original._setup_player_info_hud_pd2(self, ...)
    local hud = self:script(PlayerBase.PLAYER_INFO_HUD_PD2)
    self.ehi = managers.ehi
    self.ehi_waypoint = managers.ehi_waypoint
    self.ehi_waypoint:SetPlayerHUD(self)
    if server or level_id == "hvh" then
        self:add_updator("EHI_Update", callback(self.ehi, self.ehi, "update"))
        if EHIWaypoints then
            self:add_updator("EHI_Waypoint_Update", callback(self.ehi_waypoint, self.ehi_waypoint, "update"))
        end
    end
    if _G.IS_VR then
        self.ehi:SetPanel(hud.panel)
    end
    if EHI:GetOption("show_buffs") then
        local buff = managers.ehi_buff
        self:add_updator("EHI_Buff_Update", callback(buff, buff, "update"))
        buff:init_finalize(hud)
    end
    local level_tweak_data = tweak_data.levels[level_id]
    if (level_tweak_data and level_tweak_data.is_safehouse) or level_id == "safehouse" then
        return
    end
    if EHI:GetOption("show_captain_damage_reduction") then
        local function f(mode)
            if mode == "phalanx" then
                self.ehi:AddTracker({
                    id = "PhalanxDamageReduction",
                    icons = { "buff_shield" },
                    class = EHI.Trackers.Chance,
                })
            else
                self.ehi:RemoveTracker("PhalanxDamageReduction")
            end
        end
        EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, f)
    end
    if EHI:GetOption("show_enemy_count_tracker") then
        self.ehi:AddTracker({
            id = "EnemyCount",
            flash = false,
            class = "EHIEnemyCountTracker"
        })
    end
    if level_tweak_data.ghost_bonus or level_tweak_data.ghost_required or level_tweak_data.ghost_required_visual or level_id == "welcome_to_the_jungle_2" then
        -- In case the heist will require stealth completion but does not have XP bonus
        -- Big Oil Day 2 is exception to this rule because guards have pagers
        if EHI:GetOption("show_pager_tracker") then
            local base = tweak_data.player.alarm_pager.bluff_success_chance_w_skill
            if server then
                local function remove_chance()
                    self.ehi:RemoveTracker("pagers_chance")
                end
                for _, value in pairs(base) do
                    if value > 0 and value < 1 then
                        -- Random Chance
                        self.ehi:AddTracker({
                            id = "pagers_chance",
                            chance = EHI:RoundChanceNumber(base[1] or 0),
                            icons = { EHI.Icons.Pager },
                            class = EHI.Trackers.Chance
                        })
                        EHI:AddOnAlarmCallback(remove_chance)
                        return
                    end
                end
            end
            local function remove()
                self.ehi:RemoveTracker("pagers")
            end
            local max = 0
            for _, value in pairs(base) do
                if value > 0 then
                    max = max + 1
                end
            end
            self.ehi:AddTracker({
                id = "pagers",
                max = max,
                icons = { EHI.Icons.Pager },
                set_color_bad_when_reached = true,
                class = EHI.Trackers.Progress
            })
            if max == 0 then
                self.ehi:CallFunction("pagers", "SetBad")
            end
            EHI:AddOnAlarmCallback(remove)
        end
        if EHI:GetOption("show_bodybags_counter") then
            self.ehi:AddTracker({
                id = "BodybagsCounter",
                icons = { "equipment_body_bag" },
                class = EHI.Trackers.Counter
            })
            local function remove()
                self.ehi:RemoveTracker("BodybagsCounter")
            end
            EHI:AddOnAlarmCallback(remove)
        end
    end
    if EHI:GetOption("show_gained_xp") and EHI:GetOption("xp_panel") == 2 and Global.game_settings.gamemode ~= "crime_spree" and not EHI:IsOneXPElementHeist(level_id) then
        self.ehi:AddTracker({
            id = "XPTotal",
            class = "EHITotalXPTracker"
        })
    end
end

function HUDManager:sync_set_assault_mode(mode, ...)
    original.sync_set_assault_mode(self, mode, ...)
    EHI:CallCallback(EHI.CallbackMessage.AssaultModeChanged, mode)
end

if EHI:GetBuffAndOption("stamina") then
    original.set_stamina_value = HUDManager.set_stamina_value
    function HUDManager:set_stamina_value(value, ...)
        original.set_stamina_value(self, value, ...)
        managers.ehi_buff:AddGauge("Stamina", value)
    end
    original.set_max_stamina = HUDManager.set_max_stamina
    function HUDManager:set_max_stamina(value, ...)
        original.set_max_stamina(self, value, ...)
        managers.ehi_buff:CallFunction("Stamina", "SetMaxStamina", value)
    end
end

function HUDManager:mark_cheater(...)
    original.mark_cheater(self, ...)
    if managers.experience.RecalculateSkillXPMultiplier then
        managers.experience:RecalculateSkillXPMultiplier()
    end
end

function HUDManager:set_disabled(...)
    original.set_disabled(self, ...)
    self.ehi:HidePanel()
end

function HUDManager:set_enabled(...)
    original.set_enabled(self, ...)
    self.ehi:ShowPanel()
end

function HUDManager:destroy(...)
    self.ehi:destroy()
    self.ehi_waypoint:destroy()
    original.destroy(self, ...)
end

if EHI:IsClient() and level_id ~= "hvh" then
    original.feed_heist_time = HUDManager.feed_heist_time
    if EHIWaypoints then
        function HUDManager:feed_heist_time(time, ...)
            original.feed_heist_time(self, time, ...)
            self.ehi:update_client(time)
            self.ehi_waypoint:update_client(time)
        end
    else
        function HUDManager:feed_heist_time(time, ...)
            original.feed_heist_time(self, time, ...)
            self.ehi:update_client(time)
        end
    end
end

if EHI:CombineAssaultDelayAndAssaultTime() then
    dofile(EHI.LuaPath .. "trackers/EHIAssaultTracker.lua")
    local SyncFunction = EHI:IsHost() and "SyncAnticipationColor" or "SyncAnticipation"
    local anticipation_delay = 30 -- Get it from tweak_data
    local function VerifyHostageHesitationDelay()
    end
    local function set_assault_delay(self, data)
        self.ehi:CallFunction("Assault", "SetHostages", data.nr_hostages > 0)
    end
    local is_skirmish = tweak_data.levels:get_group_ai_state() == "skirmish"
    original.sync_start_anticipation_music = HUDManager.sync_start_anticipation_music
    function HUDManager:sync_start_anticipation_music(...)
        original.sync_start_anticipation_music(self, ...)
        self.ehi:CallFunction("Assault", SyncFunction, anticipation_delay)
        EHI:Unhook("Assault_set_control_info")
    end
    original.sync_start_assault = HUDManager.sync_start_assault
    function HUDManager:sync_start_assault(...)
        original.sync_start_assault(self, ...)
        EHI:Unhook("Assault_set_control_info")
        if EHI._cache.EndlessAssault then
            return
        end
        if self.ehi:TrackerExists("Assault") then
            self.ehi:CallFunction("Assault", "AssaultStart", EHI._cache.diff or 0)
        elseif (EHI._cache.diff and EHI._cache.diff > 0) or is_skirmish then
            self.ehi:AddTracker({
                id = "Assault",
                assault = true,
                diff = EHI._cache.diff or 0,
                class = "EHIAssaultTracker"
            })
        end
    end
    original.sync_end_assault = HUDManager.sync_end_assault
    function HUDManager:sync_end_assault(...)
        original.sync_end_assault(self, ...)
        if is_skirmish then
            self.ehi:RemoveTracker("Assault")
        elseif self.ehi:TrackerExists("Assault") then
            self.ehi:CallFunction("Assault", "AssaultEnd", EHI._cache.diff or 0)
        elseif EHI._cache.diff and EHI._cache.diff > 0 then
            self.ehi:AddTracker({
                id = "Assault",
                diff = EHI._cache.diff,
                class = "EHIAssaultTracker"
            })
        end
        EHI._cache.EndlessAssault = nil
        EHI:HookWithID(self, "set_control_info", "EHI_Assault_set_control_info", set_assault_delay)
    end
    EHI:HookWithID(HUDManager, "set_control_info", "EHI_Assault_set_control_info", set_assault_delay)
    VerifyHostageHesitationDelay()
else
    if EHI:AssaultDelayTrackerIsEnabled() then
        dofile(EHI.LuaPath .. "trackers/EHIAssaultDelayTracker.lua")
        local SyncFunction = EHI:IsHost() and "SyncAnticipationColor" or "SyncAnticipation"
        local anticipation_delay = 30 -- Get it from tweak_data
        local function VerifyHostageHesitationDelay()
        end
        local function set_assault_delay(self, data)
            self.ehi:CallFunction("AssaultDelay", "SetHostages", data.nr_hostages > 0)
        end
        original.sync_start_anticipation_music = HUDManager.sync_start_anticipation_music
        function HUDManager:sync_start_anticipation_music(...)
            original.sync_start_anticipation_music(self, ...)
            self.ehi:CallFunction("AssaultDelay", SyncFunction, anticipation_delay)
            EHI:Unhook("AssaultDelay_set_control_info")
        end
        original.sync_start_assault = HUDManager.sync_start_assault
        function HUDManager:sync_start_assault(...)
            original.sync_start_assault(self, ...)
            self.ehi:RemoveTracker("AssaultDelay")
            EHI:Unhook("AssaultDelay_set_control_info")
        end
        original.sync_end_assault = HUDManager.sync_end_assault
        function HUDManager:sync_end_assault(...)
            original.sync_end_assault(self, ...)
            if EHI._cache.diff and EHI._cache.diff > 0 then
                self.ehi:AddTracker({
                    id = "AssaultDelay",
                    compute_time = true,
                    diff = EHI._cache.diff,
                    class = EHI.Trackers.AssaultDelay
                })
                EHI:HookWithID(HUDManager, "set_control_info", "EHI_AssaultDelay_set_control_info", set_assault_delay)
            end
        end
        EHI:HookWithID(HUDManager, "set_control_info", "EHI_AssaultDelay_set_control_info", set_assault_delay)
        VerifyHostageHesitationDelay()
    end
    if EHI:GetOption("show_assault_time_tracker") then
        dofile(EHI.LuaPath .. "trackers/EHIAssaultTimeTracker.lua")
        local start_original = HUDManager.sync_start_assault
        local is_skirmish = tweak_data.levels:get_group_ai_state() == "skirmish"
        function HUDManager:sync_start_assault(...)
            start_original(self, ...)
            if (EHI._cache.diff and EHI._cache.diff > 0 and not EHI._cache.EndlessAssault) or is_skirmish then
                self.ehi:AddTracker({
                    id = "AssaultTime",
                    diff = EHI._cache.diff or 0,
                    class = "EHIAssaultTimeTracker"
                })
            end
        end
        local end_original = HUDManager.sync_end_assault
        function HUDManager:sync_end_assault(...)
            end_original(self, ...)
            self.ehi:RemoveTracker("AssaultTime")
            EHI._cache.EndlessAssault = nil
        end
    end
end

function HUDManager:ShowAchievementStartedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", EHI._cache[id], "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

function HUDManager:ShowAchievementFailedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", EHI._cache[id], "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

function HUDManager:ShowTrophyStartedPopup(id)
    self:custom_ingame_popup_text("TROPHY STARTED!", managers.localization:to_upper_text(id), "milestone_trophy")
end

function HUDManager:ShowTrophyFailedPopup(id)
    self:custom_ingame_popup_text("TROPHY FAILED!", managers.localization:to_upper_text(id), "milestone_trophy")
end

function HUDManager:ShowDailyStartedPopup(id)
    local icon = tweak_data.ehi.icons[id] and id or "milestone_trophy"
    self:custom_ingame_popup_text("DAILY SIDE JOB STARTED!", managers.localization:to_upper_text(id), icon)
end

function HUDManager:ShowDailyFailedPopup(id)
    local icon = tweak_data.ehi.icons[id] and id or "milestone_trophy"
    self:custom_ingame_popup_text("DAILY SIDE JOB FAILED!", managers.localization:to_upper_text(id), icon)
end

function HUDManager:Debug(id)
    local dt = 0
    if self._ehi_debug_time then
        local new_time = TimerManager:game():time()
        dt = new_time - self._ehi_debug_time
        self._ehi_debug_time = new_time
    else
        self._ehi_debug_time = TimerManager:game():time()
    end
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(id) .. "; dt: " .. dt, Color.white)
end

function HUDManager:DebugElement(id, element)
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(id) .. "; Element: " .. tostring(element), Color.white)
end

function HUDManager:DebugBaseElement(id, instance_index, continent_index, element)
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(EHI:GetBaseUnitID(id, instance_index, continent_index or 100000)) .. "; Element: " .. tostring(element), Color.white)
end

function HUDManager:DebugBaseElement2(base_id, instance_index, continent_index, element, instance_name)
    managers.chat:_receive_message(1, "[EHI]", "Base ID: " .. tostring(EHI:GetBaseUnitID(base_id, instance_index, continent_index or 100000)) .. "; ID: " .. tostring(base_id) .. "; Element: " .. tostring(element) .. "; Instance: " .. tostring(instance_name), Color.white)
end

local animation = { start_t = {}, end_t = {} }
function HUDManager:DebugAnimation(id, type)
    if type == "start" then
        animation.start_t[id] = TimerManager:game():time()
    else -- "end"
        animation.end_t[id] = TimerManager:game():time()
    end
    if animation.start_t[id] and animation.end_t[id] then
        local diff = animation.end_t[id] - animation.start_t[id]
        managers.chat:_receive_message(1, "[EHI]", "Animation: " .. tostring(id) .. "; Time: " .. tostring(diff), Color.white)
        animation.end_t[id] = nil
        animation.start_t[id] = nil
    end
end

local last_id = ""
function HUDManager:DebugAnimation2(id, type)
    if id then
        last_id = id
    end
    self:DebugAnimation(last_id, type)
    if type == "end" then
        last_id = ""
    end
end