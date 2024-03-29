local table_utils = require("keymaster.table-utils")

describe("keymaster.whichkey", function()
	local keymaster_whichkey = require("keymaster.whichkey")

	describe("from_wk_keymaps", function()
		local from_wk_keymaps = keymaster_whichkey.from_wk_keymaps

		it("transforms wk mappings", function()
			local km_mappings = from_wk_keymaps({
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
		it("transforms wk mappings with in-keymap options", function()
			local km_mappings = from_wk_keymaps({
				["<A-enter>"] = { [1] = "<C-o>o", [2] = "Start a new line below", noremap = false },
			}, {
				mode = "i",
			})

			assert.are.same({
				{
					modes = "i",
					lhs = "<A-enter>",
					rhs = "<C-o>o",
					description = "Start a new line below",
					noremap = false,
				},
			}, km_mappings)
		end)
	end)
end)
