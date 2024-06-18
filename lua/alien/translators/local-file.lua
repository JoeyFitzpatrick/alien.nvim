local status = require("alien.status")

local M = {}

--- Takes a line of text and attempts to return the file name and status
---@param str string
---@return LocalFile | nil
M.translate = function(str)
	local file_status = str:sub(1, 2)
	if not status.is_valid_status(file_status) then
		return nil
	end
	local filename = str:sub(4)
	return { filename = filename, file_status = file_status }
end

return M
