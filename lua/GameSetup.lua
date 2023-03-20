local EHI = EHI
if EHI:CheckLoadHook("GameSetup") then
    return
end

local redirect =
{
    branchbank = "firestarter_3",
    branchbank_gold = "firestarter_3",
    branchbank_cash = "firestarter_3",
    branchbank_deposit = "firestarter_3",
    watchdogs_1_night = "watchdogs_1",
    watchdogs_2_day = "watchdogs_2",
    welcome_to_the_jungle_1_night = "welcome_to_the_jungle_1",
    election_day_3_skip1 = "election_day_3",
    election_day_3_skip2 = "election_day_3",
    escape_cafe_day = "escape_cafe",
    escape_overpass_night = "escape_overpass",
    escape_park_day = "escape_park",
    gallery = "framing_frame_1",
    crojob3_night = "crojob3",
    -- Custom Missions
    ratdaylight = "levels/rat"
}

local levels =
{
    -- Tutorial
    short2_stage2b = true, -- Basic Mission: Loud - Plan B
    -- Escapes
    escape_cafe = true, -- Escape: Cafe
    escape_cafe_day = true, -- Escape: Cafe (Day)
    escape_overpass = true, -- Escape: Overpass; Appears to be unused
    escape_overpass_night = true, -- Escape: Overpass (Night)
    escape_park = true, -- Escape: Park
    escape_park_day = true, -- Escape: Park (Day)
    escape_street = true, -- Escape: Street
    escape_garage = true, -- Escape: Garage
    -- Chapter 1: Just getting started
    jewelry_store = true, -- Jewelry Store
    branchbank = true, -- Branchbank: Random
    branchbank_gold = true, -- Branchbank: Gold
    branchbank_cash = true, -- Branchbank: Cash
    branchbank_deposit = true, -- Branchbank: Deposit
    kosugi = true, -- Shadow Raid
    roberts = true, -- GO Bank
    family = true, -- Diamond Store
    arm_cro = true, -- Transport: Crossroads
    arm_fac = true, -- Transport: Harbor
    arm_hcm = true, -- Transport: Downtown
    arm_par = true, -- Transport: Park
    arm_und = true, -- Transport: Underpass
    arm_for = true, -- Transport: Train Heist
    mallcrasher = true, -- Mallcrasher
    four_stores = true, -- Four Stores
    pines = true, -- White Xmas; missing wps
    ukrainian_job = true, -- Ukrainian Job
    shoutout_raid = true, -- Meltdown
    jolly = true, -- Aftershock
    nightclub = true, -- Nightclub
    moon = true, -- Stealing Xmas
    watchdogs_1 = true, -- Watchdogs Day 1
    watchdogs_1_night = true, -- Watchdogs Day 1 (Night)
    watchdogs_2_day = true, -- Watchdogs Day 2 (Day)
    watchdogs_2 = true, -- Watchdogs Day 2
    firestarter_1 = true, -- Firestarter Day 1
    firestarter_2 = true, -- Firestarter Day 2
    firestarter_3 = true, -- Firestarter Day 3
    alex_1 = true, -- Rats Day 1
    alex_2 = true, -- Rats Day 2
    alex_3 = true, -- Rats Day 3
    -- Chapter 2: The Kings of CrimeNet
    welcome_to_the_jungle_1 = true, -- Big Oil Day 1
    welcome_to_the_jungle_1_night = true, -- Big Oil Day 1 (Night)
    welcome_to_the_jungle_2 = true, -- Big Oil Day 2
    framing_frame_1 = true, -- Framing Frame Day 1
    framing_frame_2 = true, -- Framing Frame Day 2
    framing_frame_3 = true, -- Framing Frame Day 3; PC Hack waypoint; removal needed
    election_day_1 = true, -- Election Day D1
    election_day_2 = true, -- Election Day D2 Plan A/B
    election_day_3 = true, -- Election Day D2 Plan C
    election_day_3_skip1 = true,
    election_day_3_skip2 = true,
    big = true, -- Big Bank
    mia_1 = true, -- Hotline Miami Day 1
    mia_2 = true, -- Hotline Miami Day 2
    hox_1 = true, -- Hoxton Breakout Day 1
    hox_2 = true, -- Hoxton Breakout Day 2
    hox_3 = true, -- Hoxton Revenge
    mus = true, -- The Diamond
    arena = true, -- The Alesso Heist
    kenaz = true, -- Golden Grin Casino
    gallery = true, -- Art Gallery
    crojob2 = true, -- The Bomb: Dockyard
    crojob3 = true, -- The Bomb: Forest
    crojob3_night = true, -- The Bomb: Forest (Night)
    friend = true, -- Scarface Mansion
    pal = true, -- Counterfeit
    red2 = true, -- First World Bank
    rat = true, -- Cook Off
    dark = true, -- Murky Station
    mad = true, -- Boiling Point
    peta = true, -- Goat Simulator Heist Day 1
    peta2 = true, -- Goat Simulator Heist Day 2
    cane = true, -- Santa's Workshop
    -- Chapter 3: Endgame
    cage = true, -- Car Shop
    born = true, -- The Biker Heist Day 1
    chew = true, -- The Biker Heist Day 2
    chill = true, -- Safehouse (New)
    chill_combat = true, -- Safehouse Raid
    flat = true, -- Panic Room
    help = true, -- Prison Nightmare
    spa = true, -- Brooklyn 10-10
    fish = true, -- The Yacht Heist
    man = true, -- Undercover
    dinner = true, -- Slaughterhouse
    nail = true, -- Lab Rats
    pbr = true, -- Beneath the Mountain
    pbr2 = true, -- Birth of Sky
    run = true, -- Heat Street
    glace = true, -- Green Bridge
    wwh = true, -- Alaskan Deal
    dah = true, -- Diamond Heist
    hvh = true, -- Cursed Kill Room
    rvd1 = true, -- Reservoir Dogs Heist Day 2; Add escape car wps
    rvd2 = true, -- Reservoir Dogs Heist Day 1
    brb = true, -- Brooklyn Bank
    tag = true, -- Breakin' Feds
    des = true, -- Henry's Rock
    sah = true, -- Shacklethorne Auction
    bph = true, -- Hell's Island
    nmh = true, -- No Mercy
    vit = true, -- The White House; Oval office Drill wp, PEOC PC wp + Firewall PC wp
    -- Silkroad campaign
    mex = true, -- Border Crossing
    mex_cooking = true, -- Border Crystals
    bex = true, -- San Martín Bank; Add "Silencioso y Codicioso" achievement
    pex = true, -- Breakfast in Tijuana
    fex = true, -- Buluc's Mansion
    -- City of Gold campaign
    chas = true, -- Dragon Heist
    sand = true, -- Ukrainian Prisoner Heist
    chca = true, -- Black Cat Heist
    pent = true, -- Mountain Master Heist
    -- Texas Heat campaign
    ranc = true, -- Midland Ranch
    trai = true, -- Lost in Transit
    corp = true, -- Hostile Takeover
    fourth_and_last_heist_of_the_Texas_Heat_campaign = true
}

