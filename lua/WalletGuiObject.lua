local EHI = EHI
if EHI:CheckHook("WalletGuiObject") or not EHI:GetOption("show_remaining_xp") then
    return
end

local infamy_pool = ""
local next_level = ""
local _100_in = ""
EHI:AddCallback(EHI.CallbackMessage.LocLoaded, function(loc)
    infamy_pool = loc:text("ehi_experience_infamy_pool")
    next_level = loc:text("ehi_experience_next_level")
    _100_in = loc:text("ehi_experience_100_in")
end)
local to_100_left = EHI:GetOption("show_remaining_xp_to_100")

local refresh = WalletGuiObject.refresh
function WalletGuiObject.refresh(...)
    refresh(...)
    local level_text = Global.wallet_panel:child("wallet_level_text")
    local skillpoint_icon = Global.wallet_panel:child("wallet_skillpoint_icon")
    local skillpoint_text = Global.wallet_panel:child("wallet_skillpoint_text")
    local xp = managers.experience
    local s = ""
    if xp:level_cap() <= xp:current_level() then -- Level is maxed, show Infamy Pool instead
        s = ", " .. infamy_pool .. " " .. xp:experience_string(xp:get_max_prestige_xp() - xp:get_current_prestige_xp()) .. " XP"
    elseif to_100_left then
        -- calculate total XP to 100
        local totalXpTo100 = 0
        for _, level in ipairs(tweak_data.experience_manager.levels) do
            totalXpTo100 = totalXpTo100 + Application:digest_value(level.points, false)
        end
        local xpToNextText = xp:experience_string(math.max(xp:next_level_data_points() - xp:next_level_data_current_points(), 0))
        local xpTo100Text = xp:experience_string(math.max(totalXpTo100 - xp:total(), 0))
        s = ", " .. next_level .. " " .. xpToNextText .. " XP, " .. _100_in .. " " .. xpTo100Text .. " XP"
    else
        s = ", " .. next_level .. " " .. xp:experience_string(xp:next_level_data_points() - xp:next_level_data_current_points())
    end
    level_text:set_text(tostring(xp:current_level()) .. s)
    local _, _, w, h = level_text:text_rect()
    level_text:set_size(w, h)
    level_text:set_position(math.round(level_text:x()), math.round(level_text:y()))
    skillpoint_icon:set_leftbottom(level_text:right() + 10, Global.wallet_panel:h() - 2)
    skillpoint_text:set_left(skillpoint_icon:right() + 2)
    WalletGuiObject.refresh_blur()
end