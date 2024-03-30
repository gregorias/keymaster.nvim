--- WhichKey-related utilities.
--
-- @module keymaster.whichkey
-- @alias M
local M = {}

--- Transform a keymap into a WhichKey keymap.
M.to_wk_keymap = function(keymap)
	return {
		{ [keymap.lhs] = {
			keymap.rhs,
			keymap.description,
		} },
		{
			mode = keymap.modes,
		},
	}
end

--- Transform Which-Key-style mappings into Keymaster-style mappings.
M.from_wk_keymaps = function(mappings, opts)
	local table_utils = require("keymaster.table-utils")

	if mappings[1] ~= nil then
		opts = table_utils.shallow_copy(opts or {})
		local prefix = opts.prefix or ""
		opts.prefix = nil
		local mode = opts.mode or "n"
		opts.mode = nil

		local keymap = {
			modes = mode,
			lhs = prefix,
			rhs = mappings[1],
			description = mappings[2],
		}
		for key, value in pairs(opts) do
			keymap[key] = value
		end
		for key, value in pairs(mappings) do
			if key ~= 1 and key ~= 2 then
				keymap[key] = value
			end
		end

		return { keymap }
	end

	local km_mappings = {}
	opts = table_utils.shallow_copy(opts or {})
	local prefix = opts.prefix or ""
	opts.prefix = nil

	for key, value in pairs(mappings) do
		if key ~= "name" then
			local subkeymaps = M.from_wk_keymaps(value, opts)
			for _, subkeymap in ipairs(subkeymaps) do
				subkeymap.lhs = prefix .. key .. subkeymap.lhs
				table.insert(km_mappings, subkeymap)
			end
		end
	end

	return km_mappings
end

--- Create a WhichKey observer.
--
-- @param wk The WhichKey module.
M.WhichKeyObserver = function(wk)
	return {
		notify_keymap_set = function(_, keymap)
			local mappings, opts = unpack(M.to_wk_keymap(keymap))
			wk.register(mappings, opts)
		end,
	}
end

return M
