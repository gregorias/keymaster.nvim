--- vim.keymap-related utilities.
--
-- @module keymaster.vim-keymap
-- @alias M
local M = {}

---@class (exact) VimKeymap
---@field mode string | string[]
---@field lhs string
---@field rhs string | function
---@field opts table

--- Options parsed by vim.keymap interface.
---
--- Sources:
--- - https://neovim.io/doc/user/map.html#%3Amap-arguments
--- - https://neovim.io/doc/user/api.html#nvim_set_keymap()
---
---@class (exact) VimKeymapOpts
---@field buffer number?
---@field desc string?
---@field noremap boolean?
---@field nowait boolean?
---@field silent boolean?
---@field script boolean?
---@field expr boolean?
---@field replace_keycodes boolean?
---@field unique boolean?

--- Transform vim.keymap-style mappings into Keymaster-style mappings.
---
---@param mode string | string[]
---@param lhs string
---@param rhs string?
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

--- Transform Keymaster keymap options into Vim keymap options.
---
---@param km_opts KeymasterKeymapOpts
---@return VimKeymapOpts
M.to_vim_keymap_opts = function(km_opts)
	local opts = {}
	for key, value in pairs(km_opts) do
		if key == "buffer" then
			opts.buffer = value
		elseif key == "desc" then
			opts.desc = value
		elseif key == "expr" then
			opts.expr = value
		elseif key == "noremap" then
			opts.noremap = value
		elseif key == "nowait" then
			opts.nowait = value
		elseif key == "replace_keycodes" then
			opts.replace_keycodes = value
		elseif key == "script" then
			opts.script = value
		elseif key == "silent" then
			opts.silent = value
		elseif key == "unique" then
			opts.unique = value
		end
	end
	return opts
end

--- Create a vim.keymap observer.
---
---@return Observer
M.VimKeymap = function()
	return {
		---@param keymap KeymasterKeymap
		notify_keymap_set = function(_, keymap)
			if keymap.rhs == nil then
				-- Ignore info-only keymaps.
				return nil
			end

			local vim_opts = M.to_vim_keymap_opts(keymap.opts or {})
			vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, vim_opts)
		end,

		notify_keymap_deleted = function(_, keymap)
			if keymap.rhs == nil then
				-- Ignore info-only keymaps.
				return nil
			end

			local vim_opts = M.to_vim_keymap_opts(keymap.opts or {})
			vim.keymap.del(keymap.mode, keymap.lhs, vim_opts)
		end,
	}
end

return M
