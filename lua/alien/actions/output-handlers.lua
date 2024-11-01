local commands = require("alien.actions.commands")
local run_cmd = require("alien.actions").run_cmd
local ERROR_CODES = require("alien.actions.error-codes")

local num_commits_error_handler = {
  [ERROR_CODES.NO_UPSTREAM_ERROR] = function()
    return "0"
  end,
}

local M = {}

M.status_output_handler = function(output)
  local head = run_cmd(commands.current_head)[1]
  local staged_stats = run_cmd(commands.staged_stats)[1]
  local num_commits_to_pull = run_cmd(commands.num_commits_to_pull, num_commits_error_handler)[1]
  local num_commits_to_push = run_cmd(commands.num_commits_to_push, num_commits_error_handler)[1]

  local pull_str = num_commits_to_pull == "0" and "" or "↓" .. num_commits_to_pull
  local push_str = num_commits_to_push == "0" and "" or "↑" .. num_commits_to_push
  table.insert(output, 1, "HEAD: " .. head .. " " .. pull_str .. push_str)
  table.insert(output, 2, staged_stats)
  return output
end

---@param lines string[]
M.branch_output_handler = function(lines)
  local new_output = {}
  for _, line in ipairs(lines) do
    local branch = string.sub(line, 3)
    local num_commits_to_pull = vim.fn.system(commands.num_commits_to_pull(branch)):gsub("\n", "")
    local num_commits_to_push = vim.fn.system(commands.num_commits_to_push(branch)):gsub("\n", "")
    local pull_str = num_commits_to_pull == "0" and "" or "↓" .. num_commits_to_pull
    local push_str = num_commits_to_push == "0" and "" or "↑" .. num_commits_to_push
    table.insert(new_output, line .. " " .. push_str .. pull_str)
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
---@return "status" | "branch" | nil
M.get_output_handler = function(cmd)
  local first_word = cmd:match("%w+")
  if first_word ~= "git" then
    return nil
  end
  local word = cmd:match("%s[^%-]%S+")
  local git_verb = word:match("%S+")
  return verb_to_output_handler[git_verb]
end

return M
