local M = {}

local FILETYPE_MAP = {
	ts = "typescript",
}

--- Get the filetype of a file. Some filetypes are not detected correctly by Vim, so we need to manually set them.
---@param filename string
---@return string
M.get_filetype = function(filename)
	local filetype = vim.fn.fnamemodify(filename, ":e")
	return FILETYPE_MAP[filetype] or filetype
end

return M
