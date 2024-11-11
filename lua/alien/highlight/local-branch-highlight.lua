local M = {}

M.highlight = function(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:sub(1, 1) == "*" then
            vim.api.nvim_buf_add_highlight(bufnr, -1, "Title", i - 1, 0, -1)
        end
    end
end

return M
