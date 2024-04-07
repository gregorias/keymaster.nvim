local M = {}

--- The global keymap dispatcher.
local dispatcher = require("keymaster.keymap-dispatcher").KeymapDispatcher:new()

--- An event registry observer that stores keymap events till VimEnter.
--
-- This observer facilitates users using Keymaster at an arbitrary point in their config lifetime and still capturing
-- all relevant events to be replayed to final observers.
--
---@type EventRegistryObserver
M.neovim_config_load_event_registry_observer = require("keymaster.event-registry-observer").EventRegistryObserver:new()
dispatcher:add_observer(M.neovim_config_load_event_registry_observer)
-- CursorHold is used to ensure the observer is removed eventually, even if the
-- user somehow never calls Keymaster during config time.
vim.api.nvim_create_autocmd({ "VimEnter", "CursorHold" }, {
	once = true,
	callback = function()
		if M.neovim_config_load_event_registry_observer then
			dispatcher:remove_observer(M.neovim_config_load_event_registry_observer)
			M.neovim_config_load_event_registry_observer = nil
		end
	end,
})

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
---
--- An alias for `set_keymap`. Since this plugin is a replacement for
--- vim.keymap, just `set` makes sense.
M.set = M.set_keymap

--- Register a keymap.
--
-- An alias for `set_keymap`. Since this plugin is meant to work with Which Key.
M.register = M.set_keymap

--- Delete a keymap.
M.delete_keymap = function(mode, lhs, opts)
	dispatcher:delete_keymap({ mode = mode, lhs = lhs, opts = opts })
end

--- Delete a keymap.
--
-- An alias for `delete_keymap`. Since this plugin is a replacement for vim.keymap, just `delete` makes sense.
M.del = M.delete_keymap

--- Add a keymap observer.
--
-- @param observer Observer
M.add_observer = function(observer)
	dispatcher:add_observer(observer)
end

--- Add a lazy load keymap observer.
--
-- This function facilitates lazy loading of keymap observers. Call this function during config initialization. Once you
-- are ready to add the final observer, call the callback with it.
--
--  TODO: Rename this function to `add_event_registry_observer`.
--
---@param opts { disable_config_time_events: boolean? }?
---@return function(observer:Observer):nil on_load The callback that will replay recorded events and add the observer.
M.add_lazy_load_observer = function(opts)
	opts = opts or {}
	local event_registry_observer = require("keymaster.event-registry-observer").EventRegistryObserver:new()
	if not opts.disable_config_time_events and M.neovim_config_load_event_registry_observer then
		M.neovim_config_load_event_registry_observer:transfer(event_registry_observer)
	end
	M.add_observer(event_registry_observer)
	return function(observer)
		event_registry_observer:transfer(observer)
		M.remove_observer(event_registry_observer)
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
