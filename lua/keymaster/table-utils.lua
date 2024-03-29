--- Table utilities.
--
-- @module keymaster.table-utils
-- @alias M
local M = {}

--- Shallow copy a table.
M.shallow_copy = function(t)
	local result = {}
	for k, v in pairs(t) do
		result[k] = v
	end
	return result
end

--- Deeply compare two objects.
M.deep_equals = function(o1, o2, ignore_mt)
	-- Same object
	if o1 == o2 then
		return true
	end

	local o1Type = type(o1)
	local o2Type = type(o2)
	if o1Type ~= o2Type then
		return false
	end
	-- Same type but not table. Already compared above.
	if o1Type ~= "table" then
		return false
	end

	if not ignore_mt then
		local mt1 = getmetatable(o1)
		if mt1 and mt1.__eq then
			--compare using built in method
			return o1 == o2
		end
	end

	for key1, value1 in pairs(o1) do
		local value2 = o2[key1]
		if value2 == nil or M.deep_equals(value1, value2, ignore_mt) == false then
			return false
		end
	end

	-- Check keys in o2 but missing from o1.
	for key2, _ in pairs(o2) do
		if o1[key2] == nil then
			return false
		end
	end
	return true
end

return M
