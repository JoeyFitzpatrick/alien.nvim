local overlap = require("alien.command-mode.utils").overlap

describe("overlap", function()
    it("returns true if an element in t1 is present in t2", function()
        local result = overlap({ "1", "2" }, { "1", "3" })
        assert.are.equal(result, true)
    end)
    it("returns false if no elements between the tables overlap", function()
        local result = overlap({ "1", "2" }, { "3", "4" })
        assert.are.equal(result, false)
    end)
end)
