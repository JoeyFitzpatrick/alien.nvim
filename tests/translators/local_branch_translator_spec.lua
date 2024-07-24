local translate = require("alien.translators.local-branch-translator").translate

describe("local branch translator", function()
	it("should return the branch name and status for currently checked out branch", function()
		local expected =
			{ branch_name = "main", is_current_branch = true, branch_name_position = { start = 3, ending = 6 } }
		assert.are.same(expected, translate("* main"))
	end)
	it("should return the branch name and status for non checked out branch", function()
		local expected =
			{ branch_name = "test", is_current_branch = false, branch_name_position = { start = 3, ending = 6 } }
		assert.are.same(expected, translate("  test"))
	end)
end)
