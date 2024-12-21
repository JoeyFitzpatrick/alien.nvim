---@alias CommitFile { filename: string, raw_filename: string }

local M = {}

local commit_file_state = function(current_commit_file_state, line_num)
    if line_num == nil then
        line_num = vim.api.nvim_win_get_cursor(0)[1]
    end
    line_num = line_num - 1 -- Because the commit file output currently adds 1 lines
    if line_num <= 0 then
        return nil
    end
    local commit_file_line = require("alien.utils.tree-view.commit-tree-view")._map_line_num_to_commit_data(
        current_commit_file_state,
        line_num
    )
    return {
        filename = "'" .. commit_file_line.name .. "'",
        raw_filename = commit_file_line.name,
    }
end

--- Takes a line of text and attempts to return the file name
---@param bufnr integer
---@param line_num integer?
---@return CommitFile | nil
M.extract = function(bufnr, line_num)
    local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
    local first_word = first_line:match("%S+")
    local result = { hash = first_word }
    local current_commit_file_state = require("alien.elements.register.state").get_state(bufnr).commit_data
    if current_commit_file_state then
        local state = commit_file_state(current_commit_file_state, line_num)
        if state then
            result = vim.tbl_extend("keep", result, state)
        end
    end
    return result
end

return M
