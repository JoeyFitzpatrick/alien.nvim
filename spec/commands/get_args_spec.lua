local get_args = require("alien.actions.commands").get_args

local function extract(str)
    return str:sub(1, 5)
end

local function setup_buffer()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "hello world" })
    vim.api.nvim_set_current_buf(bufnr)
end

describe("get_args", function()
    it("returns extract directly when there is no additional input", function()
        setup_buffer()
        assert.equal("hello", get_args(extract)())
    end)
    it("returns extract function when there is additional input", function()
        setup_buffer()
        local args, input = get_args(extract)("input")()
        assert.equal("hello", args)
        assert.equal("input", input)
    end)
end)
