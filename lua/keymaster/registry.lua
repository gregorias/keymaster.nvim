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
	key_groups = {},
	next_key_group_index = 1,
}

--- Keymaster keymap.
---
--- It is specifically designed to be a natural extension of the vim.keymap.set interface.
---
--- If rhs is missing, then this keymap is considered to be for information
--- only, not to be bound.
---
---@class (exact) KeymasterKeymap
---@field mode string | string[]
---@field lhs string
---@field rhs string | function | nil
---@field opts KeymasterKeymapOpts

--- Keymaster keymap options.
---
--- They can contain arbitrary key-value pairs.
---
---@class KeymasterKeymapOpts: VimKeymapOpts

--- Keymaster key group.
---
---@class (exact) KeymasterKeyGroup
---@field mode string | string[]
---@field lhs string
---@field opts { name: string, buffer: number? }

---@class Observer
---@field notify_keymap_set fun(self, keymap: KeymasterKeymap): nil
---@field notify_keymap_deleted (fun(self, keymap: KeymasterKeymap): nil)?
---@field notify_key_group_set (fun(self, keymap: KeymasterKeyGroup): nil)?

--- Register an observer.
---
---@param observer Observer
---@param opts { replay_registry: boolean }?
function Registry:register_observer(observer, opts)
	opts = opts or {}
	if opts.replay_registry then
		for _, keymap in pairs(self.keymaps) do
			observer:notify_keymap_set(keymap)
		end
		for _, key_group in pairs(self.key_groups) do
			if observer.notify_key_group_set then
				observer:notify_key_group_set(key_group)
			end
		end
	end
	table.insert(self.observers, observer)
end

--- Unregister an observer.
---
---@param observer Observer
function Registry:unregister_observer(observer)
	for i, v in pairs(self.observers) do
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
	self.keymaps[self.next_keymap_index] = keymap
	self.next_keymap_index = self.next_keymap_index + 1
	for _, observer in pairs(self.observers) do
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
	self.keymaps[keymap_id] = nil

	for _, observer in pairs(self.observers) do
		if observer.notify_keymap_deleted then
			observer:notify_keymap_deleted(keymap)
		end
	end
end

--- Set a key group.
---
---@param key_group KeymasterKeyGroup
---@return number The id of the set key_group.
function Registry:set_key_group(key_group)
	self.key_groups[self.next_key_group_index] = key_group
	self.next_key_group_index = self.next_key_group_index + 1
	for _, observer in pairs(self.observers) do
		if observer.notify_key_group_set then
			observer:notify_key_group_set(key_group)
		end
	end
	return self.next_key_group_index - 1
end

--- Delete a key group.
---
---@param key_group_id number The id of the key group to delete.
---@return nil
function Registry:delete_key_group(key_group_id)
	local key_group = self.key_groups[key_group_id]
	if key_group == nil then
		return
	end
	self.key_groups[key_group_id] = nil
end

return Registry
