local extract = require("alien.extractors.commit-extractor").extract

describe("commit extractor", function()
    it("should return commit hash", function()
        local expected = { hash = "123abcd", start = 0, ending = 7 }
        assert.are.same(expected, extract("123abcd JF chore: some commit msg"))
    end)
    it("should return commit hash when it isn't the first word in a string", function()
        local expected = { hash = "123abcd", start = 0, ending = 6 }
        assert.are.same(expected, extract("commit 123abcd "))
    end)
    it("should error when the commit hash is all zeros", function()
        local ok, _ = pcall(extract, "0000000 some other text")
        assert.are.equal(false, ok)
    end)
    it("should return nil when no hash is found", function()
        local result = extract("some text")
        assert.are.equal(nil, result)
    end)
end)
