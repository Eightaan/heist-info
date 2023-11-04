local EHI = EHI
if EHI:CheckLoadHook("HUDManagerPD2") then
    return
end

---@type string
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

function HUDManager:_setup_player_info_hud_pd2(...)
    original._setup_player_info_hud_pd2(self, ...)
    local server = EHI:IsHost()
    local hud = self:script(PlayerBase.PLAYER_INFO_HUD_PD2)
    self.ehi = managers.ehi_tracker
    managers.ehi_waypoint:SetPlayerHUD(self)
    self.ehi_manager = managers.ehi_manager
    if server or level_id == "hvh" then
        if EHIWaypoints then
            self:add_updator("EHIManager_Update", callback(self.ehi_manager, self.ehi_manager, "update"))
        else
            self:add_updator("EHI_Update", callback(self.ehi, self.ehi, "update"))
        end
    end
    if EHI:IsVR() then
        self.ehi:SetPanel(hud.panel)
    end
    if EHI:GetOption("show_buffs") then
        local buff = managers.ehi_buff
        self:add_updator("EHI_Buff_Update", callback(buff, buff, "update"))
        buff:init_finalize(hud)
    end
    if tweak_data.levels:IsLevelSafehouse(level_id) then
        return
    end
    if EHI:GetOption("show_captain_damage_reduction") then
        EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
            if mode == "phalanx" then
                self.ehi:AddTracker({
                    id = "PhalanxDamageReduction",
                    icons = { "buff_shield" },
                    class = EHI.Trackers.Chance,
                })
            else
                self.ehi:RemoveTracker("PhalanxDamageReduction")
            end
        end)
    end
    if EHI:GetOption("show_enemy_count_tracker") then
        self.ehi:AddTracker({
            id = "EnemyCount",
            flash_bg = false,
            class = "EHIEnemyCountTracker"
        })
    end
    if tweak_data.levels:IsStealthAvailable(level_id) then
        if EHI:GetOption("show_pager_tracker") then
            local base = tweak_data.player.alarm_pager.bluff_success_chance_w_skill
            if server then
                for _, value in pairs(base) do
                    if value > 0 and value < 1 then
                        -- Random Chance
                        self.ehi:AddTracker({
                            id = "PagersChance",
                            chance = EHI:RoundChanceNumber(base[1] or 0),
                            icons = { EHI.Icons.Pager },
                            class = EHI.Trackers.Chance
                        })
                        EHI:AddOnAlarmCallback(function()
                            self.ehi:RemoveTracker("PagersChance")
                        end)
                        return
                    end
                end
            end
            local max = 0
            for _, value in pairs(base) do
                if value > 0 then
                    max = max + 1
                end
            end
            self.ehi:AddTracker({
                id = "Pagers",
                max = max,
                icons = { EHI.Icons.Pager },
                set_color_bad_when_reached = true,
                class = EHI.Trackers.Progress
            })
            if max == 0 then
                self.ehi:CallFunction("Pagers", "SetBad")
            end
            EHI:AddOnAlarmCallback(function()
                self.ehi:RemoveTracker("Pagers")
            end)
        end
        if EHI:GetOption("show_bodybags_counter") then
            self.ehi:AddTracker({
                id = "BodybagsCounter",
                icons = { "equipment_body_bag" },
                class = EHI.Trackers.Counter
            })
            EHI:AddOnAlarmCallback(function()
                self.ehi:RemoveTracker("BodybagsCounter")
            end)
        end
    end
    if EHI:IsXPTrackerVisible() and EHI:GetOption("xp_panel") == 2 and not EHI:IsOneXPElementHeist(level_id) then
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
    self.ehi_manager:destroy()
    original.destroy(self, ...)
end

if EHI:IsClient() and level_id ~= "hvh" then
    original.feed_heist_time = HUDManager.feed_heist_time
    if EHIWaypoints then
        function HUDManager:feed_heist_time(time, ...)
            original.feed_heist_time(self, time, ...)
            self.ehi_manager:update_client(time)
        end
    else
        function HUDManager:feed_heist_time(time, ...)
            original.feed_heist_time(self, time, ...)
            self.ehi:update_client(time)
        end
    end
end

