---@alias AlienObject "commit" | "local_file" | "local_branch" | "commit_file" | "status" | "diff" | nil

local M = {}

M.OBJECT_TYPES = {
	LOCAL_FILE = "local_file",
	LOCAL_BRANCH = "local_branch",
	COMMIT_FILE = "commit_file",
	COMMIT = "commit",
	DIFF = "diff",
}

M.GIT_VERBS = {
	LOG = "log",
	STATUS = "status",
	DIFF = "diff",
	BRANCH = "branch",
}

---
---@param cmd string
---@return AlienObject
M.get_object_type = function(cmd)
	local first_word = cmd:match("%w+")
	if first_word ~= "git" then
		return nil
	end
	local word = cmd:match("%s[^%-]%S+")
	local git_verb = word:match("%S+")
	if git_verb == M.GIT_VERBS.STATUS then
		return M.OBJECT_TYPES.LOCAL_FILE
	elseif git_verb == M.GIT_VERBS.LOG then
		return M.OBJECT_TYPES.COMMIT
	elseif git_verb == M.GIT_VERBS.DIFF then
		return M.OBJECT_TYPES.DIFF
	elseif git_verb == M.GIT_VERBS.BRANCH then
		return M.OBJECT_TYPES.LOCAL_BRANCH
	end
	return nil
end

return M
