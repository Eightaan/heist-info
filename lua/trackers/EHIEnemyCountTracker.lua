EHIEnemyCountTracker = class(EHICountTracker)
if EHI:GetOption("show_enemy_count_show_pagers") then
    EHIEnemyCountTracker._forced_icons = { "pager_icon", "enemy" }
    function EHIEnemyCountTracker:Format()
        return (self._alarm_count - self._alarm_count_answered) .. "|" .. self._count
    end
else
    EHIEnemyCountTracker._forced_icons = { "enemy" }
end
function EHIEnemyCountTracker:init(...)
    self._alarm_count = 0
    self._alarm_count_answered = 0
    EHIEnemyCountTracker.super.init(self, ...)
end

function EHIEnemyCountTracker:OverridePanel()
    if self._icon2 or self._forced_icons[1] == "enemy" then
        return
    end
    local texture, text_rect = self:GetIcon("enemy")
    self._icon2 = self._panel:bitmap({
        name = "icon2",
        texture = texture,
        texture_rect = text_rect,
        alpha = 1,
        visible = false,
        x = self._icon1:x(),
        w = self._icon_size_scaled,
        h = self._icon_size_scaled
    })
    self._manually_created_icon2 = true
end

function EHIEnemyCountTracker:Update()
    self._text:set_text(self:Format())
    if self._anim_flash then
        self:AnimateBG(self._flash_times)
    end
end

function EHIEnemyCountTracker:Alarm()
    self._alarm_sounded = true
    self._count = self._count + self._alarm_count
    self.Format = self.super.Format
    self:Update()
    self:FitTheText()
    self:AnimateBG()
    if self._icon2 then
        self._icon2:set_x(self._icon1:x())
        self._icon2:set_visible(true)
        self._icon1:set_visible(false)
        if not self._manually_created_icon2 then
            self._parent_class:ChangeTrackerWidth(self._id, self._time_bg_box:w() + self._icon_gap_size_scaled)
        end
    end
end

function EHIEnemyCountTracker:NormalEnemyRegistered()
    self._count = self._count + 1
    self:Update()
end

function EHIEnemyCountTracker:NormalEnemyUnregistered()
    self._count = self._count - 1
    self:Update()
end

function EHIEnemyCountTracker:AlarmEnemyRegistered()
    if self._alarm_sounded then
        self:NormalEnemyRegistered()
        return
    end
    self._alarm_count = self._alarm_count + 1
    self:Update()
    self:FitTheText()
end

function EHIEnemyCountTracker:AlarmEnemyUnregistered()
    if self._alarm_sounded then
        self:NormalEnemyUnregistered()
        return
    end
    self._alarm_count = self._alarm_count - 1
    self:Update()
    self:FitTheText()
end

function EHIEnemyCountTracker:AlarmEnemyPagerAnswered()
    self._alarm_count_answered = self._alarm_count_answered + 1
    self:Update()
    self:FitTheText()
end

function EHIEnemyCountTracker:AlarmEnemyPagerKilled()
    self._alarm_count_answered = self._alarm_count_answered - 1
    self:Update()
    self:FitTheText()
end

function EHIEnemyCountTracker:GetEnemyCount()
    if self._alarm_sounded then
        return self._count
    end
    return self._count + self._alarm_count
end

function EHIEnemyCountTracker:ResetCounter()
    self._count = 0
    self._alarm_count = 0
end