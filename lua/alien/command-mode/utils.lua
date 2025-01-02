local M = {}

--- Parse the options in a given git command.
---@param cmd string
---@return string[]
M.parse_command_options = function(cmd)
    local command_arr = vim.split(cmd, " ")
    local result = {}
    for i = 3, #command_arr do
        table.insert(result, command_arr[i])
    end
    return result
end

--- Returns true if any options in a table are present in the other table.
---@param t1 table
---@param t2 table
M.overlap = function(t1, t2)
    for _, value in pairs(t1) do
        if vim.tbl_contains(t2, value) then
            return true
        end
    end
    return false
end

--- Returns true if the input args from command mode represent a visual range, e.g. '<,'>G log -L
---@param input_args { line1?: integer, line2?: integer, range?: integer }
---@return boolean
M.is_visual_range = function(input_args)
    return input_args.range == 2
end

--- Replace the "%" character with the current filename (like vim-fugitive)
--- It tries to do this in a helpful manner, and not expand the filename when the "%" is found within quotes, e.g. "git commit -m '%'"
---@param cmd string
---@return string
M.expand_filename = function(cmd)
    local in_quotes = false
    local previous_char
    local result = {}
    for i = 1, #cmd do
        local char = cmd:sub(i, i)
        if char == '"' or char == "'" then
            if previous_char ~= "\\" then -- Handle escaped quotes
                in_quotes = not in_quotes
            end
        end
        if char == "%" and not in_quotes then
            table.insert(result, vim.api.nvim_buf_get_name(0))
        else
            table.insert(result, char)
        end
        previous_char = char
    end

    return table.concat(result)
end

M.remove_quoted_text = function(input)
    return input:gsub("[\"'].-[\"']", "")
end

return M
