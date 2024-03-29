--- The Keymaster registry
---
--- Registry is a singleton object that manages all the registered keymaps and
--- groups. It provides an observable pattern for keymap observers.
---
--- @class Registry
local Registry = {
	observers = {},
	keymaps = {},
}

-- TODO: Add registration tests.
function Registry:register_observer(observer)
	table.insert(self.observers, observer)
end

function Registry:unregister_observer(observer)
	for i, v in ipairs(self.observers) do
		if v == observer then
			table.remove(self.observers, i)
			break
		end
	end
end

-- TODO: Add a comment.
function Registry:add_keymap(keymap)
	table.insert(self.keymaps, keymap)
	for _, observer in ipairs(self.observers) do
		observer:notify_keymap_added(keymap)
	end
end

return Registry
