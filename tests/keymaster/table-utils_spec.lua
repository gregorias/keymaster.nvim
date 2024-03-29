describe("keymaster.table-utils", function()
	local table_utils = require("keymaster.table-utils")
	describe("deep_equals", function()
		it("works", function()
			local a = { [1] = 1, b = { 3, 4 }, a = { 1, 2 } }
			local b = { [1] = 1, a = { 1, 2 }, b = { 3, 4 } }
			assert.True(table_utils.deep_equals(a, b))

			a = { [1] = 1, b = { 3, 4 }, a = { 1, 2 } }
			b = { [1] = 1, a = { 2, 3 }, b = { 3, 4 } }
			assert.False(table_utils.deep_equals(a, b))
		end)
	end)
end)
