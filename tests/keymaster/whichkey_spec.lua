local table_utils = require("keymaster.table-utils")

describe("keymaster.whichkey", function()
	local keymaster_whichkey = require("keymaster.whichkey")

	describe("from_wk_keymaps", function()
		it("transforms wk mappings", function()
			local km_mappings = keymaster_whichkey.from_wk_keymaps({
				name = "+Ignore",
				g = {
					x = { ":fgx action", "fgx action" },
					y = { ":fgy action", "fgy action" },
				},
			}, {
				prefix = "<leader>f",
				buffer = 1,
			})

			assert.are.with_eq(table_utils.deep_equals).unordered_equal({
				{
					modes = "n",
					lhs = "<leader>fgx",
					rhs = ":fgx action",
					description = "fgx action",
					buffer = 1,
				},
				{
					modes = "n",
					lhs = "<leader>fgy",
					rhs = ":fgy action",
					description = "fgy action",
					buffer = 1,
				},
			}, km_mappings)
		end)
	end)
end)
