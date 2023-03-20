local format = EHI:GetOption("variable_random_loot_format")
EHILootTracker = class(EHIProgressTracker)
EHILootTracker._forced_icons = { EHI.Icons.Loot }
EHILootTracker._show_popup = EHI:GetOption("show_all_loot_secured_popup")
function EHILootTracker:init(panel, params)
    self._mission_loot = 0
    self._offset = params.offset or 0
    self._max_random = params.max_random or 0
    self._stay_on_screen = self._max_random > 0
    EHILootTracker.super.init(self, panel, params)
    self._remove_after_reaching_counter_target = not self._stay_on_screen
    self._loot_id = {}
end

if format == 1 then
    function EHILootTracker:Format()
        if self._max_random > 0 then
            local max = self._max + self._max_random
            return self._progress .. "/" .. self._max .. "-" .. max .. "?"
        end
        return EHILootTracker.super.Format(self)
    end
elseif format == 2 then
    function EHILootTracker:Format()
        if self._max_random > 0 then
            local max = self._max + self._max_random
            return self._progress .. "/" .. max .. "?"
        end
        return EHILootTracker.super.Format(self)
    end
else
    function EHILootTracker:Format()
        if self._max_random > 0 then
            return self._progress .. "/" .. self._max .. "+" .. self._max_random .. "?"
        end
        return EHILootTracker.super.Format(self)
    end
end

function EHILootTracker:SetProgress(progress)
    local fixed_progress = progress + self._mission_loot - self._offset
    EHILootTracker.super.SetProgress(self, fixed_progress)
end

function EHILootTracker:Finalize()
    local progress = self._progress
    self._progress = self._progress - self._offset
    EHILootTracker.super.Finalize(self)
    self._progress = progress
end

function EHILootTracker:SetCompleted(force)
    EHILootTracker.super.SetCompleted(self, force)
    if self._stay_on_screen and self._status then
        self._text:set_text(self:Format())
        self:FitTheText()
        self._status = nil
    elseif self._show_popup then
        managers.hud:custom_ingame_popup_text("LOOT COUNTER", managers.localization:text("ehi_popup_all_loot_secured"), "EHI_Loot")
    end
end

function EHILootTracker:SetProgressMax(max)
    EHILootTracker.super.SetProgressMax(self, max)
    self:SetTextColor(Color.white)
    self._disable_counting = nil
    self:VerifyStatus()
end

function EHILootTracker:VerifyStatus()
    self._stay_on_screen = self._max_random > 0
    self._remove_after_reaching_counter_target = not self._stay_on_screen
    if self._progress == self._max then
        self:SetCompleted()
    end
end

function EHILootTracker:RandomLootSpawned(random)
    if self._max_random <= 0 then
        return
    end
    local n = random or 1
    self._max_random = self._max_random - n
    self:IncreaseProgressMax(n)
end

function EHILootTracker:RandomLootDeclined(random)
    if self._max_random <= 0 then
        return
    end
    self._max_random = self._max_random - (random or 1)
    self:SetProgressMax(self._max)
end

function EHILootTracker:SetMaxRandom(max)
    self._max_random = max
    self:SetProgressMax(self._max)
end

function EHILootTracker:IncreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random + (progress or 1))
end

function EHILootTracker:DecreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random - (progress or 1))
end

function EHILootTracker:RandomLootSpawned2(id, force)
    if self._loot_id[id] then
        if force then -- This is here to combat desync, use it if element does not have "fail" state
            self:IncreaseProgressMax()
        end
        return
    end
    self._loot_id[id] = true
    self:RandomLootSpawned()
end

function EHILootTracker:RandomLootDeclined2(id)
    if self._loot_id[id] then
        return
    end
    self:RandomLootDeclined()
end

function EHILootTracker:BlockRandomLoot(id)
    self._loot_id[id] = true
end

function EHILootTracker:SecuredMissionLoot()
    local progress = self._progress - self._mission_loot + self._offset
    self._mission_loot = self._mission_loot + 1
    self:SetProgress(progress)
end