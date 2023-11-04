local EHI = EHI
if EHI:CheckLoadHook("GroupAIStateBase") then
    return
end

local dropin = false
local function Execute()
    EHI:RunOnAlarmCallbacks(dropin)
end

local original =
{
    init = GroupAIStateBase.init,
    on_successful_alarm_pager_bluff = GroupAIStateBase.on_successful_alarm_pager_bluff,
    sync_alarm_pager_bluff = GroupAIStateBase.sync_alarm_pager_bluff,
    load = GroupAIStateBase.load
}

function GroupAIStateBase:init(...)
	original.init(self, ...)
    self:add_listener("EHI_EnemyWeaponsHot", { "enemy_weapons_hot" }, Execute)
end

function GroupAIStateBase:on_successful_alarm_pager_bluff(...) -- Called by host
    original.on_successful_alarm_pager_bluff(self, ...)
    managers.ehi_tracker:SetTrackerProgress("Pagers", self._nr_successful_alarm_pager_bluffs)
    managers.ehi_tracker:SetChance("PagersChance", (EHI:RoundChanceNumber(tweak_data.player.alarm_pager.bluff_success_chance_w_skill[self._nr_successful_alarm_pager_bluffs + 1] or 0)))
end

function GroupAIStateBase:sync_alarm_pager_bluff(...) -- Called by client
    original.sync_alarm_pager_bluff(self, ...)
    managers.ehi_tracker:SetTrackerProgress("Pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:load(...)
    dropin = managers.ehi_manager:GetDropin()
    original.load(self, ...)
    if self._enemy_weapons_hot then
        EHI:RunOnAlarmCallbacks(dropin)
        local law1team = self._teams[tweak_data.levels:get_default_team_ID("combatant")]
        if law1team and law1team.damage_reduction then -- PhalanxDamageReduction is created before this gets set; see GameSetup:load()
            managers.ehi_tracker:SetChance("PhalanxDamageReduction", (EHI:RoundChanceNumber(law1team.damage_reduction or 0)))
        elseif self._hunt_mode then -- Assault and AssaultTime is created before this is checked; see GameSetup:load()
            managers.ehi_tracker:RemoveTracker("Assault")
            managers.ehi_tracker:RemoveTracker("AssaultTime")
        end
    else
        managers.ehi_tracker:SetTrackerProgress("Pagers", self._nr_successful_alarm_pager_bluffs)
	end
end

if EHI:ShowDramaTracker() and not tweak_data.levels:IsStealthRequired() then
    local function Create()
        if managers.ehi_tracker:TrackerExists("Drama") then
            return
        end
        local pos = managers.ehi_tracker:TrackerExists("Assault") and 1 or 0
        managers.ehi_tracker:AddTracker({
            id = "Drama",
            icons = { "C_Escape_H_Street_Bullet" },
            class = EHI.Trackers.Chance,
            flash_bg = false
        }, pos)
    end
    original._add_drama = GroupAIStateBase._add_drama
    function GroupAIStateBase:_add_drama(...)
        original._add_drama(self, ...)
        managers.ehi_tracker:SetChance("Drama", EHI:RoundChanceNumber(self._drama_data.amount))
    end
    EHI:AddOnAlarmCallback(Create)
    EHI:AddCallback(EHI.CallbackMessage.AssaultWaveModeChanged, function(mode)
        if mode == "endless" then
            managers.ehi_tracker:RemoveTracker("Drama")
        elseif managers.ehi_tracker:TrackerDoesNotExist("Drama") then
            Create()
        end
    end)
end

local show_minion_tracker = EHI:GetOption("show_minion_tracker")
local show_popup = EHI:GetOption("show_minion_killed_message")
if show_minion_tracker or show_popup then
    local callback_key = "EHIConvert"
    local show_popup_type = EHI:GetOption("show_minion_killed_message_type")
    local game_is_running = true
    if show_popup then
        EHI:SetNotificationAlert("MINION", "ehi_popup_minion")
    end
    local UpdateTracker = function(...) end
    if show_minion_tracker then
        if EHI:GetOption("show_minion_option") ~= 2 then
            dofile(EHI.LuaPath .. "trackers/EHIMinionTracker.lua")
            UpdateTracker = function(unit, key, amount, peer_id)
                if managers.ehi_tracker:TrackerDoesNotExist("Converts") and amount ~= 0 then
                    managers.ehi_tracker:AddTracker({
                        id = "Converts",
                        class = "EHIMinionTracker"
                    })
                end
                if amount == 0 then -- Removal
                    managers.ehi_tracker:CallFunction("Converts", "RemoveMinion", key)
                else
                    managers.ehi_tracker:CallFunction("Converts", "AddMinion", unit, key, amount, peer_id)
                end
            end
        else
            UpdateTracker = function(unit, key, amount, peer_id)
                if managers.ehi_tracker:TrackerDoesNotExist("Converts") and amount ~= 0 then
                    managers.ehi_tracker:AddTracker({
                        id = "Converts",
                        dont_show_placed = true,
                        icons = { "minion" },
                        class = "EHIEquipmentTracker"
                    })
                end
                managers.ehi_tracker:CallFunction("Converts", "UpdateAmount", unit, key, amount)
            end
        end
    end

    function GroupAIStateBase:EHIConvertDied(params, unit)
        params.killed_callback = nil
        self:EHIRemoveConvert(params, unit)
    end
    function GroupAIStateBase:EHIConvertDestroyed(params, unit)
        params.destroyed_callback = nil
        self:EHIRemoveConvert(params, unit)
    end
    function GroupAIStateBase:EHIRemoveConvert(params, unit)
        EHI:CallCallback(EHI.CallbackMessage.OnMinionKilled)
        if params.update_tracker then
            UpdateTracker(nil, params.unit_key, 0)
        end
        if params.killed_callback then
            unit:character_damage():remove_listener(callback_key)
        end
        if params.destroyed_callback then
            unit:base():remove_destroy_listener(callback_key)
        end
        if game_is_running and show_popup and params.local_peer then
            if show_popup_type == 1 then
                managers.hud:custom_ingame_popup_text("MINION", managers.localization:text("ehi_popup_minion_killed"), "EHI_Minion")
            else
                managers.hud:show_hint({ text = managers.localization:text("ehi_popup_minion_killed") })
            end
        end
    end
    local function GameEnd()
        game_is_running = false
    end
    EHI:AddCallback(EHI.CallbackMessage.GameRestart, GameEnd)
    EHI:AddCallback(EHI.CallbackMessage.MissionEnd, GameEnd)

    if EHI:GetOption("show_minion_option") == 1 then -- Only you
        function GroupAIStateBase:EHIAddConvert(unit, local_peer, peer_id)
            if not unit.key then
                EHI:Log("Convert does not have a 'key()' function! Aborting to avoid crashing the game.")
                return
            end
            EHI:CallCallback(EHI.CallbackMessage.OnMinionAdded)
            local key = tostring(unit:key())
            local data = { unit_key = key, local_peer = local_peer, update_tracker = local_peer, killed_callback = true, destroyed_callback = true }
            unit:base():add_destroy_listener(callback_key, callback(self, self, "EHIConvertDestroyed", data))
            unit:character_damage():add_listener(callback_key, { "death" }, callback(self, self, "EHIConvertDied", data))
            if local_peer then
                UpdateTracker(unit, key, 1, peer_id)
            end
        end
    else -- Everyone
        function GroupAIStateBase:EHIAddConvert(unit, local_peer, peer_id)
            if not unit.key then
                EHI:Log("Convert does not have a 'key()' function! Aborting to avoid crashing the game.")
                return
            end
            EHI:CallCallback(EHI.CallbackMessage.OnMinionAdded)
            local key = tostring(unit:key())
            local data = { unit_key = key, local_peer = local_peer, update_tracker = true, killed_callback = true, destroyed_callback = true }
            unit:base():add_destroy_listener(callback_key, callback(self, self, "EHIConvertDestroyed", data))
            unit:character_damage():add_listener(callback_key, { "death" }, callback(self, self, "EHIConvertDied", data))
            UpdateTracker(unit, key, 1, peer_id)
        end
    end

    original.convert_hostage_to_criminal = GroupAIStateBase.convert_hostage_to_criminal
    function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit, ...)
		original.convert_hostage_to_criminal(self, unit, peer_unit, ...)
		if unit:brain()._logic_data.is_converted then
			local peer_id = peer_unit and managers.network:session():peer_by_unit(peer_unit):id() or managers.network:session():local_peer():id()
            local local_peer = not peer_unit
            self:EHIAddConvert(unit, local_peer, peer_id)
		end
	end

    original.sync_converted_enemy = GroupAIStateBase.sync_converted_enemy
	function GroupAIStateBase:sync_converted_enemy(converted_enemy, owner_peer_id, ...)
		if self._police[converted_enemy:key()] then
            local peer_id = owner_peer_id or 0
            self:EHIAddConvert(converted_enemy, peer_id == managers.network:session():local_peer():id(), peer_id)
		end
		return original.sync_converted_enemy(self, converted_enemy, owner_peer_id, ...)
	end

    original.remove_minion = GroupAIStateBase.remove_minion
    function GroupAIStateBase:remove_minion(minion_key, ...)
        original.remove_minion(self, minion_key, ...)
        UpdateTracker(nil, tostring(minion_key), 0)
    end
end