local M = {}

--- The global keymap dispatcher.
local dispatcher = require("keymaster.keymap-dispatcher").KeymapDispatcher:new()

--- A lazy load observer that stores keymap events till VimEnter.
---
--- This observer facilitates users using Keymaster at an arbitrary point in their config and still capturing all relevant events.
M.neovim_config_load_lazy_load_observer = require("keymaster.lazy-load-observer").LazyLoadObserver()
dispatcher:add_observer(M.neovim_config_load_lazy_load_observer)
-- CursorHold is used to ensure the observer is removed eventually, even if the
-- user somehow never calls Keymaster during config time.
vim.api.nvim_create_autocmd({ "VimEnter", "CursorHold" }, {
	once = true,
	callback = function()
		if M.neovim_config_load_lazy_load_observer then
			dispatcher:remove_observer(M.neovim_config_load_lazy_load_observer)
			M.neovim_config_load_lazy_load_observer = nil
		end
	end,
})

local initial_observers = {}

---@class (exact) KeymasterConfig
---@field disable_legendary boolean?
---@field disable_which_key boolean?

--- Set up Keymaster.
---
--- TODO: Test this function and config-time setup in general.
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
		dispatcher:add_observer(observer)
	end
end

--- Shut down Keymaster.
M.shutdown = function()
	for _, observer in ipairs(initial_observers) do
		dispatcher:remove_observer(observer)
	end
	initial_observers = {}
end

--- Set a keymap using Neovim-like keymap syntax.
---
---@param rhs string | function | nil The right-hand side of the keymap or nil if it’s a info-only keymap.
---@return number id The keymap ID.
local set_vim_keymap = function(mode, lhs, rhs, opts)
	local km_keymap = require("keymaster.vim-keymap").from_vim_keymap(mode, lhs, rhs, opts)
	return dispatcher:set_keymap(km_keymap)
end

--- Set keymaps using Which-Key-like keymap syntax.
---
---@return number[] ids The keymap IDs.
local set_which_key_keymaps = function(mappings, opts)
	opts = opts or {}
	local which_key_mappings, which_key_groups = require("keymaster.whichkey").from_wk_keymappings(mappings, opts)
	local ids = {}
	for _, mapping in ipairs(which_key_mappings) do
		local id = dispatcher:set_keymap(mapping)
		table.insert(ids, id)
	end
	for _, group in ipairs(which_key_groups) do
		dispatcher:set_key_group(group)
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
	dispatcher:delete_keymap(keymap_id)
end

--- Get all set keymaps.
--
-- @return A table of all set keymaps.
M.get_keymaps = function()
	return dispatcher.keymaps
end

--- Add a keymap observer.
---
---@param observer Observer
M.add_observer = function(observer)
	dispatcher:add_observer(observer)
end

--- Add a lazy load keymap observer.
---
--- This function facilitates lazy loading of keymap observers. Call this
--- function during config initialization. Once you are ready to add the final
--- observer, call the callback with it.
---
---@param opts { disable_config_time_events: boolean? }?
---@return function(observer:Observer):nil on_load The callback that will replay recorded events and add the observer.
M.add_lazy_load_observer = function(opts)
	opts = opts or {}
	local lazy_load_observer = require("keymaster.lazy-load-observer").LazyLoadObserver()
	if not opts.disable_config_time_events and M.neovim_config_load_lazy_load_observer then
		M.neovim_config_load_lazy_load_observer:load(lazy_load_observer)
	end
	M.add_observer(lazy_load_observer)
	return function(observer)
		lazy_load_observer:load(observer)
		M.remove_observer(lazy_load_observer)
		M.add_observer(observer)
	end
end

--- Remove a keymap observer.
---
---@param observer Observer
M.remove_observer = function(observer)
	dispatcher:remove_observer(observer)
end

return M
