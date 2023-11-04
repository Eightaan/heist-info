local EHI = EHI
if EHI:CheckLoadHook("PlayerActionTriggerHappy") then
    return
end

if not EHI:GetBuffAndOption("trigger_happy") then
    return
end

local original = PlayerAction.ExpertHandling.Function
PlayerAction.ExpertHandling.Function = function(player_manager, accuracy_bonus, max_stacks, max_time, ...)
    managers.ehi_buff:AddBuff2("trigger_happy", Application:time(), max_time)
    original(player_manager, accuracy_bonus, max_stacks, max_time, ...)
    managers.ehi_buff:RemoveBuff("trigger_happy")
end