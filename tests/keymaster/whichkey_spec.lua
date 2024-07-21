local table_utils = require("keymaster.table-utils")
require("tests.assert_extra")

describe("keymaster.whichkey", function()
	local keymaster_whichkey = require("keymaster.whichkey")

	describe("to_wk_keymap", function()
		local to_wk_keymaps = keymaster_whichkey.to_wk_keymap
		it("transforms Keymaster keymaps fully", function()
			---@type KeymasterKeymap
			local km_keymap = {
				mode = "x",
				lhs = "<leader>fgx",
				rhs = ":fgx action",
				opts = {
					desc = "fgx action",
					buffer = 1,
					silent = true,
					noremap = true,
					expr = false,
					to_be_ignored = "foo",
				},
			}

			---@type WhichKeyKeymap
			local wk_keymap = to_wk_keymaps(km_keymap)

			assert.are.same({

				{
					["<leader>fgx"] = { ":fgx action", "fgx action" },
				},
				{
					mode = "x",
					buffer = 1,
					silent = true,
					noremap = true,
					nowait = false,
					expr = false,
				},
			}, wk_keymap)
		end)

		it("maintains falsey opts", function()
			---@type KeymasterKeymap
			local km_keymap = {
				mode = { "n", "x" },
				lhs = "<leader>fgx",
				rhs = ":fgx action",
				opts = {
					silent = false,
					noremap = false,
					nowait = false,
					expr = false,
				},
			}

			---@type WhichKeyKeymap
			local wk_keymap = to_wk_keymaps(km_keymap)

			assert.are.same({
				{
					["<leader>fgx"] = { ":fgx action" },
				},
				{
					mode = { "n", "x" },
					silent = false,
					noremap = false,
					nowait = false,
					expr = false,
				},
			}, wk_keymap)
		end)

		it("transforms Keymaster keymaps with honoring WK defaults", function()
			---@type KeymasterKeymap
			local km_keymap = {
				mode = { "n", "x" },
				lhs = "<leader>fgx",
				rhs = ":fgx action",
				opts = {
					desc = "fgx action",
				},
			}

			---@type WhichKeyKeymap
			local wk_keymap = to_wk_keymaps(km_keymap)

			assert.are.same({

				{
					["<leader>fgx"] = { ":fgx action", "fgx action" },
				},
				{
					mode = { "n", "x" },
					buffer = nil,
					silent = false,
					noremap = true,
					nowait = false,
					expr = false,
				},
			}, wk_keymap)
		end)
	end)

	describe("to_wk3_keymap", function()
		local to_wk_keymaps = keymaster_whichkey.to_wk3_keymap
		it("transforms Keymaster keymaps fully", function()
			---@type KeymasterKeymap
			local km_keymap = {
				mode = "x",
				lhs = "<leader>fgx",
				rhs = ":fgx action",
				opts = {
					desc = "fgx action",
					buffer = 1,
					silent = true,
					noremap = true,
					expr = false,
					to_be_ignored = "foo",
				},
			}

			---@type WhichKeyKeymap
			local wk_keymap = to_wk_keymaps(km_keymap)

			assert.are.same({
				[1] = "<leader>fgx",
				[2] = ":fgx action",
				desc = "fgx action",
				mode = "x",
				buffer = 1,
				silent = true,
				noremap = true,
				nowait = false,
				expr = false,
			}, wk_keymap)
		end)

		it("maintains falsey opts", function()
			---@type KeymasterKeymap
			local km_keymap = {
				mode = { "n", "x" },
				lhs = "<leader>fgx",
				rhs = ":fgx action",
				opts = {
					silent = false,
					noremap = false,
					nowait = false,
					expr = false,
				},
			}

			---@type WhichKeyKeymap
			local wk_keymap = to_wk_keymaps(km_keymap)

			assert.are.same({
				[1] = "<leader>fgx",
				[2] = ":fgx action",
				desc = nil,
				mode = { "n", "x" },
				buffer = nil,
				silent = false,
				noremap = false,
				nowait = false,
				expr = false,
			}, wk_keymap)
		end)

		it("transforms Keymaster keymaps with honoring WK defaults", function()
			---@type KeymasterKeymap
			local km_keymap = {
				mode = { "n", "x" },
				lhs = "<leader>fgx",
				rhs = ":fgx action",
				opts = {
					desc = "fgx action",
				},
			}

			---@type WhichKeyKeymap
			local wk_keymap = to_wk_keymaps(km_keymap)

			assert.are.same({
				[1] = "<leader>fgx",
				[2] = ":fgx action",
				desc = "fgx action",
				mode = { "n", "x" },
				buffer = nil,
				silent = false,
				noremap = true,
				nowait = false,
				expr = false,
			}, wk_keymap)
		end)
	end)

	describe("from_wk_keymappings", function()
		local from_wk_keymappings = keymaster_whichkey.from_wk_keymappings

		it("transforms wk mappings", function()
			local km_mappings, km_key_groups = from_wk_keymappings({
				name = "+Foo",
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
					mode = "n",
					lhs = "<leader>fgx",
					rhs = ":fgx action",
					opts = {
						desc = "fgx action",
						buffer = 1,
					},
				},
				{
					mode = "n",
					lhs = "<leader>fgy",
					rhs = ":fgy action",
					opts = {
						desc = "fgy action",
						buffer = 1,
					},
				},
			}, km_mappings)
			assert.are.same({
				{ mode = "n", lhs = "<leader>f", opts = { name = "+Foo", buffer = 1 } },
			}, km_key_groups)
		end)

		it("transforms wk mappings with in-keymap options", function()
			local km_mappings = from_wk_keymappings({
				["<A-enter>"] = { [1] = "<C-o>o", [2] = "Start a new line below", noremap = false },
			}, {
				mode = "i",
			})

			assert.are.same({
				{
					mode = "i",
					lhs = "<A-enter>",
					rhs = "<C-o>o",
					opts = {
						desc = "Start a new line below",
						noremap = false,
					},
				},
			}, km_mappings)
		end)

		it("recognizes rhs-free mappings", function()
			local km_mappings = from_wk_keymappings({
				["foo"] = "Do Foo",
			})

			assert.are.same({
				{
					mode = "n",
					lhs = "foo",
					rhs = nil,
					opts = {
						desc = "Do Foo",
					},
				},
			}, km_mappings)
		end)
	end)
end)
