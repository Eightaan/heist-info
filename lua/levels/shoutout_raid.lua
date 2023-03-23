local EHI = EHI
EHIVaultTemperatureTracker = class(EHITracker)
EHIVaultTemperatureTracker._forced_icons = { EHI.Icons.Vault }
function EHIVaultTemperatureTracker:init(panel, params)
    params.time = 500
    self._synced_time = 0
    self._tick = 0.1
    EHIVaultTemperatureTracker.super.init(self, panel, params)
end

function EHIVaultTemperatureTracker:CheckTime(time)
    if self._synced_time == 0 then
        self._time = (50 - time) * 10
    else
        local new_tick = time - self._synced_time
        if new_tick ~= self._tick then
            self._time = ((50 - time) / (new_tick * 10)) * 10
            self._tick = new_tick
        end
    end
    self._synced_time = time
end

EHIVaultTemperatureWaypoint = class(EHIWaypoint)
EHIVaultTemperatureWaypoint.CheckTime = EHIVaultTemperatureTracker.CheckTime
function EHIVaultTemperatureWaypoint:init(waypoint, params, parent_class)
    EHIVaultTemperatureWaypoint.super.init(self, waypoint, params, parent_class)
    self._synced_time = 0
    self._tick = 0.1
end

local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local trophy = {
    trophy_longfellow =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { time = 420 }
        },
        mission_end_callback = true
    }
}

EHI:ParseTriggers({
    trophy = trophy
})
EHI:ShowAchievementLootCounter({
    achievement = "melt_3",
    max = 8,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = { "coke", "gold", "money", "weapon", "weapons" }
    }
})

local max = 6 -- Normal to Very Hard; Mission Loot
if ovk_and_up then
    max = 8
end
EHI:ShowLootCounter({
    max = max,
    additional_loot = 8
}) -- 14 or 16

local tbl =
{
    --levels/instances/unique/shout_container_vault
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100014, 2850)] = { ignore = true }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        vault_found = 4000,
        vault_open = 4000,
        escape = 4000
    },
    loot =
    {
        warhead = { amount = 8000, to_secure = max },
        _else = { amount = 1500 },
        xp_bonus = { amount = 2000, to_secure = max + 8 }
    },
    no_total_xp = true
})