--[[
-- SPDX-License-Identifier: LGPL-3.0
--
-- Handles transforming an STM structure to a structure the Template
-- class knows how to deal with.
--]]

local utils = require("libs.utils")

local categoryMap = {
	["HELICOPTER"] = 'HELICOPTER',
	["SHIP"]       = 'SHIP',
	["VEHICLE"]    = 'GROUND_UNIT',
	["PLANE"]      = 'AIRPLANE',
	["STATIC"]     = 'STRUCTURE',
}

local function convertNames(data, namefunc)
	data.name = namefunc(data.name)

	for _, unit in ipairs(data.units or {}) do
		unit.name = namefunc(unit.name)
	end

	if data.route then
		for _, waypoint in ipairs(data.route.points or {}) do
			waypoint.name = namefunc(waypoint.name)
		end
	end
end

local function modifyStatic(grpdata, _, dcscategory)
	if dcscategory ~= Unit.Category.STRUCTURE then
		return grpdata
	end
	local groupCopy = utils.deepcopy(grpdata.units[1])
	groupCopy.dead = grpdata.dead
	return groupCopy
end

local function processCategory(groupList, categoryTable, countryID, category, ops)
	if type(categoryTable) ~= 'table' or categoryTable.group == nil then
		return
	end
	for _, group in ipairs(categoryTable.group) do
		if ops.grpfilter == nil or
				ops.grpfilter(group, countryID, category) == true then
			if type(ops.grpmodify) == 'function' then
				group = ops.grpmodify(group, countryID, category)
			end
			local groupTable = {
				["data"]      = utils.deepcopy(group),
				["countryid"] = countryID,
				["category"]  = category,
			}
			convertNames(groupTable.data, ops.namefunc)
			table.insert(groupList, groupTable)
		end
	end
end


local STM = {}

-- return all groups matching `grpfilter` from `tbl`
-- grpfilter(grpdata, countryid, Unit.Category)
--   returns true if the filter matches and the group entry should be kept
-- grpmodify(grpdata, countryid, Unit.Category)
--   returns a copy of the group data modified as needed
-- always returns a table, even if it is empty
function STM.processCoalition(tbl, namefunc, grpfilter, grpmodify)
	assert(type(tbl) == 'table', "value error: `tbl` must be a table")
	assert(tbl.country ~= nil and type(tbl.country) == 'table',
		"value error: `tbl` must have a member `country` that is a table")

	local grplist = {}
	if namefunc == nil then
		namefunc = env.getValueDictByKey
	end
	local ops = {
		["namefunc"] = namefunc,
		["grpfilter"] = grpfilter,
		["grpmodify"] = grpmodify,
	}

	for _, cntrytbl in ipairs(tbl.country) do
		for cat, unitcat in pairs(categoryMap) do
			processCategory(grplist,
				cntrytbl[string.lower(cat)],
				cntrytbl.id,
				Unit.Category[unitcat],
				ops)
		end
	end
	return grplist
end

--[[
-- Convert STM data format
--    stm = {
--      coalition = {
--        red/blue = {
--          country = {
--            # = {
--              id = country id
--              category = {
--                group = {
--                  # = {
--                    groupdata
--    }}}}}}}}
--
-- to an internal, simplier, storage format
--
--    tpldata = {
--      [#] = {
--        category  = Unit.Category[STM_category],
--        countryid = id,
--        data      = {
--            # group definition
--            dct_deathgoal = goalspec
--    }}}
--]]

function STM.transform(stmData, file)
	local template             = {}
	local lookupname           = function(name)
		if name == nil then
			return nil
		end
		local newname = name
		local namelist = stmData.localization.DEFAULT
		if namelist[name] ~= nil then
			newname = namelist[name]
		end
		return newname
	end
	local trackUniqueCoalition = function(_, countryID, _)
		local side = coalition.getCountryCoalition(countryID)
		if template.coalition == nil then
			template.coalition = side
		end
		assert(template.coalition == side, string.format(
			"runtime error: invalid STM; country(%s) does not belong " ..
			"to '%s' coalition, country belongs to '%s' coalition; file: %s",
			country.name[countryID],
			tostring(utils.getkey(coalition.side, template.coalition)),
			tostring(utils.getkey(coalition.side, side)),
			file))
		return true
	end

	template.name              = lookupname(stmData.name)
	template.theater           = lookupname(stmData.theatre)
	template.desc              = lookupname(stmData.desc)
	template.tpldata           = {}

	for _, coa_data in pairs(stmData.coalition) do
		for _, grp in ipairs(STM.processCoalition(coa_data,
			lookupname,
			trackUniqueCoalition,
			modifyStatic)) do
			table.insert(template.tpldata, grp)
		end
	end
	return template
end

STM.categorymap = categoryMap
return STM
