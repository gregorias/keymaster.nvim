describe("keymaster", function()
	local keymaster = require("keymaster")

	describe("set_keymap", function()
		it("works with a minimal argument list", function()
			local vim_keymap = require("keymaster.vim-keymap").VimKeymap()
			keymaster.add_observer(vim_keymap)

			local has_executed = false
			keymaster.set_keymap("n", "fx", function()
				has_executed = true
			end)
			vim.api.nvim_feedkeys("fx", "mx", true)
			assert.True(has_executed)

			-- TODO: Add `del` to Keymaster.
			vim.keymap.del("n", "fx")
			keymaster.remove_observer(vim_keymap)
		end)

		it("sets a keymap", function()
			local vim_keymap = require("keymaster.vim-keymap").VimKeymap()
			keymaster.add_observer(vim_keymap)

			local has_executed = false
			keymaster.set_keymap("n", "fx", function()
				has_executed = true
			end, { desc = "TEST" })

			vim.api.nvim_feedkeys("fx", "mx", true)
			assert.True(has_executed)

			vim.keymap.del("n", "fx")
			keymaster.remove_observer(vim_keymap)
		end)

		it("supports Which-Key-like syntax", function()
			local vim_keymap = require("keymaster.vim-keymap").VimKeymap()
			keymaster.add_observer(vim_keymap)

			local has_executed = false
			keymaster.set_keymap({
				f = {
					x = {
						function()
							has_executed = true
						end,
						"TEST",
					},
				},
			})

			vim.api.nvim_feedkeys("fx", "mx", true)
			assert.True(has_executed)

			vim.keymap.del("n", "fx")
			keymaster.remove_observer(vim_keymap)
		end)

		it("supports rhs-free keymaps with Vim syntax", function()
			local notified_keymaps = {}

			---@type Observer
			local observer = {
				notify_keymap_set = function(_, keymap)
					table.insert(notified_keymaps, keymap)
				end,
			}

			keymaster.add_observer(observer)
			keymaster.set("n", "fx", nil, { desc = "Do Foo" })

			assert.are.same({ { mode = "n", lhs = "fx", rhs = nil, opts = { desc = "Do Foo" } } }, notified_keymaps)

			keymaster.remove_observer(observer)
		end)

		it("supports rhs-free keymaps with Which Key syntax", function()
			local notified_keymaps = {}

			---@type Observer
			local observer = {
				notify_keymap_set = function(_, keymap)
					table.insert(notified_keymaps, keymap)
				end,
				notify_keymap_deleted = function(_, keymap)
					for i, v in ipairs(notified_keymaps) do
						if require("keymaster.table-utils").deep_equals(v, keymap) then
							table.remove(notified_keymaps, i)
							break
						end
					end
				end,
			}

			keymaster.add_observer(observer)
			keymaster.set({ ["foo"] = "Do Foo" })

			assert.are.same({ { mode = "n", lhs = "foo", rhs = nil, opts = { desc = "Do Foo" } } }, notified_keymaps)

			keymaster.remove_observer(observer)
		end)
	end)

	describe("set", function()
		-- We want to have an interface consistent with vim.keymap.set.
		it("returns an error on duplicate unique keymaps", function()
			local vim_keymap = require("keymaster.vim-keymap").VimKeymap()
			keymaster.add_observer(vim_keymap)

			keymaster.set("n", "fx", function() end, { unique = true })
			local result, error = pcall(function()
				keymaster.set("n", "fx", function() end, { unique = true })
			end)

			-- This is what `vim.keymap.set` would have returned.
			assert.False(result)
			assert.is.same(error, "vim/keymap.lua:0: E227: mapping already exists for fx")

			-- TODO: Switch to using keymaster.del.
			vim.keymap.del("n", "fx", { unique = true })
			keymaster.remove_observer(vim_keymap)
		end)
	end)

	describe("add_lazy_load_observer", function()
		it("stores and replay events", function()
			local on_observer_load = keymaster.add_lazy_load_observer({ disable_config_time_events = true })
			keymaster.set_keymap("n", "fx", nil, { desc = "TEST" })
			local notified_keymaps = {}
			---@type Observer
			local observer = {
				notify_keymap_set = function(_, keymap)
					table.insert(notified_keymaps, keymap)
				end,
			}
			on_observer_load(observer)

			assert.are.same({ { mode = "n", lhs = "fx", rhs = nil, opts = { desc = "TEST" } } }, notified_keymaps)

			keymaster.remove_observer(observer)
		end)
	end)
end)
