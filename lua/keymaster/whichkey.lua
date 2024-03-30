--- WhichKey-related utilities.
--
-- @module keymaster.whichkey
-- @alias M
local M = {}

--- Transform a Keymaster keymap into a WhichKey keymap.
---
---@param keymap KeymasterKeymap
---@return WhichKeyKeymap
M.to_wk_keymap = function(keymap)
	local opts = keymap.opts or {}

	return {
		{ [keymap.lhs] = {
			keymap.rhs,
			opts.description or "",
		} },
		{
			mode = keymap.mode,
			buffer = opts.buffer or nil,
			silent = opts.silent or true,
			noremap = opts.noremap or true,
			nowait = opts.nowait or false,
			expr = opts.expr or false,
		},
	}
end

---@alias WhichKeyKeymapping table
---@alias WhichKeyKeymappings { [string]: string | WhichKeyKeymappings | WhichKeyKeymapping }
---@alias WhichKeyKeymap { [1]: WhichKeyKeymapping, [2]: WhichKeyOpts }

--- Schema taken from https://github.com/folke/which-key.nvim?tab=readme-ov-file#-setup.
---@class WhichKeyOpts
---@field mode string? | string[]
---@field prefix string?
---@field buffer number?
---@field silent boolean?
---@field noremap boolean?
---@field expr boolean?

--- Transform Which-Key-style mappings into Keymaster-style mappings.
---
---@param mappings WhichKeyKeymappings | WhichKeyKeymapping
---@param opts WhichKeyOpts
---@return KeymasterKeymap[]
M.from_wk_keymaps = function(mappings, opts)
	local table_utils = require("keymaster.table-utils")

	if mappings[1] ~= nil then
		opts = table_utils.shallow_copy(opts or {})
		local prefix = opts.prefix or ""
		opts.prefix = nil
		local mode = opts.mode or "n"
		opts.mode = nil

		---@type KeymasterKeymap
		local keymap = {
			mode = mode,
			lhs = prefix,
			rhs = mappings[1],
			opts = {
				description = mappings[2],
			},
		}
		for key, value in pairs(opts) do
			keymap.opts[key] = value
		end
		for key, value in pairs(mappings) do
			if key ~= 1 and key ~= 2 then
				keymap.opts[key] = value --[[@as any]]
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
			local subkeymaps = M.from_wk_keymaps(value --[[@as WhichKeyKeymappings | WhichKeyKeymap ]], opts)
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
---@param wk table The WhichKey module.
---@return Observer
M.WhichKeyObserver = function(wk)
	return {
		notify_keymap_set = function(_, keymap)
			local mappings, opts = unpack(M.to_wk_keymap(keymap))
			wk.register(mappings, opts)
		end,
		notify_keymap_deleted = function(_, _)
			return nil
		end,
	}
end

return M
