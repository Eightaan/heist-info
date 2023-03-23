local EHI = EHI
if EHI:CheckLoadHook("LevelsTweakData") then
	return
end

function LevelsTweakData:get_group_ai_state()
	local level_data = self[Global.game_settings.level_id]
	if level_data then
        return level_data.group_ai_state or "besiege"
	end
	return "besiege"
end

function LevelsTweakData:IsLevelSkirmish()
	return self:get_group_ai_state() == "skirmish"
end