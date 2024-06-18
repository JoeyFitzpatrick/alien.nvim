---@alias AlienObject "commit" | "local_file" | "commit_file" | "status" | nil

local M = {}

M.OBJECT_TYPES = {
	LOCAL_FILE = "local_file",
	COMMIT_FILE = "commit_file",
	COMMIT = "commit",
	STATUS = "status",
}

---
---@param git_verb string
---@return string | nil
M.get_object_type = function(git_verb)
	if git_verb == M.OBJECT_TYPES.STATUS then
		return M.OBJECT_TYPES.LOCAL_FILE
	elseif git_verb == "log" then
		return M.OBJECT_TYPES.COMMIT
	end
	return nil
end

return M
