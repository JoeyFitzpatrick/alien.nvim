local translate = require("alien.translators.commit-translator").translate

describe("commit translator", function()
	it("should return commit hash", function()
		local expected = { hash = "123abc" }
		assert.are.same(expected, translate("123abc JF chore: some commit msg"))
	end)
end)
