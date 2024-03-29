describe("keymaster.whichkey", function()
	local keymaster_whichkey = require("keymaster.whichkey")

	describe("from_wk_keymaps", function()
		it("transforms wk mappings", function()
			local km_mappings = keymaster_whichkey.from_wk_keymaps({
				name = "+Ignore",
				g = {
					x = { ":fgx action", "fgx action" },
				},
			}, {
				prefix = "<leader>f",
				buffer = 1,
			})

			-- TODO: Add a matcher that checks two lists for unordered equality.
			assert.are.same({
				{
					modes = "n",
					lhs = "<leader>fgx",
					rhs = ":fgx action",
					description = "fgx action",
					buffer = 1,
				},
			}, km_mappings)
		end)
	end)
end)
