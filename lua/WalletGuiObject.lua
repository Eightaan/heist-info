local EHI = EHI
if EHI:CheckHook("WalletGuiObject") or not EHI:GetOption("show_remaining_xp") then
    return
end

local infamy_pool = ""
local next_level = ""
local _100_in = ""
local _xp = ""
EHI:AddCallback(EHI.CallbackMessage.LocLoaded, function(loc)
    infamy_pool = loc:text("ehi_experience_infamy_pool")
    next_level = loc:text("ehi_experience_next_level")
    _100_in = loc:text("ehi_experience_100_in")
    _xp = loc:text("ehi_experience_xp")
end)
local to_100_left = EHI:GetOption("show_remaining_xp_to_100")

local refresh = WalletGuiObject.refresh
function WalletGuiObject.refresh(...)
    refresh(...)
    if Global.wallet_panel then
        local level_text = Global.wallet_panel:child("wallet_level_text") --[[@as PanelText]]
        local skillpoint_icon = Global.wallet_panel:child("wallet_skillpoint_icon") --[[@as PanelBitmap]]
        local skillpoint_text = Global.wallet_panel:child("wallet_skillpoint_text") --[[@as PanelText]]
        local xp = managers.experience
        local s = ""
        if xp:reached_level_cap() then -- Level is maxed, show Infamy Pool instead
            s = ", " .. infamy_pool .. " " .. xp:experience_string(xp:GetRemainingPrestigeXP()) .. " " .. _xp
        elseif to_100_left then
            -- calculate total XP to 100
            local xpToNextText = xp:experience_string(math.max(xp:next_level_data_points() - xp:next_level_data_current_points(), 0))
            local xpTo100Text = xp:experience_string(xp:GetRemainingXPToMaxLevel())
            s = ", " .. next_level .. " " .. xpToNextText .. " " .. _xp .. ", " .. _100_in .. " " .. xpTo100Text .. " " .. _xp
        else
            s = ", " .. next_level .. " " .. xp:experience_string(xp:next_level_data_points() - xp:next_level_data_current_points()) .. " " .. _xp
        end
        level_text:set_text(tostring(xp:current_level()) .. s)
        local _, _, w, h = level_text:text_rect()
        level_text:set_size(w, h)
        level_text:set_position(math.round(level_text:x()), math.round(level_text:y()))
        skillpoint_icon:set_leftbottom(level_text:right() + 10, Global.wallet_panel:h() - 2)
        skillpoint_text:set_left(skillpoint_icon:right() + 2)
        WalletGuiObject.refresh_blur()
    end
end