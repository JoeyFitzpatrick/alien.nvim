local config = require("alien.config")
local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local elements = require("alien.elements")
local create_action = require("alien.actions.action").create_action

local M = {}

local GIT_PREFIXES = { "git", "gitk", "gitweb" }
local PORCELAIN_COMMAND_STRATEGY_MAP = {
  add = DISPLAY_STRATEGIES.PRINT,
  rebase = require("alien.command-mode.display-strategies.rebase").get_strategy,
  cherry = DISPLAY_STRATEGIES.PRINT,
  am = DISPLAY_STRATEGIES.PRINT,
  reset = DISPLAY_STRATEGIES.PRINT,
  ["count-objects"] = DISPLAY_STRATEGIES.PRINT,
  archive = DISPLAY_STRATEGIES.PRINT,
  revert = DISPLAY_STRATEGIES.PRINT,
  difftool = DISPLAY_STRATEGIES.PRINT,
  bisect = DISPLAY_STRATEGIES.PRINT,
  rm = DISPLAY_STRATEGIES.PRINT,
  fsck = DISPLAY_STRATEGIES.PRINT,
  branch = require("alien.command-mode.display-strategies.branch").get_strategy,
  shortlog = DISPLAY_STRATEGIES.PRINT,
  ["get-tar-commit-id"] = DISPLAY_STRATEGIES.PRINT,
  bundle = DISPLAY_STRATEGIES.PRINT,
  show = DISPLAY_STRATEGIES.SHOW,
  help = DISPLAY_STRATEGIES.SHOW,
  checkout = DISPLAY_STRATEGIES.PRINT,
  stash = require("alien.command-mode.display-strategies.stash").get_strategy,
  instaweb = DISPLAY_STRATEGIES.PRINT,
  ["cherry-pick"] = DISPLAY_STRATEGIES.PRINT,
  status = DISPLAY_STRATEGIES.UI,
  ["merge-tree"] = DISPLAY_STRATEGIES.PRINT,
  citool = DISPLAY_STRATEGIES.PRINT,
  submodule = DISPLAY_STRATEGIES.PRINT,
  rerere = DISPLAY_STRATEGIES.PRINT,
  clean = DISPLAY_STRATEGIES.PRINT,
  tag = DISPLAY_STRATEGIES.PRINT,
  ["rev-parse"] = DISPLAY_STRATEGIES.PRINT,
  clone = DISPLAY_STRATEGIES.PRINT,
  worktree = DISPLAY_STRATEGIES.PRINT,
  ["show-branch"] = DISPLAY_STRATEGIES.PRINT,
  commit = require("alien.command-mode.display-strategies.commit").get_strategy,
  ["verify-commit"] = DISPLAY_STRATEGIES.PRINT,
  describe = DISPLAY_STRATEGIES.PRINT,
  config = DISPLAY_STRATEGIES.PRINT,
  ["verify-tag"] = DISPLAY_STRATEGIES.PRINT,
  diff = DISPLAY_STRATEGIES.DIFF,
  ["fast-export"] = DISPLAY_STRATEGIES.PRINT,
  whatchanged = DISPLAY_STRATEGIES.PRINT,
  fetch = DISPLAY_STRATEGIES.PRINT,
  ["fast-import"] = DISPLAY_STRATEGIES.PRINT,
  ["format-patch"] = DISPLAY_STRATEGIES.PRINT,
  ["filter-branch"] = DISPLAY_STRATEGIES.PRINT,
  archimport = DISPLAY_STRATEGIES.PRINT,
  gc = DISPLAY_STRATEGIES.PRINT,
  mergetool = DISPLAY_STRATEGIES.PRINT,
  cvsexportcommit = DISPLAY_STRATEGIES.PRINT,
  grep = DISPLAY_STRATEGIES.PRINT,
  ["pack-refs"] = DISPLAY_STRATEGIES.PRINT,
  cvsimport = DISPLAY_STRATEGIES.PRINT,
  gui = DISPLAY_STRATEGIES.PRINT,
  prune = DISPLAY_STRATEGIES.PRINT,
  cvsserver = DISPLAY_STRATEGIES.PRINT,
  init = DISPLAY_STRATEGIES.PRINT,
  reflog = DISPLAY_STRATEGIES.PRINT,
  ["imap-send"] = DISPLAY_STRATEGIES.PRINT,
  log = DISPLAY_STRATEGIES.UI,
  relink = DISPLAY_STRATEGIES.PRINT,
  p4 = DISPLAY_STRATEGIES.PRINT,
  merge = DISPLAY_STRATEGIES.PRINT,
  remote = DISPLAY_STRATEGIES.PRINT,
  quiltimport = DISPLAY_STRATEGIES.PRINT,
  mv = DISPLAY_STRATEGIES.PRINT,
  repack = DISPLAY_STRATEGIES.PRINT,
  ["request-pull"] = DISPLAY_STRATEGIES.PRINT,
  notes = DISPLAY_STRATEGIES.PRINT,
  replace = DISPLAY_STRATEGIES.PRINT,
  ["send-email"] = DISPLAY_STRATEGIES.PRINT,
  pull = DISPLAY_STRATEGIES.PRINT,
  annotate = DISPLAY_STRATEGIES.PRINT,
  svn = DISPLAY_STRATEGIES.PRINT,
  push = DISPLAY_STRATEGIES.PRINT,
  blame = DISPLAY_STRATEGIES.BLAME,
}

--- Takes a git command, and returns the git verb.
---@param cmd string
---@return string
M.get_subcommand = function(cmd)
  local first_word = cmd:match("%w+")
  if not first_word or not vim.tbl_contains(GIT_PREFIXES, first_word) then
    error("Error: called parse with a non-git command")
  end
  local second_word = cmd:match("%S+%s+(%S+)")
  if not second_word then
    error("Error: no subcommand passed to git commmand")
  end
  return second_word
end

--- Get the command strategy for a given command.
---@param cmd string
---@return string
M.get_command_strategy = function(cmd)
  local subcommand = M.get_subcommand(cmd)
  local strategy = PORCELAIN_COMMAND_STRATEGY_MAP[subcommand]
  if type(strategy) == "string" then
    return strategy
  else
    return strategy(cmd)
  end
end

local print_cmd = function(cmd)
  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(table.concat(output, "\n"), vim.log.levels.ERROR)
  else
    vim.print(output)
  end
end

--- Runs the given git command with a command display strategy.
---@param cmd string
M.run_command = function(cmd)
  local strategy = M.get_command_strategy(cmd)
  local cmd_fn =
    create_action(cmd, { output_handler = require("alien.actions.output-handlers").get_output_handler(cmd) })
  if strategy == DISPLAY_STRATEGIES.PRINT then
    print_cmd(cmd)
  elseif strategy == DISPLAY_STRATEGIES.UI then
    elements.buffer(cmd_fn)
  end
end

function M.create_git_command()
  for _, command in pairs(config.command_mode_commands) do
    vim.api.nvim_create_user_command(
      command, -- Command name, e.g. "Git", "G"
      function(input_args)
        local args = input_args.args
        local git_command = "git " .. args
        M.run_command(git_command)
      end,
      {
        nargs = "+", -- Require at least one argument
        complete = function(ArgLead, CmdLine, CursorPos)
          -- Optionally, you can implement completions here
          return { "status", "add", "commit", "push", "pull", "clone" } -- Example completions
        end,
      }
    )
  end
end

return M
