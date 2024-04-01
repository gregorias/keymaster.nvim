--- An observer for lazy loading.
---
--- A previous design of this plugin had the dispatcher (than called
--- “registry”) store all events. Using observers for this purpose is better.
--- Observers are more flexible and simpler.
local M = {}

--- Create a LazyLoadObserver.
---
--- This observer stores all events and discharges them when the load method is
--- called. This semantics is meant to support lazy loading, when we to delay
--- the creation of some other observer.
---
--- Example use:
---
--- ```lua
--- keymaster.register_observer(lazy_observer)
--- -- work with Neovim
--- -- …
--- local expensive_observer = InitializeExpensiveObserver()
--- lazy_observer:load(expensive_observer)
--- keymaster.unregister_observer(lazy_observer)
--- keymaster.register_observer(expensive_observer)
--- ```
---
---@return Observer
M.LazyLoadObserver = function()
	return {
		event_registry = {},
		notify_keymap_set = function(self, keymap)
			table.insert(self.event_registry, { "keymap_set", keymap })
		end,
		notify_keymap_deleted = function(self, keymap)
			table.insert(self.event_registry, { "keymap_deleted", keymap })
		end,
		notify_key_group_set = function(self, key_group)
			table.insert(self.event_registry, { "key_group_set", key_group })
		end,
		---@param observer Observer
		load = function(self, observer)
			for _, event in pairs(self.event_registry) do
				local event_name, event_data = unpack(event)
				if observer["notify_" .. event_name] then
					observer["notify_" .. event_name](observer, event_data)
				end
			end
		end,
	}
end

return M
