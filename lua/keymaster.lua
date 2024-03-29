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

--- Set a keymap.
M.set_keymap = function(mode, lhs, rhs, opts)
	opts = opts or {}
	registry:add_keymap({
		lhs = lhs,
		rhs = rhs,
		modes = mode,
		description = opts.description,
	})
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
