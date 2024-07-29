local register = require("alien.elements.register")

local M = {}

---@alias CommitFile { hash: string, filename: string }

--- Takes a line of text representing a file at a commit, and attempts to return the commit hash and filename
---@param str string
---@return CommitFile | nil
M.translate = function(str)
	local commit_hash = register.get_current_element().commit_hash
	if not commit_hash then
		return nil
	end
	return { hash = commit_hash, filename = str }
end

return M
