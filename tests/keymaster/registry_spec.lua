describe("keymaster.registry", function()
	local registry = require("keymaster.registry")

	describe("register_observer", function()
		it("registers an observer that receives events", function()
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
	end)
end)
