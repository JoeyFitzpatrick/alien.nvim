local translate = require("alien.translators.stash-translator").translate

describe("stash translator", function()
	it("should return stash index and name", function()
		local expected = { index = "0", name = "test_stash", name_start = 20, name_end = 30 }
		assert.are.same(expected, translate("stash@{0}: On main: test_stash"))
	end)
end)
