describe("keymaster", function()
	local keymaster = require("keymaster")

	before_each(function()
		keymaster.setup({
			which_key = nil,
		})
	end)

	describe("set_keymap", function()
		it("works with a minimal argument list", function()
			local has_executed = false
			keymaster.set_keymap("n", "fx", function()
				has_executed = true
			end)
			vim.api.nvim_feedkeys("fx", "mx", true)
			assert.True(has_executed)
		end)

		it("sets a keymap", function()
			local has_executed = false
			keymaster.set_keymap("n", "fx", function()
				has_executed = true
			end, { description = "TEST" })

			vim.api.nvim_feedkeys("fx", "mx", true)
			assert.True(has_executed)
		end)

		it("supports Which-Key-like syntax", function()
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
		end)
	end)
end)
