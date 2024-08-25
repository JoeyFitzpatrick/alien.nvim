local commands = require("alien.actions.commands")
local create_action = require("alien.actions.action").create_action

local M = {}

local function handle_status_output(output)
  local head = output[1]
  local num_commits_to_pull = output[2]
  local num_commits_to_push = output[3]

  local pull_str = num_commits_to_pull == "0" and "" or "↓" .. num_commits_to_pull
  local push_str = num_commits_to_push == "0" and "" or "↑" .. num_commits_to_push
  for _ = 1, 3 do
    table.remove(output, 1)
  end
  table.insert(output, 1, head .. " " .. pull_str .. push_str)
  return output
end

M.stats_and_status = create_action({
  commands.current_head,
  commands.num_commits_to_pull,
  commands.num_commits_to_push,
  commands.staged_stats,
  commands.status,
}, {
  object_type = "local_file",
  output_handler = handle_status_output,
})

---@param lines string[]
local handle_branch_output = function(lines)
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

M.local_branches = create_action("git branch", { object_type = "local_branch", output_handler = handle_branch_output })
M.stashes = create_action("git stash list", { object_type = "stash" })

return M
