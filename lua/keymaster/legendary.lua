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
M.LegendaryObserver = function()
	return {
		notify_keymap_set = function(_, keymap)
			local desc = keymap.opts and keymap.opts.desc
			local mode = keymap.opts and keymap.opts.mode
			require("legendary").keymap({ [1] = keymap.lhs, description = desc, mode = mode })
		end,
	}
end

return M
