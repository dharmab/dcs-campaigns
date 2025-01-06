-- This script sets up the MOOSE A2A Dispatcher to manage RED air interception
-- of BLUE aircraft.
-- ref: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html

-- Add all groups named with the prefixes "AEW", "EWR" and "SAM" to a set which
-- will be used as an Early Warning network.
-- AEW must be used for Airborne Early Warning aircraft
-- EWR must be used for Early Warning Radars
-- SAM must be used for Surface to Air Missile systems
DetectionSetGroup = SET_GROUP:New()
DetectionSetGroup:FilterPrefixes( { "AEW", "EWR", "SAM" } )
DetectionSetGroup:FilterStart()
-- 30km detection grouping is recommended by MOOSE documentation for modern jet
-- aircraft
Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )
A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )
-- The engage radius is the distance from BLUE aircraft within which RED
-- aircraft will engage the BLUE aircraft.
-- 100km is the default engage radius, but this might need tuning. Tune down if
-- interceptors cannot reach targets in time. Tune upwards if too many
-- interceptors are being dispatched to intercept targets.
A2ADIspatcher:SetEngageRadius( 100000 )
-- The GCI radius is the distance from RED airbases within which BLUE aircraft
-- will trigger interception by RED aircraft.
-- 200km is the default GCI radius. Tune this to match the map design.
A2ADispatcher:SetGciRadius( 200000 )

local templateKey = "template" -- Prefix for the aircraft template
local overheadKey = "overhead" -- Balancing factor, how many RED aircraft to spawn per BLUE aircraft

local iberiaMiG21 = {
	templateKey = "Iberian MiG-21",
	overheadKey = 1 ,
}
local iberianF1 = {
	templateKey = "Iberian F1",
	overheadKey = 1,
}
local iberianMiG23 = {
	templateKey = "Iberian MiG-23",
	overheadKey = 1,
}
local fedSu27 = {
	templateKey = "Federation Su-27",
	overheadKey = 1,
}
local fedMiG29 = {
	templateKey = "Federation MiG-29",
	overheadKey = 1,
}

-- Assign aircraft to RED airbases
local iberianAircraft = {iberiaMiG21, iberianMiG23, iberianF1}
local federationAircraft = {fedSu27, fedMiG29}
local airbases = {
	AIRBASE.Senaki_Kolkhi = iberianAircraft,
	AIRBASE.Caucasus.Kobuleti = iberianAircraft,
	AIRBASE.Caucasus.Kutaisi = iberianAircraft,
	AIRBASE.Caucasus.Maykop_Khanskaya = federationAircraft,
	AIRBASE.Caucasus.Vaziani = federationAircraft,
}
for airbase, aircraft in pairs(airbases) do
	for _, data in ipairs(aircraft) do
		squadron = airbase .. " " .. aircraftType
		A2ADispatcher:SetSquadron( squadron, airbase, { data[template] } )
		A2ADispatcher:SetSquadronGci(squadron, 600, 900)
		A2ADispatcher:SetSquadronOverhead(squadron, data[overheadKey])
	end
end

-- Default all squadrons to spawn and despawn on the runway. This is the most
-- reliable choice other than air start since it avoids problems with the AI
-- getting stuck while taxiiing.
A2ADispatcher:SetDefaultTakeoffFromRunway()
A2ADispatcher:SetDefaultLandingAtRunway()

-- AI aircraft will RTB after 10% damanged (90% health remaining).
A2ADispatcher:SetDefaultDamageThreshold(0.10)
