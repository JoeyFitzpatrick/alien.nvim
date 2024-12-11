local M = {}

M.highlight = function(bufnr)
    local highlight_groups = require("alien.highlight.constants").highlight_groups
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:sub(1, 1) == "*" then
            vim.api.nvim_buf_add_highlight(bufnr, -1, highlight_groups.ALIEN_TITLE, i - 1, 0, -1)
        end
        local _, branch_name_end = line:find("..%S+%s?") -- Find all text up to, but not including, push/pull string, whether it exists or not
        if branch_name_end then
            vim.api.nvim_buf_add_highlight(bufnr, -1, highlight_groups.ALIEN_SECONDARY, i - 1, branch_name_end, -1)
        end
    end
end

return M
