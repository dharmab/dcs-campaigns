
-- SPDX-License-Identifier: LGPL-3.0

local utils = {}

function utils.getkey(tbl, val)
	for k, v in pairs(tbl) do
		if v == val then
			return k
		end
	end
	return nil
end

function utils.foreach(ctx, itr, fcn, array, ...)
	for k, v in itr(array) do
		fcn(ctx, k, v, unpack({select(1, ...)}))
	end
end

function utils.shallowclone(obj)
	local obj_type = type(obj)
	local copy

	if obj_type == 'table' then
		copy = {}
		for k,v in pairs(obj) do
			copy[k] = v
		end
	else
		copy = obj
	end
	return copy
end

function utils.deepcopy(obj)
	local obj_type = type(obj)
	local copy

	if obj_type == 'table' then
		copy = {}
		for k,v in next, obj, nil do
			copy[k] = utils.deepcopy(v)
		end
	else
		copy = obj
	end
	return copy
end

function utils.mergetables(dest, source)
	assert(type(dest) == "table", "dest must be a table")
	for k, v in pairs(source or {}) do
		dest[k] = v
	end
	return dest
end

function utils.readlua(file, tblname, env)
	assert(file and type(file) == "string", "file path must be provided")
	local f = assert(loadfile(file))
	local config = env or {}
	setfenv(f, config)
	assert(pcall(f))
	local tbl = config
	if tblname ~= nil then
		tbl = config[tblname]
	end
	return tbl, file
end

function utils.readconfigs(cfgfiles, tbl)
	for _, cfg in pairs(cfgfiles) do
		tbl[cfg.name] = cfg.default
		if lfs.attributes(cfg.file) ~= nil then
			utils.mergetables(tbl[cfg.name],
				cfg.validate(cfg,
					utils.readlua(cfg.file, cfg.cfgtblname, cfg.env)))
		end
	end
end

local function errorhandler(key, m, path)
	local msg = string.format("%s: %s; file: %s",
		key, m, path or "nil")
	error(msg, 2)
end

function utils.checkkeys(keys, tbl)
	for _, keydata in ipairs(keys) do
		if keydata.default == nil and tbl[keydata.name] == nil
		   and type(keydata.check) ~= "function" then
			errorhandler(keydata.name, "missing required key", tbl.path)
		elseif keydata.default ~= nil and tbl[keydata.name] == nil then
			tbl[keydata.name] = keydata.default
		else
			if keydata.type ~= nil and
			   type(tbl[keydata.name]) ~= keydata.type then
				errorhandler(keydata.name, "invalid key value", tbl.path)
			end

			if type(keydata.check) == "function" then
				local valid, msg = keydata.check(keydata, tbl)
				if not valid then
					errorhandler(keydata.name,
						tostring(msg or "invalid key value"), tbl.path)
				end
			end
		end
	end
end

-- return the directory seperator used for the given OS
utils.sep = package.config:sub(1,1)

-- create an iterator over a table using sorted keys
-- order: optional, function to sort the keys with
function utils.sortedpairs(tbl, order)
	local index = 1
	local keys = {}
	for key, _ in pairs(tbl) do
		table.insert(keys, key)
	end
	table.sort(keys, order)
	local function iterator()
		local key = keys[index]
		if key ~= nil then
			index = index + 1
			return key, tbl[key]
		else
			return nil
		end
	end
	return iterator, tbl, index
end

return utils
