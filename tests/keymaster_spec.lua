describe("keymaster", function()
	local keymaster = require("keymaster")

	before_each(function()
		keymaster.setup({
			which_key = nil,
		})
	end)

	it("sets a keymap", function()
		local has_executed = false
		keymaster.set_keymap("n", "fx", function()
			has_executed = true
		end, { description = "TEST" })

		vim.api.nvim_feedkeys("fx", "mx", true)
		assert.True(has_executed)
	end)
end)
