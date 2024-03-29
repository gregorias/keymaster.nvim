local M = {}
local registry = require("keymaster.registry")

-- TODO: Document this function.
M.setup = function(config)
	config = config or {}

	local main_observer = nil
	if config.which_key ~= nil then
		main_observer = require("keymaster.whichkey").WhichKeyObserver(config.which_key)
	else
		main_observer = require("keymaster.vim-keymap").VimKeymap()
	end
	registry:register_observer(main_observer)
end

--- Set a keymap using Neovim-like keymap syntax.
local set_vim_keymap = function(mode, lhs, rhs, opts)
	opts = opts or {}
	registry:add_keymap({
		lhs = lhs,
		rhs = rhs,
		modes = mode,
		description = opts.description,
	})
end

--- Set keymaps using Which-Key-like keymap syntax.
local set_which_key_keymaps = function(mappings, opts)
	opts = opts or {}
	local which_key_mappings = require("keymaster.whichkey").from_wk_keymaps(mappings, opts)
	for _, mapping in ipairs(which_key_mappings) do
		registry:add_keymap(mapping)
	end
end

--- Set a keymap.
--
-- Accepts both Neovim-like keymap syntax and Which-Key-like keymap syntax.
M.set_keymap = function(mappings_or_modes, wk_opts_or_lhs, rhs, opts)
	if type(mappings_or_modes) == "string" or vim.tbl_islist(mappings_or_modes) then
		set_vim_keymap(mappings_or_modes, wk_opts_or_lhs, rhs, opts)
	else
		set_which_key_keymaps(mappings_or_modes, wk_opts_or_lhs)
	end
end

--- Get all set keymaps.
--
-- @return A table of all set keymaps.
M.get_keymaps = function()
	return registry.keymaps
end

--- Register a keymap observer.
M.register_observer = function(observer)
	registry:register_observer(observer)
end

return M
