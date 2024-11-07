local translate = require("alien.translators.commit-translator").translate

describe("commit translator", function()
  it("should return commit hash", function()
    local expected = { hash = "123abcd", start = 0, ending = 7 }
    assert.are.same(expected, translate("123abcd JF chore: some commit msg"))
  end)
  it("should return commit hash when it isn't the first word in a string", function()
    local expected = { hash = "123abcd", start = 0, ending = 6 }
    assert.are.same(expected, translate("commit 123abcd "))
  end)
  it("should error when the commit hash is all zeros", function()
    local ok, _ = pcall(translate, "0000000 some other text")
    assert.are.equal(false, ok)
  end)
  it("should return nil when no hash is found", function()
    local result = translate("some text")
    assert.are.equal(nil, result)
  end)
end)
