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
---@return KeymasterKeyGroup[]
M.from_wk_keymappings = function(mappings, opts)
	local table_utils = require("keymaster.table-utils")

	if type(mappings) == "string" or mappings[1] ~= nil then
		opts = table_utils.shallow_copy(opts or {})
		local prefix = opts.prefix or ""
		opts.prefix = nil
		local mode = opts.mode or "n"
		opts.mode = nil

		---@type KeymasterKeymap
		local keymap = {
			mode = mode,
			lhs = prefix,
			rhs = nil,
			opts = {
				description = nil,
			},
		}

		if type(mappings) == "string" then
			keymap.opts.description = mappings
		else
			keymap.rhs = mappings[1]
			keymap.opts.description = mappings[2]
			for key, value in pairs(opts) do
				keymap.opts[key] = value
			end
			for key, value in pairs(mappings) do
				if key ~= 1 and key ~= 2 then
					keymap.opts[key] = value --[[@as any]]
				end
			end
		end

		return { keymap }, {}
	end

	local km_mappings, km_groups = {}, {}
	opts = table_utils.shallow_copy(opts or {})
	local prefix = opts.prefix or ""
	opts.prefix = nil

	for key, value in pairs(mappings) do
		if key == "name" then
			table.insert(km_groups, {
				mode = opts.mode or "n",
				lhs = prefix or "",
				opts = {
					name = value,
					buffer = opts.buffer or nil,
				},
			})
		else
			local subkeymaps, subkey_groups =
				M.from_wk_keymappings(value --[[@as WhichKeyKeymappings | WhichKeyKeymap ]], opts)
			for _, subkeymap in ipairs(subkeymaps) do
				subkeymap.lhs = prefix .. key .. subkeymap.lhs
				table.insert(km_mappings, subkeymap)
			end
			for _, subkey_group in ipairs(subkey_groups) do
				subkey_group.lhs = prefix .. key .. subkey_group.lhs
				table.insert(km_groups, subkey_group)
			end
		end
	end

	return km_mappings, km_groups
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

		---@param key_group KeymasterKeyGroup
		notify_key_group_set = function(_, key_group)
			wk.register({
				[key_group.lhs] = {
					name = key_group.opts.name,
				},
			}, {
				mode = key_group.mode,
				buffer = key_group.opts.buffer,
			})
		end,
	}
end

return M
