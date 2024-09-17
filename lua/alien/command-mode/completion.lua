local constants = require("alien.command-mode.constants")

local M = {}

---@return string[]
local function base_subcommands()
  return constants.BASE_COMMANDS
end

---@param subcommand string
---@return
local function subcommand_flags(subcommand)
  return constants.SUBCOMMAND_FLAGS[subcommand]
end

local function get_subcommand(cmdline)
  local words = {}
  for word in cmdline:gmatch("%S+") do
    table.insert(words, word)
  end
  return words[2]
end

local function get_arguments(subcommand)
  local SUBCOMMAND_TO_ARGUMENTS_MAP = {
    checkout = "git for-each-ref --format='%(refname:short)' refs/heads/",
    switch = "git for-each-ref --format='%(refname:short)' refs/heads/",
  }
  local cmd = SUBCOMMAND_TO_ARGUMENTS_MAP[subcommand]
  if not cmd then
    return {}
  end
  return vim.fn.systemlist(cmd)
end

--- takes an arbitrary git command, and returns completion options
---@param arglead string
---@param cmdline string
---@return string[]
M.complete_git_command = function(arglead, cmdline)
  local space_count = 0
  for _ in string.gmatch(cmdline, " ") do
    space_count = space_count + 1
  end
  if space_count == 1 then
    return base_subcommands()
  end
  if space_count > 1 then
    local subcommand = get_subcommand(cmdline)
    if arglead:sub(1, 1) == "-" then
      return subcommand_flags(subcommand)
    end
    return get_arguments(subcommand)
  end
  return { arglead, cmdline }
end

return M
