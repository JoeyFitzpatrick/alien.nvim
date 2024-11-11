local status = require("alien.status")

---@alias LocalFile { filename: string, file_status: string, raw_filename: string }

local M = {}

--- Takes a line of text and attempts to return the file name and status
---@param str string
---@return LocalFile | nil
M.extract = function(str)
    local status_start = 1
    local status_end = 2
    local file_status = str:sub(status_start, status_end)
    if not status.is_valid_status(file_status) then
        return nil
    end
    local filename = str:sub(4)
    return {
        filename = "'" .. filename .. "'",
        raw_filename = filename,
        file_status = file_status,
    }
end

return M
