local set_element_opts = require("alien.elements")._set_element_opts

describe("set_element_opts", function()
    local mock_highlight = function() end
    local cmd = "git status"
    it("returns the updated opts", function()
        local result = set_element_opts(cmd, { object_type = "status" }, 0, { output = { "hello" } }, mock_highlight)
        local expected = {
            bufnr = 0,
            highlight = mock_highlight,
            object_type = "status",
            win = vim.api.nvim_get_current_win(),
        }

        -- It's tough to assert that the function in opts is correct,
        -- so we just assert that it is a function, then remove it so we can compare the rest of the properties
        assert.are.equal("function", type(result.action))
        result.action = nil

        assert.are.same(expected, result)
    end)
    it("uses the object type from the result if it's not in the opts", function()
        local result = set_element_opts(cmd, {}, 0, { output = { "hello" }, object_type = "status" }, mock_highlight)
        assert.are.same("status", result.object_type)
    end)
end)
