local register = require("alien.elements.register")

local M = {}

---@alias CommitFile { hash: string, filename: string }

--- Takes a line of text representing a file at a commit, and attempts to return the commit hash and filename
---@param str string
---@return CommitFile | nil
M.translate = function(str)
	local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
	local first_word = first_line:match("%S+")
	return { hash = first_word, filename = str }
end

return M
