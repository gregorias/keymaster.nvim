describe("keymaster.registry", function()
	local registry = require("keymaster.registry")

	describe("register_observer", function()
		it("registers an observer that receives keymap events", function()
			local notified_keymaps = {}

			---@type Observer
			local observer = {
				notify_keymap_set = function(_, keymap)
					table.insert(notified_keymaps, keymap)
				end,
				notify_keymap_deleted = function(_, keymap)
					for i, v in ipairs(notified_keymaps) do
						if v == keymap then
							table.remove(notified_keymaps, i)
							break
						end
					end
				end,
			}

			registry:register_observer(observer)
			local keymap_id = registry:set_keymap({ mode = "n", lhs = "a", rhs = "b", opts = {} })

			assert.are.same({ { mode = "n", lhs = "a", rhs = "b", opts = {} } }, notified_keymaps)

			registry:delete_keymap(keymap_id)

			assert.are.same({}, notified_keymaps)

			registry:unregister_observer(observer)
		end)

		it("registers an observer that receives key group events", function()
			---@type KeymasterKeyGroup[]
			local notified_key_groups = {}

			---@type Observer
			local observer = {
				notify_key_group_set = function(_, key_group)
					table.insert(notified_key_groups, key_group)
				end,
				notify_keymap_set = function(_, _)
					return nil
				end,
				notify_keymap_deleted = function(_, _)
					return nil
				end,
			}

			registry:register_observer(observer)
			local key_group_id = registry:set_key_group({ mode = "n", lhs = "<leader>g", opts = { name = "+Git" } })

			assert.are.same({ { mode = "n", lhs = "<leader>g", opts = { name = "+Git" } } }, notified_key_groups)

			registry:delete_key_group(key_group_id)
			registry:unregister_observer(observer)
		end)

		it("sets and deletes multiple keymaps", function()
			-- This indirectly tests that the keymap table is correctly updated.
			local notified_set_keymaps = {}
			local notified_deleted_keymaps = {}

			local observer = {
				notify_keymap_set = function(_, keymap)
					table.insert(notified_set_keymaps, keymap)
				end,
				notify_keymap_deleted = function(_, keymap)
					table.insert(notified_deleted_keymaps, keymap)
				end,
			}
			registry:register_observer(observer)

			local keymap_id_1 = registry:set_keymap({ mode = "n", lhs = "a", rhs = "b" })
			local keymap_id_2 = registry:set_keymap({ mode = "n", lhs = "c", rhs = "d" })
			local keymap_id_3 = registry:set_keymap({ mode = "n", lhs = "e", rhs = "f" })

			registry:delete_keymap(keymap_id_1)
			registry:delete_keymap(keymap_id_2)
			registry:delete_keymap(keymap_id_3)

			registry:unregister_observer(observer)

			assert.are.same({
				{ mode = "n", lhs = "a", rhs = "b" },
				{ mode = "n", lhs = "c", rhs = "d" },
				{ mode = "n", lhs = "e", rhs = "f" },
			}, notified_set_keymaps)

			assert.are.same({
				{ mode = "n", lhs = "a", rhs = "b" },
				{ mode = "n", lhs = "c", rhs = "d" },
				{ mode = "n", lhs = "e", rhs = "f" },
			}, notified_deleted_keymaps)
		end)
	end)
end)
