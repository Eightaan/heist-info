local EHI = EHI
local SF = EHI.SpecialFunctions
--[[function EHI:PaintingCount()
    --[[local paintings = managers.ehi:GetUnits("units/payday2/architecture/com_int_gallery/com_int_gallery_wall_painting_bars", 1)
    local n_of_paintings = 0
    -- 3878622f45bc7dfe => Idstring("g_important") without ID and @ at the end
    for _, painting in pairs(paintings) do
        if painting:damage()._state and painting:damage()._state.object and painting:damage()._state.object["3878622f45bc7dfe"] then
            local state = painting:damage()._state.object["3878622f45bc7dfe"].set_visibility
            -- Object at index 1 is our Idstring "3878622f45bc7dfe", no need to check that again
            -- This check is a bit different than in function EHI:LordOfWar(), because objects are going through "self:set_cat_state2()" in CoreSequenceManager.lua
            if state and state[2] then
                n_of_paintings = n_of_paintings + 1
            end
        end
    end]]
    --[[self:ShowLootCounter({ max = 9 })
    self:ShowAchievementLootCounter({
        achievement = "pink_panther",
        max = 9
    })
end]]

if Global.game_settings.level_id == "gallery" then
    local TT = EHI.Trackers
    local achievements =
    {
        cac_19 =
        {
            elements =
            {
                [100789] = { class = TT.AchievementStatus },
                [104288] = { special_function = SF.SetAchievementComplete },
                [104290] = { special_function = SF.SetAchievementFailed }
            }
        }
    }
    if TheFixes then
        if TheFixesPreventer and TheFixesPreventer.achi_masterpiece then -- Unfixed, assume Vanilla "broken" behavior
        else -- Fixed
            local function f()
                local key = "EHI_ArtGallery_TheFixes"
                CopDamage.register_listener(key, { "on_damage" }, function(damage_info)
                    if damage_info.result.type == "death" then
                        managers.ehi:SetAchievementFailed("cac_19")
                        CopDamage.unregister_listener(key)
                    end
                end)
            end
            achievements.cac_19.elements[100789].special_function = SF.CreateAnotherTrackerWithTracker
            achievements.cac_19.elements[100789].data = { fake_id = 1 }
            achievements.cac_19.elements[1] = { special_function = SF.CustomCode, f = f }
        end
    end

    EHI:ParseTriggers({
        achievement = achievements
    })
end

local other =
{
    [102437] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }, -- +5%
    [103884] = { id = "EscapeChance", special_function = SF.SetChanceFromElement } -- 100 %
}

EHI:ParseTriggers({
    other = other
})

EHI:ShowLootCounter({ max = 9 })
EHI:ShowAchievementLootCounter({
    achievement = "pink_panther",
    max = 9,
    remove_after_reaching_target = false,
    failed_on_alarm = true
})

local MissionDoorPositions =
{
    -- Security doors
    [1] = Vector3(-827.08, 115.886, 92.4429),
    [2] = Vector3(-60.1138, 802.08, 92.4429),
    [3] = Vector3(-140.886, -852.08, 92.4429)
}
local MissionDoorIndex =
{
    [1] = { w_id = 103191 },
    [2] = { w_id = 103188 },
    [3] = { w_id = 103202 }
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 25)
    end)
end
EHI:AddXPBreakdown({
    loot_all = { amount = 500, times = 9 },
    objective =
    {
        pc_hack = { amount = 6000, loud = true },
        escape = 2000
    }
})