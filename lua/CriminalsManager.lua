local EHI = EHI
if EHI:CheckLoadHook("CriminalsManager") or EHI:IsXPTrackerHidden() then
    return
end

if EHI:IsRunningBB() then
    local original =
    {
        add_character = CriminalsManager.add_character,
        set_unit = CriminalsManager.set_unit,
        _remove = CriminalsManager._remove
    }

    function CriminalsManager:add_character(name, ...)
        original.add_character(self, name, ...)
        local character = self:character_by_name(name)
        if character and character.taken and character.data.ai then
            managers.experience:IncreaseAlivePlayers()
        end
    end

    function CriminalsManager:set_unit(name, unit, ...)
        original.set_unit(self, name, unit, ...)
        local character = self:character_by_name(name)
        if character and character.taken and character.data.ai and not unit:base().is_local_player then
            managers.experience:IncreaseAlivePlayers()
        end
    end

    function CriminalsManager:_remove(id, ...)
        local char_data = self._characters[id]
        if char_data.data.ai then
            managers.experience:DecreaseAlivePlayers()
        end
        original._remove(self, id, ...)
    end
elseif EHI:IsRunningUsefulBots() then
    local function Query(...)
        managers.experience:QueryAmountOfAllPlayers()
    end
    EHI:Hook(CriminalsManager, "add_character", Query)
    EHI:Hook(CriminalsManager, "set_unit", Query)
    EHI:Hook(CriminalsManager, "on_peer_left", Query)
    EHI:Hook(CriminalsManager, "_remove", Query)
elseif not Global.game_settings.single_player then
    local Query
    if EHI:IsRunningUsefulBots() then
        Query = function(...)
            managers.experience:QueryAmountOfAllPlayers()
        end
        EHI:Hook(CriminalsManager, "_remove", Query)
    else
        Query = function(...)
            managers.experience:QueryAmountOfAlivePlayers()
        end
    end
    EHI:Hook(CriminalsManager, "add_character", Query)
    EHI:Hook(CriminalsManager, "set_unit", Query)
    EHI:Hook(CriminalsManager, "on_peer_left", Query)
end