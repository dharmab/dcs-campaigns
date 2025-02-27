-- This script sets up the MOOSE A2A Dispatcher to manage RED air interception
-- of BLUE aircraft.
-- ref: https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html

-- Convenience values to make units more readable
local meter = 1
local kilometer = 1000 * meter
local second = 1
local minute = 60 * second

-- Add all groups named with the prefixes "AEW", "EWR" and "SAM" to a set which
-- will be used as an Early Warning network.
-- AEW must be used for Airborne Early Warning aircraft
-- EWR must be used for Early Warning Radars
-- SAM must be used for Surface to Air Missile systems
local regions = {
	"Alania",
	"Apsilia",
	"Batumi",
	"Beslan",
	"BlackSea",
	"GaliZugdidi",
	"Gudauta",
	"KashuriGori",
	"Kobuleti",
	"Kutaisi",
	"MineralnyeVody",
	"Mozdok",
	"Nalchik",
	"Poti",
	"Sukhumi",
	"Tbilisi",
}

local group_prefixes = { "AEW" }
for _, region in ipairs(regions) do
	for _, prefix in ipairs({ "EWR", "SAM" }) do
		table.insert(group_prefixes, region .. "_" .. prefix)
	end
end

-- Create a new set of groups
Detectors = SET_GROUP:New()
-- Dynamically add all units with the specified prefixes to the set
Detectors:FilterPrefixes(group_prefixes)
-- FilterStart will dynamically update the set as air defense groups are (de)spawned
Detectors:FilterStart()

-- Units which are closer to the first detected unit than the radius will be collected
-- into a single target to intercept
local groupRadius = 11 * kilometer
Detections = DETECTION_AREAS:New(Detectors, groupRadius)

-- Create an A2A dispatcher which will spawn aircraft in response to detected aircraft
Dispatcher = AI_A2A_DISPATCHER:New(Detections)

-- Intercept delay is how long it takes for an aircraft to be scrambled after a detection
local interceptDelay = 3 * minute
Dispatcher:SetIntercept(interceptDelay)

-- Overhead controls how many aircraft are spawned in response to a detection
local scalingFactor = math.sqrt(2)
Dispatcher:SetDefaultOverhead(scalingFactor)

-- Default all squadrons to spawn and despawn on the runway. This is the most
-- reliable choice other than air start since it avoids problems with the AI
-- getting stuck during taxi.
Dispatcher:SetDefaultTakeoffFromRunway()
Dispatcher:SetDefaultLandingAtRunway()

-- AI aircraft will RTB after 10% damaged (90% health remaining).
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
-- Aircraft here correspond to group names of Late Activation groups in the MIZ file
local factions = {
	["Iberian"] = {
		["airbases"] = {
			AIRBASE.Caucasus.Senaki_Kolkhi,
			AIRBASE.Caucasus.Kobuleti,
			AIRBASE.Caucasus.Kutaisi,
		},
		["aircraft"] = {
			"Iberian MiG-21 Medium Range",
			"Iberian MiG-21 Long Range",
			"Iberian MiG-23"
		}
	},
	["Federation"] = {
		["airbases"] = {
			AIRBASE.Caucasus.Mozdok,
			AIRBASE.Caucasus.Vaziani,
		},
		["aircraft"] = {
			"Federation MiG-29",
			"Federation J-11"
		}
	},
}
for faction, assignments in pairs(factions) do
	for _, airbase in ipairs(assignments.airbases) do
		local squadron = faction .. " " .. airbase
		Dispatcher:SetSquadron(squadron, airbase, assignments.aircraft)
		Dispatcher:SetSquadronGci(squadron, minInterceptSpeed, maxInterceptSpeed)
	end
end
Dispatcher:Start()
