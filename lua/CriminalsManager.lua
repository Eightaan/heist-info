local EHI = EHI
if EHI:CheckLoadHook("CriminalsManager") or EHI:IsXPTrackerHidden() then
    return
end

if BB and BB.grace_period and Global.game_settings.single_player and Global.game_settings.team_ai then
    local original =
    {
        add_character = CriminalsManager.add_character,
        set_unit = CriminalsManager.set_unit,
        _remove = CriminalsManager._remove
    }

    function CriminalsManager:add_character(name, unit, ...)
        original.add_character(self, name, unit, ...)
        local character = self:character_by_name(name)
        if character and unit and not unit:base().is_local_player then
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
elseif not Global.game_settings.single_player then
    local function Query(...)
        managers.experience:QueryAmountOfAlivePlayers()
    end
    EHI:Hook(CriminalsManager, "add_character", Query)
    EHI:Hook(CriminalsManager, "set_unit", Query)
    EHI:Hook(CriminalsManager, "on_peer_left", Query)
end