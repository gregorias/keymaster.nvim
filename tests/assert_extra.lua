--- Extra assertions for luassert.
local assert = require("luassert")
local say = require("say")

local EQ_STATE_KEY = "__eq_state"

--- A modifier that sets an equality function for the current assertion.
local function with_eq(state, arguments)
	state[EQ_STATE_KEY] = arguments[1]
	return state
end

local function unordered_equal(state, arguments)
	local l1 = arguments[1]
	local l2 = arguments[2]

	if not vim.tbl_islist(l1) then
		return false, { "The first argument is not a list." }
	end

	if not vim.tbl_islist(l2) then
		return false, { "The second argument is not a list." }
	end


	if #l1 ~= #l2 then
		arguments[1] = string.format("Lists have different length: %d and %d.", #l1, #l2)
		return false
	end

	local eq = rawget(state, EQ_STATE_KEY) or function(a, b)
		return a == b
	end

	for _, v1 in ipairs(l1) do
		local v1_count = 0
		for _, v in ipairs(l1) do
			if eq(v1, v) then
				v1_count = v1_count + 1
			end
		end

		local v2_count = 0
		for _, v2 in ipairs(l2) do
			if eq(v1, v2) then
				v2_count = v2_count + 1
				break
			end
		end

		if v1_count ~= v2_count then
			arguments[1] = string.format("Element %s is %d time(s) in the first argument but %d time(s) in the second.", vim.inspect(v1), v1_count, v2_count)
			return false
		end
	end

	return true
end

say:set_namespace("en")
say:set("assertion.unordered_equal.negative", "Both lists are unordered equal but expected unequal.")
say:set("assertion.unordered_equal.positive", ("Lists are not unordered equal. %s"))
assert:register(
	"assertion",
	"unordered_equal",
	unordered_equal,
	"assertion.unordered_equal.positive",
	"assertion.unordered_equal.negative"
)

assert:register("modifier", "with_eq", with_eq)
