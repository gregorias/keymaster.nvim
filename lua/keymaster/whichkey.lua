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

--- Create a WhichKey observer.
--
-- @param wk The WhichKey module.
M.WhichKeyObserver = function(wk)
	return {
		notify_keymap_added = function(_, keymap)
			local mappings, opts = unpack(M.to_wk_keymap(keymap))
			wk.register(mappings, opts)
		end,
	}
end

return M
