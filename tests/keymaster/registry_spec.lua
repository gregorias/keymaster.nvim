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
						if require('keymaster.table-utils').deep_equals(v, keymap) then
							table.remove(notified_keymaps, i)
							break
						end
					end
				end,
			}

			registry:register_observer(observer)
			registry:set_keymap({ mode = "n", lhs = "a", rhs = "b", opts = {} })

			assert.are.same({ { mode = "n", lhs = "a", rhs = "b", opts = {} } }, notified_keymaps)

			registry:delete_keymap({ mode = "n", lhs = "a", rhs = "b", opts = {} })

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
			registry:set_key_group({ mode = "n", lhs = "<leader>g", opts = { name = "+Git" } })

			assert.are.same({ { mode = "n", lhs = "<leader>g", opts = { name = "+Git" } } }, notified_key_groups)

			registry:delete_key_group({ mode = "n", lhs = "<leader>g", opts = { name = "+Git" } })
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

			registry:set_keymap({ mode = "n", lhs = "a", rhs = "b" })
			registry:set_keymap({ mode = "n", lhs = "c", rhs = "d" })
			registry:set_keymap({ mode = "n", lhs = "e", rhs = "f" })
			registry:delete_keymap({ mode = "n", lhs = "a", rhs = "b" })
			registry:delete_keymap({ mode = "n", lhs = "c", rhs = "d" })
			registry:delete_keymap({ mode = "n", lhs = "e", rhs = "f" })

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