if EHI:CombineAssaultDelayAndAssaultTime() then
    local SyncFunction = EHI:IsHost() and "SyncAnticipationColor" or "SyncAnticipation"
    local anticipation_delay = 30 -- Get it from tweak_data
    local function VerifyHostageHesitationDelay()
    end
    local function set_assault_delay(self, data)
        self.ehi:CallFunction("Assault", "SetHostages", data.nr_hostages > 0)
    end
    local is_skirmish = tweak_data.levels:IsLevelSkirmish(level_id)
    local EndlessAssault = nil
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
        if EndlessAssault or self._ehi_manual_block then
            return
        elseif self.ehi:TrackerExists("Assault") then
            self.ehi:CallFunction("Assault", "AssaultStart", EHI._cache.diff or 0)
        elseif (EHI._cache.diff and EHI._cache.diff > 0) or is_skirmish then
            self.ehi:AddTracker({
                id = "Assault",
                assault = true,
                diff = EHI._cache.diff or 0,
                class = EHI.Trackers.Assault.Assault
            }, 0)
        end
    end
    original.sync_end_assault = HUDManager.sync_end_assault
    function HUDManager:sync_end_assault(...)
        original.sync_end_assault(self, ...)
        if self._ehi_manual_block then
            return
        elseif is_skirmish or EndlessAssault then
            self.ehi:RemoveTracker("Assault")
        elseif self.ehi:TrackerExists("Assault") then
            self.ehi:CallFunction("Assault", "AssaultEnd", EHI._cache.diff or 0)
        elseif EHI._cache.diff and EHI._cache.diff > 0 then
            self.ehi:AddTracker({
                id = "Assault",
                diff = EHI._cache.diff,
                class = EHI.Trackers.Assault.Assault
            }, 0)
        end
        EHI:HookWithID(self, "set_control_info", "EHI_Assault_set_control_info", set_assault_delay)
    end
    EHI:HookWithID(HUDManager, "set_control_info", "EHI_Assault_set_control_info", set_assault_delay)
    VerifyHostageHesitationDelay()
    EHI:AddCallback(EHI.CallbackMessage.AssaultWaveModeChanged, function(mode)
        if mode == "endless" then
            EndlessAssault = true
            managers.ehi_tracker:RemoveTracker("Assault")
        else
            EndlessAssault = nil
        end
    end)
    EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
        EndlessAssault = nil
    end)
else
    if EHI:AssaultDelayTrackerIsEnabled() then
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
            if EHI._cache.diff and EHI._cache.diff > 0 and not self._ehi_manual_block then
                self.ehi:AddTracker({
                    id = "AssaultDelay",
                    diff = EHI._cache.diff,
                    class = EHI.Trackers.Assault.Delay
                })
                EHI:HookWithID(HUDManager, "set_control_info", "EHI_AssaultDelay_set_control_info", set_assault_delay)
            end
        end
        EHI:HookWithID(HUDManager, "set_control_info", "EHI_AssaultDelay_set_control_info", set_assault_delay)
        VerifyHostageHesitationDelay()
    end
    if EHI:GetOption("show_assault_time_tracker") then
        local start_original = HUDManager.sync_start_assault
        local is_skirmish = tweak_data.levels:IsLevelSkirmish(level_id)
        local EndlessAssault = nil
        function HUDManager:sync_start_assault(...)
            start_original(self, ...)
            if self._ehi_assault_in_progress or self._ehi_manual_block then
                return
            elseif (EHI._cache.diff and EHI._cache.diff > 0 and not EndlessAssault) or is_skirmish then
                self.ehi:AddTracker({
                    id = "AssaultTime",
                    diff = EHI._cache.diff or 0,
                    class = EHI.Trackers.Assault.Time
                })
            end
            self._ehi_assault_in_progress = true
        end
        local end_original = HUDManager.sync_end_assault
        function HUDManager:sync_end_assault(...)
            end_original(self, ...)
            self.ehi:RemoveTracker("AssaultTime")
            self._ehi_assault_in_progress = nil
        end
        EHI:AddCallback(EHI.CallbackMessage.AssaultWaveModeChanged, function(mode)
            if mode == "endless" then
                EndlessAssault = true
                managers.ehi_tracker:RemoveTracker("AssaultTime")
            else
                EndlessAssault = nil
            end
        end)
        EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
            EndlessAssault = nil
        end)
    end
end

function HUDManager:SetAssaultTrackerManualBlock(block)
    self._ehi_manual_block = block
    if block then
        self.ehi:CallFunction("Assault", "PoliceActivityBlocked")
        self.ehi:CallFunction("AssaultDelay", "PoliceActivityBlocked")
        self.ehi:CallFunction("AssaultTime", "PoliceActivityBlocked")
    end
end

function HUDManager:ShowAchievementStartedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", EHI._cache.Beardlib[id].name, "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

function HUDManager:ShowAchievementFailedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", EHI._cache.Beardlib[id].name, "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

function HUDManager:ShowAchievementDescription(id, beardlib)
    if beardlib then
        local Achievement = EHI._cache.Beardlib[id]
        managers.chat:_receive_message(1, Achievement.name, Achievement.objective, Color.white)
    else
        managers.chat:_receive_message(1, managers.localization:text("achievement_" .. id), managers.localization:text("achievement_" .. id .. "_desc"), Color.white)
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

function HUDManager:DebugElement(id, editor_name, enabled)
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(id) .. "; Editor Name: " .. tostring(editor_name) .. "; Enabled: " .. tostring(enabled), Color.white)
end

function HUDManager:DebugExperience(id, name, amount)
    managers.chat:_receive_message(1, "[EHI]", string.format("`%s` ElementExperince %d: Gained %d XP", name, id, amount), Color.white)
end

function HUDManager:DebugBaseElement(id, instance_index, continent_index, element)
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(EHI:GetBaseUnitID(id, instance_index, continent_index or 100000)) .. "; Element: " .. tostring(element), Color.white)
end

function HUDManager:DebugBaseElement2(base_id, instance_index, continent_index, element, instance_name)
    managers.chat:_receive_message(1, "[EHI]", "Base ID: " .. tostring(EHI:GetBaseUnitID(base_id, instance_index, continent_index or 100000)) .. "; ID: " .. tostring(base_id) .. "; Element: " .. tostring(element) .. "; Instance: " .. tostring(instance_name), Color.white)
end

--[[local animation = { start_t = {}, end_t = {} }
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
end]]