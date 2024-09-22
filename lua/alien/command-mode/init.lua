local config = require("alien.config")
local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local elements = require("alien.elements")
local create_action = require("alien.actions.action").create_action

local M = {}

local GIT_PREFIXES = { "git", "gitk", "gitweb" }
local PORCELAIN_COMMAND_STRATEGY_MAP = {
  rebase = require("alien.command-mode.display-strategies.rebase").get_strategy,
  branch = require("alien.command-mode.display-strategies.branch").get_strategy,
  show = DISPLAY_STRATEGIES.SHOW,
  help = DISPLAY_STRATEGIES.SHOW,
  grep = DISPLAY_STRATEGIES.SHOW,
  stash = require("alien.command-mode.display-strategies.stash").get_strategy,
  status = require("alien.command-mode.display-strategies.status").get_strategy,
  commit = require("alien.command-mode.display-strategies.commit").get_strategy,
  diff = DISPLAY_STRATEGIES.DIFF,
  log = DISPLAY_STRATEGIES.UI,
  blame = DISPLAY_STRATEGIES.BLAME,
  mergetool = DISPLAY_STRATEGIES.MERGETOOL,
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
  if not strategy then
    return DISPLAY_STRATEGIES.TERMINAL
  end
  if type(strategy) == "string" then
    return strategy
  end
  if type(strategy) == "function" then
    return strategy(cmd)
  end
  return DISPLAY_STRATEGIES.TERMINAL
end

local interceptors = {
  ["git status"] = function()
    elements.buffer(require("alien.actions.base").stats_and_status)
  end,
}

--- Runs the given git command with a command display strategy.
---@param cmd string
M.run_command = function(cmd)
  if interceptors[cmd] then
    interceptors[cmd]()
    return
  end
  local strategy = M.get_command_strategy(cmd)
  local cmd_fn =
    create_action(cmd, { output_handler = require("alien.actions.output-handlers").get_output_handler(cmd) })
  if strategy == DISPLAY_STRATEGIES.TERMINAL then
    elements.terminal(cmd, { enter = true, dynamic_resize = true, window = { split = "below" } })
  elseif strategy == DISPLAY_STRATEGIES.UI then
    elements.buffer(cmd_fn)
  elseif strategy == DISPLAY_STRATEGIES.BLAME then
    require("alien.global-actions.blame").blame()
  elseif strategy == DISPLAY_STRATEGIES.MERGETOOL then
    elements.terminal(cmd + " --tool=nvimdiff", { enter = true, window = { split = "below" } })
  elseif strategy == DISPLAY_STRATEGIES.SHOW then
    local bufnr = elements.buffer(cmd_fn)
    vim.api.nvim_set_option_value("filetype", "git", { buf = bufnr })
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
        complete = function(arglead, cmdline)
          return require("alien.command-mode.completion").complete_git_command(arglead, cmdline)
        end,
      }
    )
  end
end

return M