local custom_levels =
{
    ratdaylight = true, -- Rats (Daylight)
    ["Triad Takedown Yacht Heist"] = true, -- Triad Takedown Yacht Heist; Saw defend wp; needs removal
    ttr_yct_lvl = true, -- Triad Takedown Remastered Custom Heist; Hack PC wp; needs removal
    ruswl = true, -- Scorched Earth Custom Heist
    rusdl = true, -- Cold Stones Custom Heist
    crimepunishlvl = true, -- Crime and Punishment Custom Heist; Drill wps + C4 wp; needs removal
    RogueCompany = true, -- Yaeger - Rogue Company Custom Heist
    hunter_party = true, -- Hunter and Hunted (Party) Day 1
    hunter_departure = true, -- Hunter and Hunted (Departure) Day 2
    hunter_fall = true, -- Hunter and Hunted (Fall) Day 3
    constantine_harbor_lvl = true, -- Harboring a Grudge
    --lit1 = true, -- California Heat
    --lit2 = true, -- California Heat (Bonus Mission)
    -- Constantine Scores
    constantine_smackdown_lvl = true, -- Smackdown
    constantine_smackdown2_lvl = true, -- Truck Hustle
    constantine_ondisplay_lvl = true, -- On Display
    constantine_apartment_lvl = true, -- Concrete Jungle
    --[[Smugglers Den (Loud and Stealth)
    Aurora Club (Loud and Stealth)]]
    constantine_butcher_lvl = true, -- Butchers Bay
    constantine_policestation_lvl = true, -- Precinct Raid
    --[[Kozlov Mansion (Loud and Stealth)
    Blood in the Water (Loud and Stealth)
    Gunrunners Clubhouse (Loud Only)
    In the Crosshairs (Stealth Only)
    Murky Airpot (Loud Only)
    Scarlett Resort (Loud and Stealth)
    Penthouse Crasher (Loud Only)
    Golden Shakedown (Loud and Stealth)
    ]]
    --Tonis2 = true, -- Triple Threat
    --dwn1 = true -- Deep Inside
    street_new = true, -- Heat Street Rework (Heat Street True Classic in-game)
    office_strike = true,
    tonmapjam22l = true -- Hard Cash
}

local init_finalize = GameSetup.init_finalize
function GameSetup:init_finalize(...)
    init_finalize(self, ...)
    EHI:CallCallback(EHI.CallbackMessage.InitFinalize)
    local level_id = Global.game_settings.level_id
    if levels[level_id] then
        local fixed_name = redirect[level_id] or level_id
        dofile(EHI.LuaPath .. "levels/" .. fixed_name .. ".lua")
    end
    if custom_levels[level_id] then
        local fixed_path = redirect[level_id] or ("custom_levels/" .. level_id)
        dofile(EHI.LuaPath .. fixed_path .. ".lua")
    end
    EHI:InitElements()
    EHI:DisableWaypointsOnInit()
end

EHI:PreHookWithID(GameSetup, "load", "EHI_GameSetup_load_Pre", function(...)
    EHI:FinalizeUnitsClient()
end)

EHI:HookWithID(GameSetup, "load", "EHI_GameSetup_load_Post", function(...)
    managers.ehi:LoadSync()
    EHI:SyncLoad()
end)