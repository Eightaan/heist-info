local EHI = EHI
if EHI:CheckLoadHook("HUDMissionBriefing") or Global.game_settings.single_player or EHI:IsXPTrackerDisabled() or not EHI:GetOption("show_mission_xp_overview") then
    return
end

function HUDMissionBriefing:MoveJobName()
    if self.__ehi_moved then
        return
    end
    local job = self._foreground_layer_one and self._foreground_layer_one:child("job_text")
    if job then
        job:set_x(job:x() + 351)
        self.__ehi_moved = true
    end
end