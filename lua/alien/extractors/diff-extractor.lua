---@class Hunk
---@field hunk_start integer
---@field hunk_end integer
---@field hunk_first_changed_line integer

local M = {}

--- Returns info on a diff hunk
---@return Hunk | nil
M.extract = function()
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    local hunk_start, hunk_end, hunk_first_changed_line = nil, nil, nil
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i = line_num, 1, -1 do
        if lines[i]:sub(1, 2) == "@@" then
            hunk_start = i + 1
            break
        end
    end
    if hunk_start == nil then
        return nil
    end

    for i = line_num + 1, #lines, 1 do
        if lines[i]:sub(1, 2) == "@@" then
            hunk_end = i - 1
            break
        end
    end
    if hunk_end == nil then
        hunk_end = #lines
    end

    for i = hunk_start, hunk_end, 1 do
        local first_char = lines[i]:sub(1, 1)
        if first_char == "+" or first_char == "-" then
            hunk_first_changed_line = i
            break
        end
    end
    if hunk_first_changed_line == nil then
        return nil
    end

    return { hunk_start = hunk_start, hunk_end = hunk_end, hunk_first_changed_line = hunk_first_changed_line }
end

return M
