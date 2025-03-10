--[[
-- SPDX-License-Identifier: LGPL-3.0
--
-- common utility functions
--]]

require("os")
require("math")
local check = require("libs.check")
local enum  = require("dct.enum")
local vector = require("dct.libs.vector")
local utils = {}

local enemymap = {
	[coalition.side.NEUTRAL] = false,
	[coalition.side.BLUE]    = coalition.side.RED,
	[coalition.side.RED]     = coalition.side.BLUE,
}

utils.INTELMAX = 5

function utils.getenemy(side)
	return enemymap[side]
end

function utils.isalive(grpname)
	local grp = Group.getByName(grpname)
	return (grp and grp:isExist() and grp:getSize() > 0)
end


function utils.interp(s, tab)
	return (s:gsub('(%b%%)', function(w) return tab[w:sub(2,-2)] or w end))
end

function utils.assettype2mission(assettype)
	for k, v in pairs(enum.missionTypeMap) do
		if v[assettype] then
			return k
		end
	end
	return nil
end

local airbase_id2name_map = nil
function utils.airbaseId2Name(id)
	if id == nil then
		return nil
	end
	if airbase_id2name_map == nil then
		airbase_id2name_map = {}
		for _, ab in pairs(world.getAirbases()) do
			airbase_id2name_map[tonumber(ab:getID())] = ab:getName()
		end
	end
	return airbase_id2name_map[id]
end

function utils.time(dcsabstime)
	-- timer.getAbsTime() returns local time of day, but we still need
	-- to calculate the day
	local time = os.time({
		["year"]  = env.mission.date.Year,
		["month"] = env.mission.date.Month,
		["day"]   = env.mission.date.Day,
		["hour"]  = 0,
		["min"]   = 0,
		["sec"]   = 0,
	})
	return time + dcsabstime
end

local offsettbl = {
	["Test Theater"] =  6*3600, -- simulate US Central TZ
	["PersianGulf"]  = -4*3600,
	["Nevada"]       =  8*3600,
	["Caucasus"]     = -4*3600,
	["Normandy"]     = -1*3600,
	["Syria"]        = -3*3600, -- EEST according to sunrise times
}

function utils.zulutime(abstime)
	local correction = offsettbl[env.mission.theatre] or 0
	return (utils.time(abstime) + correction)
end

function utils.centroid2D(point, pcentroid, n)
	if pcentroid == nil or n == nil then
		return vector.Vector2D(point), 1
	end

	local n1 = n + 1
	local p = vector.Vector2D(point)
	local pc = vector.Vector2D(pcentroid)
	local c = {}
	c.x = (p.x + (n * pc.x))/n1
	c.y = (p.y + (n * pc.y))/n1
	return vector.Vector2D(c), n1
end

-- returns a value guaranteed to be between min and max, inclusive.
function utils.clamp(x, min, max)
    return math.min(math.max(x, min), max)
end

-- add a random value between +/- sigma to val and return
function utils.addstddev(val, sigma)
    return val + math.random(-sigma, sigma)
end

utils.posfmt = {
	["DD"]   = 1,
	["DDM"]  = 2,
	["DMS"]  = 3,
	["MGRS"] = 4,
}

-- reduce the accuracy of the position to the precision specified
function utils.degradeLL(lat, long, precision)
	local multiplier = math.pow(10, precision)
	lat  = math.modf(lat * multiplier) / multiplier
	long = math.modf(long * multiplier) / multiplier
	return lat, long
end

-- set up formatting args for the LL string
local function getLLformatstr(precision, fmt)
	local decimals = precision
	if fmt == utils.posfmt.DDM then
		if precision > 1 then
			decimals = precision - 1
		else
			decimals = 0
		end
	elseif fmt == utils.posfmt.DMS then
		if precision > 4 then
			decimals = precision - 2
		elseif precision > 2 then
			decimals = precision - 3
		else
			decimals = 0
		end
	end
	if decimals == 0 then
		return "%02.0f"
	else
		return "%0"..(decimals+3).."."..decimals.."f"
	end
end

