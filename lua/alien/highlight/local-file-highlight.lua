---@alias Position { start: number, ending: number }

local M = {}

M.highlight = function(bufnr)
    local highlight_groups = require("alien.highlight.constants").highlight_groups
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        if i == 1 and line:sub(1, 4) == "HEAD" then
            local second_word = line:match("%S+%s+(%S+)")
            local head_length = 6
            vim.api.nvim_buf_add_highlight(bufnr, -1, "Title", i - 1, head_length, #second_word + head_length)
            vim.api.nvim_buf_add_highlight(bufnr, -1, "WarningMsg", i - 1, #second_word + head_length + 1, -1)
        end
        local local_file = require("alien.extractors.local-file-extractor").extract(line)
        if not local_file then
            goto continue
        end
        if require("alien.status").is_staged(local_file.file_status) then
            vim.api.nvim_buf_add_highlight(bufnr, -1, highlight_groups.ALIEN_DIFF_ADD, i - 1, 0, -1)
        else
            vim.api.nvim_buf_add_highlight(bufnr, -1, highlight_groups.ALIEN_DIFF_DELETE, i - 1, 0, -1)
        end
        ::continue::
    end
end

return M
