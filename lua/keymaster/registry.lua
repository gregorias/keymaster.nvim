--- The Keymaster registry
---
--- Registry is a singleton object that manages all the registered keymaps and
--- groups. It provides an observable pattern for keymap observers.
---
---@class Registry
local Registry = {
	observers = {},
	keymaps = {},
	next_keymap_index = 1,
}

---@class KeymasterKeymap
---@field mode string | string[]
---@field lhs string
---@field rhs string | function
---@field opts table

---@class Observer
---@field notify_keymap_set fun(self, keymap: KeymasterKeymap): nil
---@field notify_keymap_deleted fun(self, keymap: KeymasterKeymap): nil

--- Register an observer.
---
---@param observer Observer
function Registry:register_observer(observer)
	table.insert(self.observers, observer)
end

--- Unregister an observer.
---
---@param observer Observer
function Registry:unregister_observer(observer)
	for i, v in ipairs(self.observers) do
		if v == observer then
			table.remove(self.observers, i)
			break
		end
	end
end

--- Set a keymap.
---
---@param keymap KeymasterKeymap
---@return number The id of the set keymap.
function Registry:set_keymap(keymap)
	table.insert(self.keymaps, self.next_keymap_index, keymap)
	self.next_keymap_index = self.next_keymap_index + 1
	for _, observer in ipairs(self.observers) do
		observer:notify_keymap_set(keymap)
	end
	return self.next_keymap_index - 1
end

--- Delete a keymap.
---
---@param keymap_id number The id of the keymap to delete.
---@return nil
function Registry:delete_keymap(keymap_id)
	local keymap = self.keymaps[keymap_id]
	if keymap == nil then
		return
	end
	table.remove(self.keymaps, keymap_id)

	for _, observer in ipairs(self.observers) do
		observer:notify_keymap_deleted(keymap)
	end
end

return Registry
