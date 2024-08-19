local get_object_type = require("alien.objects").get_object_type
local commands = require("alien.actions.commands")
local register = require("alien.elements.register")
local get_translator = require("alien.translators").get_translator

local M = {}

---@alias Action fun(): { output: string[], object_type: AlienObject, action_args: table }
---@alias MultiAction { actions: Action[], object_type: AlienObject }
---@alias AlienCommand string | fun(): string
---@alias AlienOpts { object_type: AlienObject | nil, trigger_redraw: boolean | nil, add_flags: boolean | nil, action_args: table, output_handler: nil | fun(output: string[]): string[], input: function | nil  }

--- Run a command, with side effects, such as displaying errors
---@param cmd string
---@return string[]
local run_cmd = function(cmd)
  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(table.concat(output, "\n"), vim.log.levels.ERROR)
  end
  return output
end

--- Return the output of multiple commands
--- If one of the commands is itself an array, the outputs of the commands in the array will be concatenated on a single line
---@param cmds AlienCommand[]
---@return string[]
local function get_multiple_outputs(cmds)
  local output = {}
  for _, c in ipairs(cmds) do
    if type(c) == "string" then
      for _, line in ipairs(run_cmd(c)) do
        table.insert(output, line)
      end
    end
    if type(c) == "function" then
      for _, line in ipairs(run_cmd(c())) do
        table.insert(output, line)
      end
    end
  end
  return output
end

--- Parses a command from an AlienCommand, which is a very lenient data type
---@param alien_command AlienCommand
---@param add_flags boolean | nil
---@return string
M.parse_command = function(alien_command, add_flags)
  local cmd = nil
  if type(alien_command) == "function" then
    cmd = alien_command()
  else
    cmd = alien_command
  end
  if add_flags then
    cmd = commands.add_flags_input(cmd)
  end
  return cmd
end

--- Takes a command and returns an Action function
---@param cmd AlienCommand | AlienCommand[]
---@param opts AlienOpts | nil
---@return Action
M.create_action = function(cmd, opts)
  opts = opts or {}
  local object_type = opts.object_type
  local redraw = function()
    if opts.trigger_redraw then
      require("alien.elements.register").redraw_elements()
    end
  end
  local handle_output = function(output)
    if opts.output_handler then
      return opts.output_handler(output)
    end
    return output
  end
  return function()
    if type(cmd) == "table" then
      ---@type string[]
      local output = get_multiple_outputs(cmd)
      redraw()
      return { output = handle_output(output), object_type = object_type, action_args = opts.action_args }
    end
    local parsed_command = M.parse_command(cmd, opts.add_flags)
    local output = handle_output(run_cmd(parsed_command))
    redraw()
    return {
      output = output,
      object_type = object_type or get_object_type(parsed_command),
      action_args = opts.action_args,
    }
  end
end

--- Create an action with just a command (string or function)
---@param cmd string | fun(object: table, input: string | nil): string
---@param opts AlienOpts | nil
M.action = function(cmd, opts)
  return function(input)
    opts = opts or {}
    local current_element = register.get_current_element()
    local current_object_type = current_element and current_element.object_type or nil
    local translate = get_translator(current_object_type)
    local get_args = nil
    if translate then
      get_args = commands.get_args(translate)
    end
    local command = commands.create_command(cmd, get_args, input, current_element)
    if get_args then
      local action_args = get_args(input)
      if type(action_args) == "function" then
        action_args = action_args()
      end
      local combined_args = vim.tbl_extend("force", opts.action_args or {}, action_args or {})
      opts.action_args = combined_args
    end
    local action_fn = M.create_action(command, opts)
    return action_fn()
  end
end

--- Create a composite action with multiple commands
---@param cmds string[] | fun(object: table)[]: string
---@param opts AlienOpts | nil
M.composite_action = function(cmds, opts)
  return function()
    local output = {}
    local object_type = nil
    for _, cmd in ipairs(cmds) do
      local action_fn = M.action(cmd, opts)
      local result = action_fn()
      object_type = result.object_type
      for _, line in ipairs(result.output) do
        table.insert(output, line)
      end
    end
    return { output = output, object_type = object_type }
  end
end

return M
