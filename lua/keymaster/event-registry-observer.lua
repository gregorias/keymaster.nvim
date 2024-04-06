--- An observer that registers events.
---
--- A previous design of this plugin had the dispatcher (than called
--- “registry”) store all events. Using observers for this purpose is better.
--- Observers are more flexible and simpler.
local M = {}

---@class EventRegistryObserver: Observer
---@field notify_keymap_set fun(self, keymap: KeymasterKeymap): nil
---@field notify_keymap_deleted fun(self, keymap: KeymasterKeymap): nil
---@field notify_key_group_set fun(self, key_group: KeymasterKeyGroup): nil
---@field transfer fun(self, observer: Observer): nil
---@field event_registry table<string, KeymasterKeymap | KeymasterKeyGroup>

--- Example use:
---
--- ```lua
--- keymaster.register_observer(event_registry_observer)
--- -- work with Neovim
--- -- …
--- local expensive_observer = InitializeExpensiveObserver()
--- event_registry_observer:transfer(expensive_observer)
--- keymaster.unregister_observer(event_registry_observer)
--- keymaster.register_observer(expensive_observer)
--- ```
---
---@return Observer

M.EventRegistryObserver = {}

--- Create an event registry observer.
---
--- This observer stores all events and discharges them when the transfer
--- method is called. This semantics is meant to support lazy loading, when we
--- want to delay the creation of some other observer.
---@return EventRegistryObserver
function M.EventRegistryObserver:new()
	local observer = { event_registry = {} }
	setmetatable(observer, self)
	self.__index = self
	return observer
end

function M.EventRegistryObserver:notify_keymap_set(keymap)
	table.insert(self.event_registry, { "keymap_set", keymap })
end

function M.EventRegistryObserver:notify_keymap_deleted(keymap)
	table.insert(self.event_registry, { "keymap_deleted", keymap })
end

function M.EventRegistryObserver:notify_key_group_set(key_group)
	table.insert(self.event_registry, { "key_group_set", key_group })
end

--- Transfer events to another observer.
---
---@param self EventRegistryObserver
---@param observer Observer
---@return nil
function M.EventRegistryObserver:transfer(observer)
	for _, event in pairs(self.event_registry) do
		local event_name, event_data = unpack(event)
		if observer["notify_" .. event_name] then
			observer["notify_" .. event_name](observer, event_data)
		end
	end
end

return M
