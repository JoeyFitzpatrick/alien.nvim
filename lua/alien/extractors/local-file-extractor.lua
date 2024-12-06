---@alias LocalFile { filename: string, file_status: string, raw_filename: string }

local M = {}

local status_state = function(current_status_state, line_num)
    if line_num == nil then
        line_num = vim.api.nvim_win_get_cursor(0)[1]
    end
    line_num = line_num - 2 -- Because the status output currently adds two lines
    if line_num <= 0 then
        return nil
    end
    local status_line =
        require("alien.utils.tree-view.status-tree-view")._map_line_num_to_status_data(current_status_state, line_num)
    return {
        filename = "'" .. status_line.name .. "'",
        raw_filename = status_line.name,
        file_status = status_line.status,
    }
end

--- Takes a line of text and attempts to return the file name and status
---@param bufnr integer
---@param line_num integer?
---@return LocalFile | nil
M.extract = function(bufnr, line_num)
    local current_status_state = require("alien.elements.register.state").get_state(bufnr).status_data
    if current_status_state then
        local state = status_state(current_status_state, line_num)
        if state then
            return state
        end
    end
end

return M
