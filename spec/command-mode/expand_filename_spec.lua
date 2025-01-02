local expand_filename = require("alien.command-mode.utils").expand_filename

describe("expand filename", function()
    before_each(function()
        vim.api.nvim_buf_get_name = function()
            return "example.txt"
        end
    end)
    it("replaces the '%' character with the current filename", function()
        assert.are.equal("git add example.txt", expand_filename("git add %"))
    end)
    it("does not replace the '%' character when it is enclosed in quotes", function()
        assert.are.equal("git commit -m '%'", expand_filename("git commit -m '%'"))
    end)
end)
