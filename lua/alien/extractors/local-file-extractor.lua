local status = require("alien.status")

---@alias LocalFile { filename: string, file_status: string, raw_filename: string }

local M = {}

--- In the file tree, find the parents that are above the file, to get the full file name.
---@param line string
M._find_filename = function(line)
    local second_word = line:match("%S+%s+(%S+)")
    local filename = second_word
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    if lines[line_num] ~= line then
        return filename
    end
    local spacing = ""
    while line:len() > 4 and line:sub(1, 4) == require("alien.constants").TREE_SPACING do
        line = line:sub(5)
        spacing = spacing .. require("alien.constants").TREE_SPACING
    end
    for i = line_num, 1, -1 do
        if spacing:len() < 4 then
            break
        end
        local current_line = lines[i]
        if current_line:sub(1, spacing:len()) ~= spacing then
            spacing = spacing:sub(5)
            local dir_start_index = current_line:find("[%w]")
            if not dir_start_index then
                goto continue
            end
            filename = current_line:sub(dir_start_index) .. "/" .. filename
        end
        ::continue::
    end
    return filename
end

local status_state = function(current_status_state)
    local line_num = vim.api.nvim_win_get_cursor(0)[1] - 2 -- Adding 2 becuase the status output currently adds two lines
    if line_num <= 0 then
        return nil
    end
    local status_line = current_status_state[line_num]
    return {
        filename = "'" .. status_line.name .. "'",
        raw_filename = status_line.name,
        file_status = status_line.status,
    }
end

--- Takes a line of text and attempts to return the file name and status
---@param str string
---@return LocalFile | nil
M.extract = function(str)
    -- local current_status_state = require("alien.elements.register").get_state(vim.api.nvim_get_current_buf())
    -- if current_status_state then
    --     local state = status_state(current_status_state)
    --     if state then
    --         return state
    --     end
    -- end
    local filename = M._find_filename(str)
    local status_start = 1
    local status_end = 2
    while str:len() > 4 and str:sub(1, 4) == require("alien.constants").TREE_SPACING do
        str = str:sub(5)
    end
    local file_status = str:sub(status_start, status_end)
    if not status.is_valid_status(file_status) then
        return nil
    end
    return {
        filename = "'" .. filename .. "'",
        raw_filename = filename,
        file_status = file_status,
    }
end

return M
