local EHI = EHI
if EHI:CheckLoadHook("LevelsTweakData") then
	return
end

---@class LevelsTweakData
---@field GetGroupAIState fun(self: self, level_id: string?): string
---@field IsLevelSkirmish fun(self: self, level_id: string?): boolean
---@field IsLevelSafehouse fun(self: self, level_id: string?): boolean
---@field IsStealthAvailable fun(self: self, level_id: string?): boolean
---@field IsStealthRequired fun(self: self, level_id: string?): boolean
---@field IsLevelChristmas fun(self: self, level_id: string?): boolean
---@field IsLevelCustom fun(self: self, level_id: string?): boolean

---@param level_id string?
---@return string
function LevelsTweakData:GetGroupAIState(level_id)
	local level_data = self[level_id or Global.game_settings.level_id] or {}
    return level_data.group_ai_state or "besiege"
end

---@param level_id string?
---@return boolean
function LevelsTweakData:IsLevelSkirmish(level_id)
	return self:GetGroupAIState(level_id) == "skirmish"
end

---@param level_id string?
---@return boolean
function LevelsTweakData:IsLevelSafehouse(level_id)
	local level_data = self[level_id or Global.game_settings.level_id] or {}
	return level_data.is_safehouse or level_id == "safehouse"
end

---@param level_id string?
---@return boolean
function LevelsTweakData:IsStealthAvailable(level_id)
	local level_data = self[level_id or Global.game_settings.level_id] or {}
	-- In case the heist will require stealth completion but does not have XP bonus
    -- Big Oil Day 2 is exception to this rule because guards have pagers
	return level_data.ghost_bonus or level_data.ghost_required or level_data.ghost_required_visual or level_id == "welcome_to_the_jungle_2"
end

---@param level_id string?
---@return boolean
function LevelsTweakData:IsStealthRequired(level_id)
	local level_data = self[level_id or Global.game_settings.level_id] or {}
	return level_data.ghost_required or level_data.ghost_required_visual
end

---@param level_id string?
---@return boolean
function LevelsTweakData:IsLevelChristmas(level_id)
	local level_data = self[level_id or Global.game_settings.level_id] or {}
	return level_data.is_christmas_heist
end

---@param level_id string?
---@return boolean
function LevelsTweakData:IsLevelCustom(level_id)
	local level_data = self[level_id or Global.game_settings.level_id] or {}
	return level_data.custom or false
end