---@alias AlienObject "commit" | "local_file" | "local_branch" | "commit_file" | "status" | "diff" | nil
---@alias AlienVerb "log" | "status" | "diff" | "branch" | "diff-tree"

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
	DIFF_TREE = "diff-tree",
	SHOW = "show",
}

local verb_to_status = {
	[M.GIT_VERBS.STATUS] = M.OBJECT_TYPES.LOCAL_FILE,
	[M.GIT_VERBS.LOG] = M.OBJECT_TYPES.COMMIT,
	[M.GIT_VERBS.DIFF] = M.OBJECT_TYPES.DIFF,
	[M.GIT_VERBS.BRANCH] = M.OBJECT_TYPES.LOCAL_BRANCH,
	[M.GIT_VERBS.DIFF_TREE] = M.OBJECT_TYPES.COMMIT_FILE,
	[M.GIT_VERBS.SHOW] = M.OBJECT_TYPES.DIFF,
}

local pattern_to_status = {}

---
---@param cmd string | fun(obj: table, input: string | nil): string
---@return AlienObject
M.get_object_type = function(cmd)
	local first_word = cmd:match("%w+")
	if first_word ~= "git" then
		return nil
	end
	local word = cmd:match("%s[^%-]%S+")
	local git_verb = word:match("%S+")
	return verb_to_status[git_verb]
end

return M
