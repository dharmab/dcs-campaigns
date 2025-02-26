-- This script sets up the MOOSE A2A Dispatcher to manage RED air interception
-- of BLUE aircraft.
-- ref: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html

local meter = 1
local kilometer = 1000 * meter
local second = 1

-- Add all groups named with the prefixes "AEW", "EWR" and "SAM" to a set which
-- will be used as an Early Warning network.
-- AEW must be used for Airborne Early Warning aircraft
-- EWR must be used for Early Warning Radars
-- SAM must be used for Surface to Air Missile systems
local regions = {
	["Alania"] = true,
	["Apsilia"] = true,
	["Batumi"] = true,
	["Beslan"] = true,
	["BlackSea"] = true,
	["GaliZugdidi"] = true,
	["Gudauta"] = true,
	["KashuriGori"] = true,
	["Kobuleti"] = true,
	["Kutaisi"] = true,
	["MineralnyeVody"] = true,
	["Mozdok"] = true,
	["Nalchik"] = true,
	["Poti"] = true,
	["Sukhumi"] = true,
	["Tbilisi"] = true,
}

local group_prefixes = { "AEW" }
for region, _ in pairs(regions) do
	table.insert(group_prefixes, region .. "_SAM")
	table.insert(group_prefixes, region .. "_EWR")
end

-- Create a new set of groups
Detectors = SET_GROUP:New()
-- Dynamically add all units with the specified prefixes to the set
Detectors:FilterPrefixes(group_prefixes)
-- FilterStart will dynamically update the set as air defense groups are (de)spawned
Detectors:FilterStart()

-- units which are closer to the first detected unit than the radius will be collected
-- into a single target to intercept
local groupRadius = 11 * kilometer
Detections = DETECTION_AREAS:New(Detectors, groupRadius)

-- Create an A2A dispatcher which will spawn aircraft in response to detected aircraft
Dispatcher = AI_A2A_DISPATCHER:New(Detections)
Dispatcher:SetIntercept(5 * second)

-- Default all squadrons to spawn and despawn on the runway. This is the most
-- reliable choice other than air start since it avoids problems with the AI
-- getting stuck while taxiiing.
Dispatcher:SetDefaultTakeoffFromRunway()
Dispatcher:SetDefaultLandingAtRunway()

-- AI aircraft will RTB after 10% damanged (90% health remaining).
Dispatcher:SetDefaultDamageThreshold(0.10)

-- The engage radius is the distance from BLUE aircraft within which RED
-- aircraft will engage the BLUE aircraft.
-- 100km is the default engage radius, but this might need tuning. Tune down if
-- interceptors cannot reach targets in time. Tune upwards if too many
-- interceptors are being dispatched to intercept targets.
Dispatcher:SetEngageRadius(100 * kilometer)
-- The GCI radius is the distance from RED airbases within which BLUE aircraft
-- will trigger interception by RED aircraft.
-- 200km is the default GCI radius. Tune this to match the map design.
Dispatcher:SetGciRadius(200 * kilometer)

local minInterceptSpeed = 600 * (meter / second)
local maxInterceptSpeed = 1800 * (meter / second)

-- Assign aircraft to RED airbases
local iberianAirbases = {
	[AIRBASE.Caucasus.Senaki_Kolkhi] = true,
	[AIRBASE.Caucasus.Kobuleti] = true,
	[AIRBASE.Caucasus.Kutaisi] = true,
}
local iberianAircraft = { "Iberian MiG-21", "Iberian MiG-23", "Iberian F1" }
local federationAirbases = {
	[AIRBASE.Caucasus.Mozdok] = true,
	[AIRBASE.Caucasus.Vaziani] = true,
}
local federationAircraft = { "Federation MiG-29", "Federation Su-27" }
local factions = {
	["Iberian"] = { airbases = iberianAirbases, aircraft = iberianAircraft },
	["Federation"] = { airbases = federationAirbases, aircraft = federationAircraft },
}
for faction, data in pairs(factions) do
	local airbases = data.airbases
	local aircraft = data.aircraft
	for airbase, _ in pairs(airbases) do
		local squadron = faction .. " " .. airbase
		for _, platform in ipairs(aircraft) do
			Dispatcher:SetSquadron(squadron, airbase, { platform })
			Dispatcher:SetSquadronGci(squadron, minInterceptSpeed, maxInterceptSpeed)
		end
	end
end
Dispatcher:Start()
