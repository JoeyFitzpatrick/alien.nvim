---@alias Position { start: number, ending: number }

local M = {}

M.highlight = function(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        if i == 1 and line:sub(1, 4) == "HEAD" then
            local second_word = line:match("%S+%s+(%S+)")
            local head_length = 6
            vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienHead", i - 1, head_length, #second_word + head_length)
            vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienPushPullString", i - 1, #second_word + head_length + 1, -1)
        end
        local local_file = require("alien.extractors.local-file-extractor").extract(line)
        if not local_file then
            goto continue
        end
        local start = local_file.file_status_position.start
        local ending = local_file.file_status_position.ending
        if require("alien.status").is_staged(local_file.file_status) then
            vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienStaged", i - 1, start, ending)
            vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienStagedBg", i - 1, 0, -1)
        else
            vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienUnstaged", i - 1, start, ending)
            vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienUnstagedBg", i - 1, 0, -1)
        end
        ::continue::
    end
end

return M
