local register = require("alien.elements.register")

describe("get_current_element", function()
    it("should return the element with the bufnr of the current buffer", function()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(buf)
        local mock_element = { bufnr = buf, child_elements = {}, object_type = "diff" }
        register.elements = { mock_element }
        assert.are.same(mock_element, register.get_current_element())
    end)
    it(
        "should return the element with the win number of the current buffer, if no element with matching bufnr is found",
        function()
            local win = vim.api.nvim_get_current_win()
            local mock_element_no_match = { bufnr = -1, child_elements = {}, object_type = "diff" }
            local mock_element_matching_win = { bufnr = -1, win = win, child_elements = {}, object_type = "diff" }
            register.elements = { mock_element_no_match, mock_element_matching_win }
            assert.are.same(mock_element_matching_win, register.get_current_element())
        end
    )
end)
