describe("keymaster.event-registry-observer", function()
	local event_registry_observer_m = require("keymaster.event-registry-observer")
	it("transfers all events into the provided observer", function()
		local event_registry_observer = event_registry_observer_m.EventRegistryObserver:new()

		event_registry_observer:notify_keymap_set({ mode = "n", lhs = "a", rhs = "b", opts = {} })
		event_registry_observer:notify_key_group_set({ mode = "n", lhs = "<leader>g", opts = { name = "+Git" } })
		event_registry_observer:notify_keymap_deleted({ mode = "n", lhs = "a", rhs = "b", opts = {} })

		local notified_events = {}

		---@type Observer
		local observer = {
			notify_keymap_set = function(_, keymap)
				table.insert(notified_events, { event = "keymap_set", keymap = keymap })
			end,
			notify_keymap_deleted = function(_, keymap)
				table.insert(notified_events, { event = "keymap_deleted", keymap = keymap })
			end,
			notify_key_group_set = function(_, key_group)
				table.insert(notified_events, { event = "key_group_set", key_group = key_group })
			end,
		}

		event_registry_observer:transfer(observer)

		assert.are.same({
			{ event = "keymap_set", keymap = { mode = "n", lhs = "a", rhs = "b", opts = {} } },
			{ event = "key_group_set", key_group = { mode = "n", lhs = "<leader>g", opts = { name = "+Git" } } },
			{ event = "keymap_deleted", keymap = { mode = "n", lhs = "a", rhs = "b", opts = {} } },
		}, notified_events)
	end)
end)
