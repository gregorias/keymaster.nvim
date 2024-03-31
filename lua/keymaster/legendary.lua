--- Legendary utilities.
--
-- @module keymaster.legendary
-- @alias M
local M = {}

--- Check if Legendary is installed.
---@return boolean
M.is_legendary_installed = function()
	local legendary_status = pcall(require, "legendary")
	return legendary_status
end

--- Create a Legendary observer.
---
---@return Observer
M.LegendaryObserver = function(do_binding, use_groups)
	local legendary_wk = require("legendary.util.which_key")
	return {
		notify_keymap_set = function(_, keymap)
			local mappings, opts = unpack(require("keymaster.whichkey").to_wk_keymap(keymap))
			legendary_wk.bind_whichkey(mappings, opts, --[[do_binding]] do_binding, --[[use_groups]] use_groups)
		end,
	}
end

return M
