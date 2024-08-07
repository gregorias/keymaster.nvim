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

	-- noremap is true by default for vim.keymap.
	local noremap = opts.noremap
	if opts.noremap == false then
		noremap = false
	else
		noremap = true
	end

	-- silent is false by default for vim.keymap.
	local silent = opts.silent
	if opts.silent == true then
		silent = true
	else
		silent = false
	end

	return {
		{ [keymap.lhs] = {
			keymap.rhs,
			opts.desc,
		} },
		{
			mode = keymap.mode,
			buffer = opts.buffer or nil,
			silent = silent,
			noremap = noremap,
			nowait = opts.nowait or false,
			expr = opts.expr or false,
		},
	}
end

--- Transforms a Keymaster keymap into a WhichKey v3 keymap.
---
---@param keymap KeymasterKeymap
---@return WhichKeyV3Keymap
M.to_wk3_keymap = function(keymap)
	local opts = keymap.opts or {}

	-- noremap is true by default for vim.keymap.
	local noremap = opts.noremap
	if opts.noremap == false then
		noremap = false
	else
		noremap = true
	end

	-- silent is false by default for vim.keymap.
	local silent = opts.silent
	if opts.silent == true then
		silent = true
	else
		silent = false
	end

	return {
		[1] = keymap.lhs,
		[2] = keymap.rhs,
		desc = opts.desc,
		mode = keymap.mode,
		buffer = opts.buffer or nil,
		silent = silent,
		noremap = noremap,
		nowait = opts.nowait or false,
		expr = opts.expr or false,
	}
end

---@alias WhichKeyKeymapping table
---@alias WhichKeyKeymappings { [string]: string | WhichKeyKeymappings | WhichKeyKeymapping }
---@alias WhichKeyKeymap { [1]: WhichKeyKeymapping, [2]: WhichKeyOpts }

--- A non-group keymap.
---
--- The fields comes from WhichKey's schema:
--- (https://github.com/folke/which-key.nvim/blob/c4689ab39c1f51cac447893b05bb0266a7af1ed7/doc/which-key.nvim.txt#L284-L296).
---
---@class WhichKeyV3Keymap
---@field [1] string lhs
---@field [2]? string|fun() rhs
---@field desc string|fun():string description
---@field mode? string|string[]
---@field cond? boolean|fun():boolean
---@field hidden? boolean
---@field icon? string|any|fun():(any|string)
---@field proxy? string
---@field expand? fun():any
---@field buffer? number|boolean
---@field remap? boolean
---@field noremap? boolean
---@field silent? boolean
---@field expr? boolean
---@field nowait? boolean

--- A group keymap.
---
---@class WhichKeyV3Keygroup
---@field [1] string lhs
---@field group string|fun():string

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
				desc = nil,
			},
		}

		if type(mappings) == "string" then
			keymap.opts.desc = mappings
		else
			keymap.rhs = mappings[1]
			keymap.opts.desc = mappings[2]
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
		notify_keymap_set = function(_, km_keymap)
			wk.add(M.to_wk3_keymap(km_keymap))
		end,
		notify_keymap_deleted = function(_, _)
			return nil
		end,

		---@param key_group KeymasterKeyGroup
		notify_key_group_set = function(_, key_group)
			wk.add({
				[1] = key_group.lhs,
				group = key_group.opts.name,
				mode = key_group.mode,
				buffer = key_group.opts.buffer,
			})
			-- Fixes a bug, where the WhichKey window doesn’t show up in when there’s a conflicting prefix, e.g., `gcr` is
			-- used for Coerce, but `gc` is used for commenting.
			vim.keymap.set(key_group.mode, key_group.lhs, function()
				local wk_mode = key_group.mode
				if key_group.mode == "v" then
					wk_mode = "x"
				end
				require("which-key").show({ keys = key_group.lhs, mode = wk_mode })
			end, { buffer = key_group.opts.buffer })
		end,
	}
end

return M
