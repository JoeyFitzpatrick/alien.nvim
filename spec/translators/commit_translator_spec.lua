local translate = require("alien.translators.commit-translator").translate

describe("commit translator", function()
  it("should return commit hash", function()
    local expected = { hash = "123abcd", start = 0, ending = 7 }
    assert.are.same(expected, translate("123abcd JF chore: some commit msg"))
  end)
end)
