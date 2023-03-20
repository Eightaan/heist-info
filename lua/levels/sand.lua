local Color = Color
EHIsand11Tracker = class(EHIAchievementProgressTracker)
EHIsand11Tracker._forced_icons = EHI:GetAchievementIcon("sand_11")
EHIsand11Tracker.FormatChance = EHIChanceTracker.Format
function EHIsand11Tracker:init(panel, params)
    params.max = 100
    params.remove_after_reaching_target = false
    params.no_failure = true
    self._chance = 0
    EHIsand11Tracker.super.init(self, panel, params)
end

function EHIsand11Tracker:OverridePanel()
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._text_chance = self._time_bg_box:text({
        name = "chance",
        text = self:FormatChance(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self._text_chance:set_right(self._time_bg_box:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIsand11Tracker:SetChance(amount)
    self._chance = amount
    self._text_chance:set_text(self:FormatChance())
    if amount >= 100 then
        self._text_chance:set_color(Color.green)
    else
        self._text_chance:set_color(Color.white)
    end
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local boat_anim = 614/30 + 12 + 1
local skid = { { icon = Icon.Car, color = Color("1E90FF") } }
local triggers = {
    [EHI:GetInstanceElementID(100045, 7100)] = { time = 5, id = "RoomHack", icons = { Icon.PCHack } },

    [EHI:GetInstanceElementID(100043, 4800)] = { special_function = SF.Trigger, data = { 1000431, 1000432 } },
    [1000431] = { time = 15, id = "DoorOpenGas", icons = { "pd2_door" } },
    [1000432] = { time = 20, random_time = 5, id = "RoomGas", icons = { Icon.Teargas } },

    [103333] = { time = 613/30, id = "SkidDriving2", icons = skid },
    [103178] = { time = 386/30, id = "SkidDriving3", icons = skid },
    [104043] = { time = 28, id = "SkidDriving4", icons = skid }, -- More accurate
    [104101] = { time = 7, id = "SkidDriving5", icons = skid }, -- 100704; More accurate
    [104102] = { time = 477/30, id = "SkidDriving6", icons = skid },
    [104233] = { time = 30, id = "SkidDriving7", icons = skid }, -- More accurate
    [104262] = { time = 549/30, id = "SkidDriving8", icons = skid },
    [104304] = { time = 40, id = "SkidDriving9", icons = skid }, -- More accurate
    [103667] = { time = 1399/30, id = "SkidDriving10", icons = skid },
    [100782] = { time = 18, id = "SkidDriving11", icons = skid }, -- More accurate
    [104227] = { time = 37, id = "SkidDriving12", icons = skid }, -- More accurate
    [104305] = { time = 25, id = "SkidDriving13", icons = skid }, -- More accurate
    [101009] = { time = 210/30, id = "RampRaise", icons = { Icon.Wait } },
    [101799] = { time = 181/30, id = "RampLower", icons = { Icon.Wait } },

    [104528] = { time = 22, id = "Crane", icons = { Icon.Winch } }, -- 104528 -> 100703

    [103870] = { chance = 34, id = "ReviveVlad", icons = { "equipment_defibrillator" }, class = TT.Chance, special_function = SF.AddTrackerIfDoesNotExist },
    [103871] = { id = "ReviveVlad", special_function = SF.RemoveTracker },

    [103925] = { id = "BoatEscape", icons = Icon.BoatEscape, special_function = SF.SetTimeIfLoudOrStealth, data = { yes = 30 + boat_anim, no = 19 + boat_anim } }
}
local KeypadResetTimer = EHI:GetKeypadResetTimer()
for _, index in ipairs({ 8530, 9180, 9680 }) do
    local unit_id = EHI:GetInstanceUnitID(100279, index)
    triggers[EHI:GetInstanceElementID(100176, index)] = { time = 30, id = "KeypadRebootECM", icons = { Icon.Loop }, waypoint = { position_by_unit = unit_id }, special_function = SF.SetTimeOrCreateTracker } -- ECM Jammer
    triggers[EHI:GetInstanceElementID(100210, index)] = { time = 3 + KeypadResetTimer, id = "KeypadReboot", icons = { Icon.Loop }, waypoint = { position_by_unit = unit_id } }
end
for i = 16580, 16780, 100 do
    triggers[EHI:GetInstanceElementID(100057, i)] = { id = "ReviveVlad", special_function = SF.IncreaseChanceFromElement } -- +33%
end

local DisableWaypoints =
{
    -- sand_chinese_computer_hackable
    [EHI:GetInstanceElementID(100018, 15680)] = true, -- Defend
    -- Interact is in CoreWorldInstanceManager.lua
    -- sand_server_hack
    -- levels/instances/unique/sand/sand_server_hack/001 is used, others are not
    [EHI:GetInstanceElementID(100018, 14280)] = true, -- Fix
    -- Interact is in CoreWorldInstanceManager.lua
    -- sand_defibrillator
    [EHI:GetInstanceElementID(100051, 16580)] = true, -- Wait
    [EHI:GetInstanceElementID(100051, 16680)] = true, -- Wait
    [EHI:GetInstanceElementID(100051, 16780)] = true -- Wait
}

local achievements =
{
    sand_9 =
    {
        elements =
        {
            [EHI:GetInstanceElementID(100024, 31755)] = { special_function = SF.Trigger, data = { 1, 2 } },
            [1] = { max = 10, remove_after_reaching_target = false, class = TT.AchievementProgress, special_function = SF.ShowAchievementFromStart },
            [2] = { special_function = SF.CustomCode, f = function()
                if managers.ehi:TrackerDoesNotExist("sand_9") then
                    return
                end
                -- Counter is bugged. Teaset is counted too.
                -- Reported in:
                -- https://steamcommunity.com/app/218620/discussions/14/3182363463067457019/
                EHI:AddAchievementToCounter({
                    achievement = "sand_9"
                })
                managers.ehi:SetTrackerProgress("sand_9", managers.loot:GetSecuredBagsAmount())
            end },
            [103208] = { special_function = SF.FinalizeAchievement }
        }
    },
    sand_10 =
    {
        elements =
        {
            [100107] = { max = 8, class = TT.AchievementProgress },
        }
    }
}
for i = 105290, 105329, 1 do
    achievements.sand_10.elements[i] = { special_function = SF.IncreaseProgress }
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 60 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    --levels/instances/unique/sand/sand_computer_hackable
    --units/pd2_dlc_sand/equipment/sand_interactable_hack_computer/sand_interactable_hack_computer
    [EHI:GetInstanceUnitID(100140, 18680)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100034, 18680) },

    --levels/instances/unique/sand/sand_swat_van_drillable
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small_no_jam
    [EHI:GetInstanceUnitID(100022, 15380)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100023, 15380) },

    --levels/instances/unique/sand/sand_computer_code_display
    --units/pd2_dlc_sand/equipment/sand_interactable_rotating_code_computer/sand_interactable_rotating_code_computer
    [EHI:GetInstanceUnitID(100150, 9030)] = { remove_on_pause = true, remove_on_alarm = true },

    --levels/instances/unique/sand/sand_server_hack
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceUnitID(100037, 14280)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100017, 14280) },

    --levels/instances/unique/sand/sand_chinese_computer_hackable
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceUnitID(100037, 15680)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100017, 15680) },

    --levels/instances/unique/sand/sand_defibrillator
    --units/pd2_dlc_sand/equipment/sand_interactable_defibrillator/sand_interactable_defibrillator
    [EHI:GetInstanceUnitID(100009, 16580)] = { icons = { Icon.Power } },
    [EHI:GetInstanceUnitID(100009, 16680)] = { icons = { Icon.Power } },
    [EHI:GetInstanceUnitID(100009, 16780)] = { icons = { Icon.Power } }
}
if EHI:GetOption("show_waypoints") then
    local function f(id, unit_data, unit)
        local trigger_id = unit_data.trigger_id
        EHI:AddWaypointToTrigger(trigger_id, { unit = unit })
        unit:unit_data():add_destroy_listener("EHIDestroy", function(...)
            managers.ehi_waypoint:RemoveWaypoint(triggers[trigger_id].id)
        end)
    end
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/002
    tbl[104456] = { f = f, trigger_id = 103333 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/003
    tbl[104457] = { f = f, trigger_id = 103178 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/004
    tbl[104458] = { f = f, trigger_id = 104043 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/005
    tbl[104459] = { f = f, trigger_id = 104101 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/006
    tbl[104460] = { f = f, trigger_id = 104102 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/007
    tbl[104461] = { f = f, trigger_id = 104233 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/008
    tbl[104462] = { f = f, trigger_id = 104262 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/009
    tbl[104463] = { f = f, trigger_id = 104304 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/010
    tbl[104464] = { f = f, trigger_id = 103667 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/011
    tbl[104465] = { f = f, trigger_id = 100782 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/012
    tbl[104467] = { f = f, trigger_id = 104227 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/013
    tbl[104308] = { f = f, trigger_id = 104305 }
end
EHI:UpdateUnits(tbl)