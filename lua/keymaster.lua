local M = {}
local registry = require("keymaster.registry")

-- TODO: Document this function.
M.setup = function()
	local wk_status, wk = pcall(require, "which-key")

	local main_observer = nil
	if wk_status then
		main_observer = require("keymaster.whichkey").WhichKeyObserver(wk)
	else
		main_observer = require("keymaster.vim-keymap").VimKeymap()
	end
	registry:register_observer(main_observer)
end

-- TODO: Add a comment.
M.set_keymap = function(mode, lhs, rhs, opts)
	registry:add_keymap({
		lhs = lhs,
		rhs = rhs,
		modes = mode,
		description = opts.description,
	})
end

--- Get all set keymaps.
--
-- @return A table of all set keymaps.
M.get_keymaps = function(keymap)
	return registry.keymaps
end

--- Register a keymap observer.
M.register_observer = function(observer)
	registry:register_observer(observer)
end

return M
