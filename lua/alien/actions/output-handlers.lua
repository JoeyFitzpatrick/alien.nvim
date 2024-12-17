local commands = require("alien.actions.commands")
local run_cmd = require("alien.utils").run_cmd
local ERROR_CODES = require("alien.actions.error-codes")

local run_cmd_opts = {
    error_callbacks = {
        [ERROR_CODES.NO_UPSTREAM_ERROR] = function()
            return { "0" }
        end,
    },
}

local M = {}

---@param branch? string
---@return string, string
local function get_num_commits(branch)
    local pull_ok, num_commits_to_pull = pcall(run_cmd, commands.num_commits_to_pull(branch), run_cmd_opts)
    local pull_str = ""
    if pull_ok and num_commits_to_pull[1] ~= "0" then
        pull_str = "↓" .. num_commits_to_pull[1]
    end

    local push_ok, num_commits_to_push = pcall(run_cmd, commands.num_commits_to_push(branch), run_cmd_opts)
    local push_str = ""
    if push_ok and num_commits_to_push[1] ~= "0" then
        push_str = "↑" .. num_commits_to_push[1]
    end
    return pull_str, push_str
end

M.status_output_handler = function(output)
    local head = run_cmd(commands.current_head)[1]
    local staged_stats = run_cmd(commands.staged_stats)[1]
    local num_commits_to_pull, num_commits_to_push = get_num_commits()

    local status_file_tree = require("alien.utils.tree-view.status-tree-view").render_status_file_tree(output)
    local new_output = status_file_tree.lines
    table.insert(new_output, 1, "HEAD: " .. head .. " " .. num_commits_to_pull .. num_commits_to_push)
    table.insert(new_output, 2, staged_stats)
    return new_output
end

---@param lines string[]
M.branch_output_handler = function(lines)
    local new_output = {}
    for _, line in ipairs(lines) do
        local branch = string.sub(line, 3)
        local num_commits_to_pull, num_commits_to_push = get_num_commits(branch)
        table.insert(new_output, line .. " " .. num_commits_to_pull .. num_commits_to_push)
    end
    return new_output
end

M.GIT_VERBS = {
    STATUS = "status",
    BRANCH = "branch",
}

local verb_to_output_handler = {
    [M.GIT_VERBS.STATUS] = M.status_output_handler,
    [M.GIT_VERBS.BRANCH] = M.branch_output_handler,
}

---@param cmd string | fun(obj: table, input: string | nil): string
---@return nil | fun(lines: string[]): string[]
M.get_output_handler = function(cmd)
    local first_word = cmd:match("%w+")
    if first_word ~= "git" then
        return nil
    end
    local word = cmd:match("%s[^%-]%S+")
    if not word then
        return nil
    end
    local git_verb = word:match("%S+")
    if git_verb then
        return verb_to_output_handler[git_verb]
    end
end

return M
