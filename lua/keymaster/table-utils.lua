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

return M