function utils.LLtostring(lat, long, precision, fmt)
	local northing = "N"
	local easting  = "E"
	local degsym   = '°'

	if lat < 0 then
		northing = "S"
	end

	if long < 0 then
		easting = "W"
	end

	lat, long = utils.degradeLL(lat, long, precision)
	lat  = math.abs(lat)
	long = math.abs(long)

	local fmtstr = getLLformatstr(precision, fmt)

	if fmt == utils.posfmt.DD then
		return string.format(fmtstr..degsym, lat)..northing..
			" "..
			string.format(fmtstr..degsym, long)..easting
	end

	-- we give the minutes and seconds a little push in case the division
	-- from the truncation with this multiplication gives us a value ending
	-- in .99999...
	local tolerance = 1e-8

	local latdeg   = math.floor(lat)
	local latmind  = (lat - latdeg)*60 + tolerance
	local longdeg  = math.floor(long)
	local longmind = (long - longdeg)*60 + tolerance

	if fmt == utils.posfmt.DDM then
		return string.format("%02d"..degsym..fmtstr.."'", latdeg, latmind)..
			northing..
			" "..
			string.format("%03d"..degsym..fmtstr.."'", longdeg, longmind)..
			easting
	end

	local latmin   = math.floor(latmind)
	local latsecd  = (latmind - latmin)*60 + tolerance
	local longmin  = math.floor(longmind)
	local longsecd = (longmind - longmin)*60 + tolerance

	return string.format("%02d"..degsym.."%02d'"..fmtstr.."\"",
			latdeg, latmin, latsecd)..
		northing..
		" "..
		string.format("%03d"..degsym.."%02d'"..fmtstr.."\"",
			longdeg, longmin, longsecd)..
		easting
end

function utils.MGRStostring(mgrs, precision)
	local str = mgrs.UTMZone .. " " .. mgrs.MGRSDigraph

	if precision == 0 then
		return str
	end

	local divisor = 10^(5-precision)
	local fmtstr  = "%0"..precision.."d"

	if precision == 0 then
		return str
	end

	return str.." "..string.format(fmtstr, (mgrs.Easting/divisor))..
		" "..string.format(fmtstr, (mgrs.Northing/divisor))
end

function utils.degrade_position(position, precision)
	local lat, long = coord.LOtoLL(position)
	lat, long = utils.degradeLL(lat, long, precision)
	return coord.LLtoLO(lat, long, 0)
end

function utils.fmtposition(position, precision, fmt)
	precision = math.floor(precision)
	assert(precision >= 0 and precision <= 5,
		"value error: precision range [0,5]")
	local lat, long = coord.LOtoLL(position)

	if fmt == utils.posfmt.MGRS then
		return utils.MGRStostring(coord.LLtoMGRS(lat, long),
			precision)
	end

	return utils.LLtostring(lat, long, precision, fmt)
end

function utils.trimTypeName(typename)
	if typename ~= nil then
		return string.match(typename, "[^.]-$")
	end
end

utils.buildevent = {}
function utils.buildevent.dead(obj)
	check.table(obj)
	local event = {}
	event.id = enum.event.DCT_EVENT_DEAD
	event.initiator = obj
	return event
end

function utils.buildevent.hit(asset, weapon)
	check.table(asset)
	check.table(weapon)
	local event = {}
	event.id = enum.event.DCT_EVENT_HIT
	event.initiator = asset
	event.weapon = weapon
	return event
end

function utils.buildevent.operational(base, state)
	check.table(base)
	check.bool(state)
	local event = {}
	event.id = enum.event.DCT_EVENT_OPERATIONAL
	event.initiator = base
	event.state = state
	return event
end

function utils.buildevent.impact(wpn)
	check.table(wpn)
	local event = {}
	event.id = enum.event.DCT_EVENT_IMPACT
	event.initiator = wpn
	event.point = wpn:getImpactPoint()
	return event
end

function utils.buildevent.addasset(asset)
	check.table(asset)
	local event = {}
	event.id = enum.event.DCT_EVENT_ADD_ASSET
	event.initiator = asset
	return event
end

return utils
