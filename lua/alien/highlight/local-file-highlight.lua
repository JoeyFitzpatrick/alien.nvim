---@alias Position { start: number, ending: number }

local M = {}

M.highlight = function(bufnr)
    local hlgroups = require("alien.highlight.constants").highlight_groups
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        if i == 1 and line:sub(1, 4) == "HEAD" then
            local second_word = line:match("%S+%s+(%S+)")
            local head_length = 6
            local head_end = #second_word + head_length
            vim.api.nvim_buf_add_highlight(bufnr, -1, hlgroups.ALIEN_TITLE, i - 1, head_length, head_end)
            vim.api.nvim_buf_add_highlight(bufnr, -1, hlgroups.ALIEN_SECONDARY, i - 1, head_end + 1, -1)
        end
        local local_file = require("alien.extractors.local-file-extractor").extract(line)
        if not local_file then
            goto continue
        end
        if require("alien.status").is_staged(local_file.file_status) then
            vim.api.nvim_buf_add_highlight(bufnr, -1, hlgroups.ALIEN_DIFF_ADD, i - 1, 0, -1)
        else
            vim.api.nvim_buf_add_highlight(bufnr, -1, hlgroups.ALIEN_DIFF_DELETE, i - 1, 0, -1)
        end
        ::continue::
    end
end

return M
