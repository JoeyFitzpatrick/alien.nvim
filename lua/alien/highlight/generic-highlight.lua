local M = {}

M.highlight = function(bufnr)
    vim.api.nvim_set_option_value("filetype", "git", { buf = bufnr })
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:sub(1, 3) == "-  " then
            vim.api.nvim_buf_add_highlight(bufnr, -1, "DiffDelete", i - 1, 0, -1)
        end
        if line:sub(1, 3) == "+  " then
            vim.api.nvim_buf_add_highlight(bufnr, -1, "DiffAdd", i - 1, 0, -1)
        end
    end
end

return M
