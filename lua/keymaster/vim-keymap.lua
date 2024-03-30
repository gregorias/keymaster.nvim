--- vim.keymap-related utilities.
--
-- @module keymaster.vim-keymap
-- @alias M
local M = {}

---@class VimKeymap
---@field mode string | string[]
---@field lhs string
---@field rhs string | function
---@field opts table

--- Options taken from https://neovim.io/doc/user/map.html#%3Amap-arguments + noremap.
---@class VimKeymapOpts
---@field buffer number?
---@field nowait boolean?
---@field silent boolean?
---@field script boolean?
---@field expr boolean?
---@field unique boolean?
---@field noremap boolean?

--- Transform vim.keymap-style mappings into Keymaster-style mappings.
---
---@param mode string | string[]
---@param lhs string
---@param rhs string
---@param opts VimKeymapOpts
---@return KeymasterKeymap
M.from_vim_keymap = function(mode, lhs, rhs, opts)
	opts = opts or {}
	---@type KeymasterKeymap
	local keymap = {
		mode = mode,
		lhs = lhs,
		rhs = rhs,
		opts = {},
	}
	for key, value in pairs(opts) do
		keymap.opts[key] = value
	end
	return keymap
end

--- Create a vim.keymap observer.
---@return Observer
M.VimKeymap = function()
	return {
		---@param keymap KeymasterKeymap
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
			vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, opts)
		end,
	}
end

return M
