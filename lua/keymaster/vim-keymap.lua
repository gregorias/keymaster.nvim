--- vim.keymap-related utilities.
--
-- @module keymaster.vim-keymap
-- @alias M
local M = {}

--- Create a vim.keymap observer.
M.VimKeymap = function()
	return {
		notify_keymap_added = function(_, keymap)
			vim.keymap.set(keymap.modes, keymap.lhs, keymap.rhs, keymap.opts)
		end,
	}
end

return M
