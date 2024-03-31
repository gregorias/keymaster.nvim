describe("keymaster.vim-keymap", function()
	local keymaster_vim_keymap = require("keymaster.vim-keymap")

	describe("from_vim_keymap", function()
		local from_vim_keymap = keymaster_vim_keymap.from_vim_keymap
		it("transforms vim keymap", function()
			local km_mapping = from_vim_keymap("n", "<leader>fgx", ":fgx action", {
				desc = "fgx action",
				buffer = 1,
			})

			assert.are.same({
				mode = "n",
				lhs = "<leader>fgx",
				rhs = ":fgx action",
				opts = {
					desc = "fgx action",
					buffer = 1,
				},
			}, km_mapping)
		end)
	end)
end)
