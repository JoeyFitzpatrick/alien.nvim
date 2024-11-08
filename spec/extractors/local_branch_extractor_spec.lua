local extract = require("alien.extractors.local-branch-extractor").extract

describe("local branch extractor", function()
  it("should return the branch name and status for currently checked out branch", function()
    local expected =
      { branch_name = "main", is_current_branch = true, branch_name_position = { start = 3, ending = 6 } }
    assert.are.same(expected, extract("* main"))
  end)
  it("should return the branch name and status for non checked out branch", function()
    local expected =
      { branch_name = "test", is_current_branch = false, branch_name_position = { start = 3, ending = 6 } }
    assert.are.same(expected, extract("  test"))
  end)
  it("should return the branch name and status for branch with a pull/push string", function()
    local expected =
      { branch_name = "main", is_current_branch = true, branch_name_position = { start = 3, ending = 6 } }
    assert.are.same(expected, extract("* main ↑1"))
  end)
end)
