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
    managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
    managers.ehi:SetChance("pagers_chance", (EHI:RoundChanceNumber(tweak_data.player.alarm_pager.bluff_success_chance_w_skill[self._nr_successful_alarm_pager_bluffs + 1] or 0)))
end

function GroupAIStateBase:sync_alarm_pager_bluff(...) -- Called by client
    original.sync_alarm_pager_bluff(self, ...)
    managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:load(...)
    dropin = managers.ehi:GetDropin()
    original.load(self, ...)
    if self._enemy_weapons_hot then
        EHI:RunOnAlarmCallbacks(dropin)
    else
        managers.ehi:SetTrackerProgress("pagers", self._nr_successful_alarm_pager_bluffs)
	end
    local law1team = self._teams[tweak_data.levels:get_default_team_ID("combatant")]
    if law1team and law1team.damage_reduction then -- PhalanxDamageReduction is created before this gets set; see GameSetup:load()
        managers.ehi:SetChance("PhalanxDamageReduction", (EHI:RoundChanceNumber(law1team.damage_reduction or 0)))
    elseif self._hunt_mode then -- AssaultTime is created before this is checked; see GameSetup:load()
        managers.ehi:RemoveTracker("AssaultTime")
    end
end

if EHI:ShowDramaTracker() then
    local level_id = Global.game_settings.level_id
    local level_data = tweak_data.levels[level_id]
    if not (level_data.ghost_required or level_data.ghost_required_visual) then
        original._add_drama = GroupAIStateBase._add_drama
        function GroupAIStateBase:_add_drama(...)
            original._add_drama(self, ...)
            managers.ehi:SetChance("Drama", EHI:RoundChanceNumber(self._drama_data.amount))
        end
        EHI:AddOnAlarmCallback(function()
            managers.ehi:AddTracker({
                id = "Drama",
                icons = { "C_Escape_H_Street_Bullet" },
                class = "EHIChanceTracker",
                dont_flash = true
            }, 0)
        end)
    end
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
        if EHI:GetOption("show_minion_per_player") then
            dofile(EHI.LuaPath .. "trackers/EHIMinionTracker.lua")
            UpdateTracker = function(unit, key, amount, peer_id)
                if managers.ehi:TrackerDoesNotExist("Converts") and amount ~= 0 then
                    managers.ehi:AddTracker({
                        id = "Converts",
                        class = "EHIMinionTracker"
                    })
                end
                if amount == 0 then -- Removal
                    managers.ehi:CallFunction("Converts", "RemoveMinion", key)
                else
                    managers.ehi:CallFunction("Converts", "AddMinion", unit, key, amount, peer_id)
                end
            end
        else
            UpdateTracker = function(unit, key, amount, peer_id)
                if managers.ehi:TrackerDoesNotExist("Converts") and amount ~= 0 then
                    managers.ehi:AddTracker({
                        id = "Converts",
                        dont_show_placed = true,
                        icons = { "minion" },
                        class = "EHIEquipmentTracker"
                    })
                end
                managers.ehi:CallFunction("Converts", "UpdateAmount", unit, key, amount)
            end
        end
    end

    function GroupAIStateBase:EHIRemoveConvert(params, unit)
        EHI:CallCallback(EHI.CallbackMessage.OnMinionKilled)
        UpdateTracker(nil, params.unit_key, 0)
        unit:character_damage():remove_listener(callback_key)
        unit:base():remove_destroy_listener(callback_key)
        if game_is_running and show_popup and params.local_peer and game_state_machine:verify_game_state(_G.GameStateFilters.any_ingame) then
            if show_popup_type == 1 then
                managers.hud:custom_ingame_popup_text("MINION", managers.localization:text("ehi_popup_minion_killed"), "EHI_Minion")
            else
                managers.hud:show_hint({ text = managers.localization:text("ehi_popup_minion_killed") })
            end
        end
    end
    EHI:AddCallback(EHI.CallbackMessage.GameRestart, function()
        game_is_running = false
    end)

    function GroupAIStateBase:EHIAddListener(unit, local_peer)
        if not unit.key then
            EHI:Log("Convert does not have a 'key()' function! Aborting to avoid crashing the game.")
            return
        end
        EHI:CallCallback(EHI.CallbackMessage.OnMinionAdded)
        local key = tostring(unit:key())
        local clbk = callback(self, self, "EHIRemoveConvert", { unit_key = key, local_peer = local_peer })
        unit:base():add_destroy_listener(callback_key, clbk)
        unit:character_damage():add_listener(callback_key, { "death" }, clbk)
    end

    original.convert_hostage_to_criminal = GroupAIStateBase.convert_hostage_to_criminal
    function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit, ...)
		original.convert_hostage_to_criminal(self, unit, peer_unit, ...)
		if unit:brain()._logic_data.is_converted then
			local peer_id = peer_unit and managers.network:session():peer_by_unit(peer_unit):id() or managers.network:session():local_peer():id()
            local local_peer = not peer_unit
            self:EHIAddListener(unit, local_peer)
            UpdateTracker(unit, tostring(unit:key()), 1, peer_id)
		end
	end

    original.sync_converted_enemy = GroupAIStateBase.sync_converted_enemy
	function GroupAIStateBase:sync_converted_enemy(converted_enemy, owner_peer_id, ...)
		if self._police[converted_enemy:key()] then
            local peer_id = owner_peer_id or 0
            local local_peer = peer_id == managers.network:session():local_peer():id()
            self:EHIAddListener(converted_enemy, local_peer)
            UpdateTracker(converted_enemy, tostring(converted_enemy:key()), 1, peer_id)
		end
		return original.sync_converted_enemy(self, converted_enemy, owner_peer_id, ...)
	end

    original.remove_minion = GroupAIStateBase.remove_minion
    function GroupAIStateBase:remove_minion(minion_key, ...)
        original.remove_minion(self, minion_key, ...)
        UpdateTracker(nil, tostring(minion_key), 0)
    end
end