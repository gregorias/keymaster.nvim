--- Legendary utilities.
--
-- @module keymaster.legendary
-- @alias M
local M = {}

--- Create a Legendary observer.
--
-- @param legendary_wk The legendary.util.which_key module.
M.LegendaryObserver = function(legendary_wk, do_binding, use_groups)
	return {
		notify_keymap_added = function(_, keymap)
			local mappings, opts = unpack(require("keymaster.whichkey").to_wk_keymap(keymap))
			legendary_wk.bind_whichkey(mappings, opts, --[[do_binding]] do_binding, --[[use_groups]] use_groups)
		end,
	}
end

return M
