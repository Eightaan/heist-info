local EHI = EHI
if EHI:CheckLoadHook("GageAssignmentManager") or not EHI:GetOption("show_gage_tracker") then
    return
end

local original =
{
	sync_load = GageAssignmentManager.sync_load,
	present_progress = GageAssignmentManager.present_progress
}

local ShowProgress
if EHI:GetOption("gage_tracker_panel") == 1 then
	ShowProgress = function(picked_up, max, client_sync_load)
		managers.ehi:SetTrackerProgress("Gage", picked_up)
	end
else
	ShowProgress = function(picked_up, max, client_sync_load)
		if (client_sync_load and Global.statistics_manager.playing_from_start) or not EHI:AreGagePackagesSpawned() then
			return
		end
		managers.hud:custom_ingame_popup_text(managers.localization:text("ehi_popup_gage_packages"), tostring(picked_up) .. "/" .. tostring(max), "EHI_Gage")
	end
end

-- Don't use in-game function because it is inaccurate by one package
local function GetGageXPRatio(self, picked_up, max_units)
	if picked_up > 0 then
		local ratio = 1 - (max_units - picked_up) / max_units
		return self._tweak_data:get_experience_multiplier(ratio)
	end
	return 1
end

local function UpdateTracker(self, client_sync_load)
	local max_units = self:count_all_units()
	local remaining = self:count_active_units() - 1
	local picked_up = max_units - remaining
	if client_sync_load then
		if not Global.statistics_manager.playing_from_start then
			picked_up = math.max(picked_up - 1, 0)
			EHI._cache.GagePackagesProgress = picked_up
		end
	end
	ShowProgress(picked_up, max_units, client_sync_load)
	if managers.experience.SetGagePackageBonus then
		managers.experience:SetGagePackageBonus(GetGageXPRatio(self, picked_up, max_units))
	end
end

function GageAssignmentManager:present_progress(...)
	original.present_progress(self, ...)
	UpdateTracker(self)
end

function GageAssignmentManager:sync_load(...)
	original.sync_load(self, ...)
	UpdateTracker(self, true)
end