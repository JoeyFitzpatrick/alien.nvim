local is_staged = require("alien.status").is_staged
local STATUSES = require("alien.status").STATUSES
local ERROR_CODES = require("alien.actions.error-codes")

---@alias CommandArgs LocalBranch | Commit

local M = {}

--- Create a command string or function that returns a command string.
--- If the command is a function, pass a get_args fn that returns the arguments to the command.
---@param cmd string | (fun(args?: CommandArgs): string)
---@param get_args function | nil
---@param input string | nil
---@param element Element | nil
M.create_command = function(cmd, get_args, input, element)
  if type(cmd) == "string" then
    return cmd
  end
  if not get_args then
    return cmd()
  end
  return function()
    local args = { get_args() }
    if not args or #args == 0 then
      return cmd({}, input)
    end
    table.insert(args, input)
    local unpack = unpack and unpack or table.unpack
    local ok, result = pcall(cmd, unpack(args))
    if ok then
      return result
    elseif element and element.action_args then
      return cmd(element.action_args)
    end
  end
end

--- Logic to add flags to a command string
---@param cmd string
---@param flags string
---@return string
M.add_flags = function(cmd, flags)
  local cmd_with_flags = ""
  local count = 1
  for w in string.gmatch(cmd, "%a+") do
    if count == 1 then
      cmd_with_flags = w
    else
      cmd_with_flags = cmd_with_flags .. " " .. w
    end
    if count == 2 and flags and #flags > 0 then
      cmd_with_flags = cmd_with_flags .. " " .. flags
    end
    count = count + 1
  end
  return cmd_with_flags
end

--- add flags via a UI to a command
---@param cmd string
---@return string
M.add_flags_input = function(cmd)
  local git_verb = cmd:match("%S+%s+(%S+)")
  local cmd_with_flags = ""
  vim.ui.input({ prompt = git_verb .. " flags: " }, function(input)
    cmd_with_flags = M.add_flags(cmd, input)
  end)
  return cmd_with_flags
end

--- Get the arguments to pass to create_command
---@param translate fun(string): table
---@return fun(input: string | nil): (table | fun(): table)
M.get_args = function(translate)
  return function(input)
    if input then
      return function()
        return translate(vim.api.nvim_get_current_line()), input
      end
    end
    return translate(vim.api.nvim_get_current_line())
  end
end

M.status = "git status --porcelain --untracked=all | sort -k1.4"
-- output stats for staged files, or a message if no files are staged
M.staged_stats =
  "git diff --staged --shortstat | grep -q '^' && git diff --staged --shortstat || echo 'No files staged'"
M.current_head = "printf 'HEAD: %s\n' $(git rev-parse --abbrev-ref HEAD)"

---@param branch? string
M.current_remote = function(branch)
  branch = branch or "HEAD"
  return "git rev-parse --symbolic-full-name --abbrev-ref " .. branch .. "@{u}"
end

--- Get the number of commits to pull
---@param branch? string
---@return string
M.num_commits_to_pull = function(branch)
  local current_remote = vim.fn.system(M.current_remote(branch)):gsub("\n", "")
  if vim.v.shell_error == ERROR_CODES.NO_UPSTREAM_ERROR then
    return "echo 0"
  end
  branch = branch or "HEAD"
  return "git rev-list --count " .. branch .. ".." .. current_remote
end

--- Get the number of commits to push
---@param branch? string
---@return string
M.num_commits_to_push = function(branch)
  local current_remote = vim.fn.system(M.current_remote(branch)):gsub("\n", "")
  if vim.v.shell_error == ERROR_CODES.NO_UPSTREAM_ERROR then
    return "echo 0"
  end
  branch = branch or "HEAD"
  return "git rev-list --count " .. current_remote .. ".." .. branch
end

return M
