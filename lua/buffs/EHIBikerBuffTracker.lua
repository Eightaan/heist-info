local max_kills = tweak_data.upgrades.wild_max_triggers_per_time or 10
local pm
local f
---@class EHIBikerBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIBikerBuffTracker = class(EHIBuffTracker)
function EHIBikerBuffTracker:PreUpdateCheck()
    pm = managers.player
    return pm:has_category_upgrade("player", "wild_health_amount") or pm:has_category_upgrade("player", "wild_armor_amount")
end

function EHIBikerBuffTracker:PreUpdate()
    f = function(...)
        if pm._wild_kill_triggers then
            -- Old kills were purged here before our post hook is called, no need to purge them again
            local kills = #pm._wild_kill_triggers
            self:Trigger(kills)
        end
    end
    self:CustodyState(false)
    local function f2(state)
        self:CustodyState(state)
    end
    EHI:AddOnCustodyCallback(f2)
end

function EHIBikerBuffTracker:CustodyState(state)
    if state then
        EHI:Unhook("BikerBuff_Post")
    else
        EHI:HookWithID(PlayerManager, "chk_wild_kill_counter", "EHI_BikerBuff_Post", f)
    end
end

function EHIBikerBuffTracker:Trigger(kills)
    if kills < 1 then
        if self._active then
            self:Deactivate()
        end
        return
    end
    local t = Application:time()
    local cd
    if kills < max_kills then
        cd = pm._wild_kill_triggers[kills] - t
        self:SetIconColor(Color.white)
        self._hint:set_text(tostring(kills))
    else
        cd = pm._wild_kill_triggers[1] - t
        self:SetIconColor(Color.red)
        self._hint:set_text(tostring(max_kills))
        self._retrigger = true
    end
    if self._active then
        self:Extend(cd)
    else
        self:Activate(cd)
    end
end

function EHIBikerBuffTracker:SetIconColor(color)
    self._panel:child("icon"):set_color(color) ---@diagnostic disable-line
end

function EHIBikerBuffTracker:Activate(t)
    EHIBikerBuffTracker.super.Activate(self, t)
    self:AddVisibleBuff()
end

function EHIBikerBuffTracker:Deactivate()
    if self._retrigger then
        self._retrigger = nil
        self:Retrigger()
        return
    end
    EHIBikerBuffTracker.super.Deactivate(self)
end

function EHIBikerBuffTracker:Retrigger()
    -- Check again if there are still kills, but first, purge old kills so they don't mess up with the calculation
    local t = Application:time()
    while pm._wild_kill_triggers[1] and t >= pm._wild_kill_triggers[1] do
        table.remove(pm._wild_kill_triggers, 1)
    end
    local n = #pm._wild_kill_triggers
    self:Trigger(n)
end