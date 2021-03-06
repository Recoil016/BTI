env.info("[BTI] A2A Dispatcher: Starting the mastermind dispatcher")

-- RedBorderZone = ZONE_POLYGON:New( "RED Border", GROUP:FindByName( "RED BorderZone" ) )
RedCapZone = ZONE_POLYGON:New( "RED Patrol", GROUP:FindByName("RED Patrol"))
env.info("[BTI] A2A Dispatcher: Zone Poly ready")


REDEWR = SET_GROUP:New()
REDEWR:FilterPrefixes( { "RED EWR" } )
REDEWR:FilterStart()
env.info("[BTI] A2A Dispatcher: EWR ready")

-- Setup the detection and group targets to a 30km range!
EWR = DETECTION_AREAS:New( REDEWR, 28000 ):SetRefreshTimeInterval( 70 )
env.info("[BTI] A2A Dispatcher: Detection ready")

-- Setup the A2A dispatcher, and initialize it.
A2ADispatcher = AI_A2A_DISPATCHER:New( EWR )
A2ADispatcher:SetEngageRadius( 50000 )
A2ADispatcher:SetGciRadius( 100000 )
A2ADispatcher:SetIntercept(120)
-- A2ADispatcher:SetTacticalDisplay( true )
-- A2ADispatcher:SetBorderZone( RedBorderZone )
env.info("[BTI] A2A Dispatcher: Dispatcher created")

-- Set Defaults
A2ADispatcher:SetDefaultGrouping(1)
A2ADispatcher:SetDefaultOverhead(1)
A2ADispatcher:SetDefaultFuelThreshold(0.25)
A2ADispatcher:SetDefaultTanker("RED Tanker")
A2ADispatcher:SetDefaultDamageThreshold(0.4)
A2ADispatcher:SetDisengageRadius(130000)
env.info("[BTI] A2A Dispatcher: Defaults set")

--Set Squadrons
-- BandarAbbasSquadron = "Bandar Abbas Squadron"
-- A2ADispatcher:SetSquadron( BandarAbbasSquadron , "Bandar Abbas Intl", { "RED Mig23" }, 15 )
-- A2ADispatcher:SetSquadronGci(BandarAbbasSquadron, 800, 1800)
-- A2ADispatcher:SetSquadronCap( BandarAbbasSquadron, RedCapZone, 4000, 8000, 600, 800, 800, 1200, "BARO" )
-- A2ADispatcher:SetSquadronCapInterval( BandarAbbasSquadron, 1, 30, 120, 1 )


-- LarSquadron = "Ta race"
-- A2ADispatcher:SetSquadron( LarSquadron, "Kerman Airport", { "RED F14" }, 14 )
-- A2ADispatcher:SetSquadronGci( LarSquadron, 800, 1800)

-- Blabla = "Lar Squadron"
-- A2ADispatcher:SetSquadron( Blabla, "Shiraz International Airport", { "RED J11" }, 8 )
-- A2ADispatcher:SetSquadronGci( Blabla, 800, 1800)

-- HavadaryaSquadron = "Havada"
-- A2ADispatcher:SetSquadron( HavadaryaSquadron, "Lar Airbase", { "RED Mig21" }, 4 )
-- A2ADispatcher:SetSquadronGci( HavadaryaSquadron, 400, 800)


env.info("[BTI] A2A Dispatcher: Squadrons ready")


-- AIRBASE.PersianGulf.Fujairah_Intl
-- AIRBASE.PersianGulf.Qeshm_Island
-- AIRBASE.PersianGulf.Sir_Abu_Nuayr
-- AIRBASE.PersianGulf.Abu_Musa_Island_Airport
-- AIRBASE.PersianGulf.Bandar_Abbas_Intl
-- AIRBASE.PersianGulf.Bandar_Lengeh
-- AIRBASE.PersianGulf.Tunb_Island_AFB
-- AIRBASE.PersianGulf.Havadarya
-- AIRBASE.PersianGulf.Lar_Airbase
-- AIRBASE.PersianGulf.Sirri_Island
-- AIRBASE.PersianGulf.Tunb_Kochak
-- AIRBASE.PersianGulf.Al_Dhafra_AB
-- AIRBASE.PersianGulf.Dubai_Intl
-- AIRBASE.PersianGulf.Al_Maktoum_Intl
-- AIRBASE.PersianGulf.Khasab
-- AIRBASE.PersianGulf.Al_Minhad_AB
-- AIRBASE.PersianGulf.Sharjah_Intl
-- 
-- AIRBASE.PersianGulf = {
--     ["Fujairah_Intl"] = "Fujairah Intl",
--     ["Qeshm_Island"] = "Qeshm Island",
--     ["Sir_Abu_Nuayr"] = "Sir Abu Nuayr",
--     ["Abu_Musa_Island_Airport"] = "Abu Musa Island Airport",
--     ["Bandar_Abbas_Intl"] = "Bandar Abbas Intl",
--     ["Bandar_Lengeh"] = "Bandar Lengeh",
--     ["Tunb_Island_AFB"] = "Tunb Island AFB",
--     ["Havadarya"] = "Havadarya",
--     ["Lar_Airbase"] = "Lar Airbase",
--     ["Sirri_Island"] = "Sirri Island",
--     ["Tunb_Kochak"] = "Tunb Kochak",
--     ["Al_Dhafra_AB"] = "Al Dhafra AB",
--     ["Dubai_Intl"] = "Dubai Intl",
--     ["Al_Maktoum_Intl"] = "Al Maktoum Intl",
--     ["Khasab"] = "Khasab",
--     ["Al_Minhad_AB"] = "Al Minhad AB",
--     ["Sharjah_Intl"] = "Sharjah Intl",
--    }