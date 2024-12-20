local M = {}

--- Get the number of lines to trim in terminal output.
--- Empty lines at the end of the terminal output, and lines that begin with `[Process exited`, should be trimmed.
---@param lines string[]
---@return integer
M.get_num_lines_to_trim = function(lines)
    local num_lines_to_trim = 0
    for i = #lines, 1, -1 do
        if lines[i] == "" or lines[i]:find("[Process exited", 1, true) ~= nil then
            num_lines_to_trim = num_lines_to_trim + 1
        else
            break
        end
    end
    return num_lines_to_trim
end

return M
