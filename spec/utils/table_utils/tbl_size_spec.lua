local tbl_size = require("alien.utils.table_utils").tbl_size

describe("tbl_size", function()
    it("returns correct size for key-value-pair table", function()
        assert.are.equal(3, tbl_size({ key1 = "", key2 = "", key3 = "" }))
    end)
end)
