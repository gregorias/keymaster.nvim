local M = {}
local registry = require("keymaster.registry")

--- A lazy load observer that stores keymap events till VimEnter.
---
--- This observer facilitates users using Keymaster at an arbitrary point in their config and still capturing all relevant events.
M.neovim_config_load_lazy_load_observer = require("keymaster.lazy-load-observer").LazyLoadObserver()
registry:register_observer(M.neovim_config_load_lazy_load_observer)
-- CursorHold is used to ensure the observer is removed eventually, even if the
-- user somehow never calls Keymaster during config time.
vim.api.nvim_create_autocmd({ "VimEnter", "CursorHold" }, {
	once = true,
	callback = function()
		if M.neovim_config_load_lazy_load_observer then
			registry:unregister_observer(M.neovim_config_load_lazy_load_observer)
			M.neovim_config_load_lazy_load_observer = nil
		end
	end,
})

local initial_observers = {}

---@class KeymasterConfig
---@field disable_legendary boolean?
---@field disable_which_key boolean?

--- Set up Keymaster.
---
---@param config KeymasterConfig Keymaster configuration.
M.setup = function(config)
	config = config or {}

	local vim_keymap_observer = require("keymaster.vim-keymap").VimKeymap()
	if config.disable_which_key then
		table.insert(initial_observers, vim_keymap_observer)
	else
		-- TODO: This code is ugly. Refactor it.
		-- TODO: Legendary has its own specialized function for checking if it’s installed.
		local which_key_status, which_key = pcall(require, "which-key")
		if which_key_status then
			table.insert(initial_observers, require("keymaster.whichkey").WhichKeyObserver(which_key))
		else
			table.insert(initial_observers, vim_keymap_observer)
		end
	end

	if not config.disable_legendary and require("keymaster.legendary").is_legendary_installed() then
		table.insert(initial_observers, require("keymaster.legendary").LegendaryObserver())
	end

	for _, observer in ipairs(initial_observers) do
		if M.neovim_config_load_lazy_load_observer then
			M.neovim_config_load_lazy_load_observer:load(observer)
		end
		registry:register_observer(observer)
	end
end

--- Shut down Keymaster.
M.shutdown = function()
	for _, observer in ipairs(initial_observers) do
		registry:unregister_observer(observer)
	end
	initial_observers = {}
end

--- Set a keymap using Neovim-like keymap syntax.
---
---@param rhs string | function | nil The right-hand side of the keymap or nil if it’s a info-only keymap.
---@return number id The keymap ID.
local set_vim_keymap = function(mode, lhs, rhs, opts)
	local km_keymap = require("keymaster.vim-keymap").from_vim_keymap(mode, lhs, rhs, opts)
	return registry:set_keymap(km_keymap)
end

--- Set keymaps using Which-Key-like keymap syntax.
---
---@return number[] ids The keymap IDs.
local set_which_key_keymaps = function(mappings, opts)
	opts = opts or {}
	local which_key_mappings, which_key_groups = require("keymaster.whichkey").from_wk_keymappings(mappings, opts)
	local ids = {}
	for _, mapping in ipairs(which_key_mappings) do
		local id = registry:set_keymap(mapping)
		table.insert(ids, id)
	end
	for _, group in ipairs(which_key_groups) do
		registry:set_key_group(group)
	end
	return ids
end

--- Set a keymap.
---
--- Accepts both Neovim-like keymap syntax and Which-Key-like keymap syntax.
---
---@return number | number[] id The keymap ID.
M.set_keymap = function(mappings_or_mode, wk_opts_or_lhs, rhs, opts)
	if type(mappings_or_mode) == "string" or vim.tbl_islist(mappings_or_mode) then
		return set_vim_keymap(mappings_or_mode, wk_opts_or_lhs, rhs, opts)
	else
		return set_which_key_keymaps(mappings_or_mode, wk_opts_or_lhs)
	end
end

--- Set a keymap.
--
-- An alias for `set_keymap`. Since this plugin is a replacement for
-- vim.keymap, just `set` makes sense.
M.set = M.set_keymap

--- Register a keymap.
--
-- An alias for `set_keymap`. Since this plugin is meant to work with Which Key.
M.register = M.set_keymap

--- Delete a keymap.
---
---@param keymap_id number The ID of the keymap to delete.
M.delete_keymap = function(keymap_id)
	registry:delete_keymap(keymap_id)
end

--- Get all set keymaps.
--
-- @return A table of all set keymaps.
M.get_keymaps = function()
	return registry.keymaps
end

--- Register a keymap observer.
---
---@param observer Observer
M.register_observer = function(observer)
	registry:register_observer(observer)
end

--- Unregister a keymap observer.
---
---@param observer Observer
M.unregister_observer = function(observer)
	registry:unregister_observer(observer)
end

return M
