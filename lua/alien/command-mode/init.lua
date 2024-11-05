local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local utils = require("alien.command-mode.utils")
local elements = require("alien.elements")
local register = elements.register
local run_action = require("alien.actions").run_action

---@alias DisplayStrategyOpts { dynamic_resize?: boolean } | nil

local M = {}

local GIT_PREFIXES = { "git", "gitk", "gitweb" }
local PORCELAIN_COMMAND_STRATEGY_MAP = {
  add = DISPLAY_STRATEGIES.PRINT,
  blame = DISPLAY_STRATEGIES.BLAME,
  branch = require("alien.command-mode.display-strategies.branch").get_strategy,
  commit = require("alien.command-mode.display-strategies.commit").get_strategy,
  diff = DISPLAY_STRATEGIES.DIFF,
  grep = DISPLAY_STRATEGIES.SHOW,
  help = DISPLAY_STRATEGIES.SHOW,
  log = DISPLAY_STRATEGIES.UI,
  merge = require("alien.command-mode.display-strategies.merge").get_strategy,
  mergetool = DISPLAY_STRATEGIES.MERGETOOL,
  notes = require("alien.command-mode.display-strategies.notes").get_strategy,
  rebase = require("alien.command-mode.display-strategies.rebase").get_strategy,
  show = DISPLAY_STRATEGIES.SHOW,
  stash = require("alien.command-mode.display-strategies.stash").get_strategy,
  status = require("alien.command-mode.display-strategies.status").get_strategy,
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
---@return string, DisplayStrategyOpts
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

---@param cmd string
local function print_output(cmd)
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(output, vim.log.levels.ERROR)
  else
    vim.notify(output, vim.log.levels.INFO)
  end
  register.redraw_elements()
end

local literal_commands = {
  ["git status"] = function()
    require("alien.actions.special_actions").stats_and_status()
  end,
}

local patterns = {
  ["^git log %-L"] = function(cmd, input_args)
    if utils.is_visual_range(input_args) then
      return cmd .. input_args.line1 .. "," .. input_args.line2 .. ":" .. vim.api.nvim_buf_get_name(0)
    end
    return cmd
  end,
}

---@param cmd string
---@param input_args { line1?: integer, line2?: integer, range?: integer }
---@return boolean, string
local intercept = function(cmd, input_args)
  if literal_commands[cmd] then
    literal_commands[cmd]()
    return false, cmd
  end
  cmd = utils.populate_filename(cmd)
  for pattern, fn in pairs(patterns) do
    if cmd:find(pattern) then
      cmd = fn(cmd, input_args)
      return true, cmd
    end
  end
  return true, cmd
end

--- Runs the given git command with a command display strategy.
---@param cmd string
---@param input_args { line1?: integer, line2?: integer, range?: integer }
M.run_command = function(cmd, input_args)
  local should_continue, new_cmd = intercept(cmd, input_args)
  if not should_continue then
    return
  end
  cmd = new_cmd
  local strategy, custom_opts = M.get_command_strategy(cmd)
  local output_handler_fn = require("alien.actions.output-handlers").get_output_handler(cmd)
  local output_handler = output_handler_fn and { output_handler = output_handler_fn } or nil
  if strategy == DISPLAY_STRATEGIES.TERMINAL then
    local default_opts = { enter = true, dynamic_resize = true, window = { split = "below" } }
    local opts = vim.tbl_deep_extend("force", default_opts, custom_opts or {})
    elements.terminal(cmd, opts)
  elseif strategy == DISPLAY_STRATEGIES.PRINT then
    print_output(cmd)
  elseif strategy == DISPLAY_STRATEGIES.UI then
    elements.buffer(cmd, output_handler)
  elseif strategy == DISPLAY_STRATEGIES.BLAME then
    require("alien.global-actions.blame").blame(cmd)
  elseif strategy == DISPLAY_STRATEGIES.SHOW then
    local show_cmd = cmd .. " | col -b"
    elements.buffer(
      show_cmd,
      { output_handler = require("alien.actions.output-handlers").get_output_handler(show_cmd) }
    )
  end
end

--- Set up Git command with given commands. Note that the command comes from the config, and does not have to be "Git".
function M.create_git_command()
  for _, command in pairs(require("alien.config").config.command_mode_commands) do
    vim.api.nvim_create_user_command(
      command, -- Command name, e.g. "Git", "G"
      function(input_args)
        local args = input_args.args
        local git_command = "git " .. args
        M.run_command(git_command, input_args)
      end,
      {
        nargs = "+", -- Require at least one argument
        complete = function(arglead, cmdline)
          local completion = require("alien.command-mode.completion").complete_git_command(arglead, cmdline)
          return vim.tbl_filter(function(val)
            return vim.startswith(val, arglead)
          end, completion)
        end,
        range = true,
      }
    )
  end
end

return M
