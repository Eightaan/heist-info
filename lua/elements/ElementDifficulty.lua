local EHI = EHI
if EHI:CheckLoadHook("ElementDifficulty") then
    return
end

if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

if tweak_data.levels:get_group_ai_state() == "skirmish" then
    return
end

local original =
{
    client_on_executed = ElementDifficulty.client_on_executed,
    on_executed = ElementDifficulty.on_executed
}

local Trigger
if EHI:GetOption("show_difficulty_tracker") then
    local id = "Difficulty"
    Trigger = function(value)
        local diff = EHI:RoundChanceNumber(value)
        if managers.ehi:TrackerExists(id) then
            managers.ehi:SetChance(id, diff)
        else
            managers.ehi:AddTracker({
                id = id,
                icons = { "enemy" },
                chance = diff,
                class = EHI.Trackers.Chance
            })
        end
    end
else
    Trigger = function(value) end
end

local function Run(value)
    EHI._cache.diff = value
    Trigger(value)
    managers.ehi:CallFunction("Assault", "UpdateDiff", value)
    managers.ehi:CallFunction("AssaultDelay", "UpdateDiff", value)
    managers.ehi:CallFunction("AssaultTime", "UpdateDiff", value)
end

function ElementDifficulty:client_on_executed(...)
    original.client_on_executed(self, ...)
    Run(self._values.difficulty)
end

function ElementDifficulty:on_executed(...)
    if not self._values.enabled then
        return
    end
    Run(self._values.difficulty)
    original.on_executed(self, ...)
end