---@alias AlienObject "commit" | "local_file" | "commit_file" | "status" | "diff" | nil

local M = {}

M.OBJECT_TYPES = {
	LOCAL_FILE = "local_file",
	COMMIT_FILE = "commit_file",
	COMMIT = "commit",
	STATUS = "status",
	DIFF = "diff",
}

---
---@param cmd string
---@return AlienObject
M.get_object_type = function(cmd)
	local first_word = cmd:match("%w+")
	if first_word ~= "git" then
		return nil
	end
	local git_verb = cmd:match("%S+%s+(%S+)")
	if git_verb == M.OBJECT_TYPES.STATUS then
		return M.OBJECT_TYPES.LOCAL_FILE
	elseif git_verb == "log" then
		return M.OBJECT_TYPES.COMMIT
	elseif git_verb == "diff" then
		return M.OBJECT_TYPES.DIFF
	end
	return nil
end

return M
