---@alias AlienObject "commit" | "local_file" | "local_branch" | "commit_file" | "status" | "diff" | "blame" | "stash" | nil
---@alias AlienVerb "log" | "status" | "diff" | "branch" | "diff-tree" | "blame" | "stash"

local M = {}

M.OBJECT_TYPES = {
    LOCAL_FILE = "local_file",
    LOCAL_BRANCH = "local_branch",
    COMMIT_FILE = "commit_file",
    COMMIT = "commit",
    DIFF = "diff",
    BLAME = "blame",
    STASH = "stash",
}

M.GIT_VERBS = {
    LOG = "log",
    STATUS = "status",
    DIFF = "diff",
    BRANCH = "branch",
    DIFF_TREE = "diff-tree",
    SHOW = "show",
    BLAME = "blame",
    STASH = "stash",
}

local verb_to_status = {
    [M.GIT_VERBS.STATUS] = M.OBJECT_TYPES.LOCAL_FILE,
    [M.GIT_VERBS.LOG] = M.OBJECT_TYPES.COMMIT,
    [M.GIT_VERBS.DIFF] = M.OBJECT_TYPES.DIFF,
    [M.GIT_VERBS.BRANCH] = M.OBJECT_TYPES.LOCAL_BRANCH,
    [M.GIT_VERBS.DIFF_TREE] = M.OBJECT_TYPES.COMMIT_FILE,
    [M.GIT_VERBS.SHOW] = M.OBJECT_TYPES.DIFF,
    [M.GIT_VERBS.BLAME] = M.OBJECT_TYPES.BLAME,
    [M.GIT_VERBS.STASH] = M.OBJECT_TYPES.STASH,
}

---@param cmd string | fun(obj: table, input: string | nil): string
---@return AlienObject
M.get_object_type = function(cmd)
    if not cmd then
        return nil
    end
    local first_word = cmd:match("%w+")
    if first_word ~= "git" then
        return nil
    end
    local word = cmd:match("%s[^%-]%S+")
    local git_verb = word:match("%S+")
    return verb_to_status[git_verb]
end

--- Get a description from an object type, e.g. "local_file" -> "Local File"
---@param object_type AlienObject
M.get_object_type_desc = function(object_type)
    if not object_type then
        return
    end
    object_type = object_type:gsub("_", " ")
    return (object_type:gsub("(%l)(%w*)", function(a, b)
        return a:upper() .. b
    end))
end

return M
