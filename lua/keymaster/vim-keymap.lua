--- vim.keymap-related utilities.
--
-- @module keymaster.vim-keymap
-- @alias M
local M = {}

--- Transform vim.keymap-style mappings into Keymaster-style mappings.
M.from_vim_keymap = function(mode, lhs, rhs, opts)
	opts = opts or {}
	local keymap = {
		modes = mode,
		lhs = lhs,
		rhs = rhs,
	}
	for key, value in pairs(opts) do
		keymap[key] = value
	end
	return keymap
end

--- Create a vim.keymap observer.
M.VimKeymap = function()
	return {
		notify_keymap_set = function(_, keymap)
			local opts = {}
			for key, value in pairs(keymap) do
				if key == "buffer" then
					opts.buffer = value
				elseif key == "expr" then
					opts.expr = value
				elseif key == "noremap" then
					opts.noremap = value
				elseif key == "nowait" then
					opts.nowait = value
				elseif key == "script" then
					opts.script = value
				elseif key == "silent" then
					opts.silent = value
				elseif key == "unique" then
					opts.unique = value
				end
			end
			vim.keymap.set(keymap.modes, keymap.lhs, keymap.rhs, opts)
		end,
	}
end

return M
