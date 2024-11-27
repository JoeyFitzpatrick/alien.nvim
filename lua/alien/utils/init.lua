local M = {}

M.get_visual_line_nums = function()
    -- move back to normal mode to access most recent visual line nums
    -- this is a workaround, as 'getpos' won't return correct lines until visual mode is exited
    local back_to_n = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
    vim.api.nvim_feedkeys(back_to_n, "x", false)
    local start = vim.fn.getpos("'<")[2] - 1
    local ending = vim.fn.getpos("'>")[2]
    return start, ending
end

--- Shallow validation to ensure a table conforms to a given schema
---@param tbl table
---@param schema table<string, string>
M.validate = function(tbl, schema)
    for key, property_type in pairs(schema) do
        local value_type = type(tbl[key])
        if property_type ~= value_type then
            error(
                string.format(
                    "Validation error: table with property %s (%s) does not match type %s",
                    key,
                    value_type,
                    property_type
                )
            )
        end
    end
end

--- Run a command, with side effects, such as displaying errors
---@param cmd string
---@param opts AlienOpts?
---@return string[]
M.run_cmd = function(cmd, opts)
    opts = opts or {}
    local error_callbacks = opts.error_callbacks
    local stdin = opts.stdin
    if cmd == "" then
        return {}
    end
    local output = nil
    if stdin ~= nil then
        output = vim.fn.systemlist(cmd, stdin)
    else
        output = vim.fn.systemlist(cmd)
    end
    if vim.v.shell_error ~= 0 then
        if error_callbacks and error_callbacks[vim.v.shell_error] then
            return error_callbacks[vim.v.shell_error](cmd)
        else
            vim.notify(table.concat(output, "\n"), vim.log.levels.ERROR)
            error(output)
        end
    end
    return output
end

return M
