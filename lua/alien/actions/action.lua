local commands = require("alien.actions.commands")
local register = require("alien.elements.register")
local get_translator = require("alien.translators").get_translator

local M = {}

---@alias Action fun(): ({ output: string[], object_type: AlienObject, action_args: table } | nil)
---@alias MultiAction { actions: Action[], object_type: AlienObject }
---@alias AlienCommand string | fun(): string
---@alias AlienOpts { object_type: AlienObject | nil, trigger_redraw: boolean | nil, action_args: table, error_callbacks: table<integer, function> | nil, output_handler: nil | fun(output: string[]): string[], input: function | nil  }

--- Run a command, with side effects, such as displaying errors
---@param cmd string
---@param error_callbacks? table<integer, function>
---@return string[]
M.run_cmd = function(cmd, error_callbacks)
  if cmd == "" then
    return {}
  end
  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    if error_callbacks and error_callbacks[vim.v.shell_error] then
      error_callbacks[vim.v.shell_error](cmd)
    else
      vim.notify(table.concat(output, "\n"), vim.log.levels.ERROR)
    end
  end
  return output
end

--- Parses a command from an AlienCommand (string | function)
---@param alien_command AlienCommand
---@return string
M.parse_command = function(alien_command)
  local cmd = nil
  if type(alien_command) == "function" then
    cmd = alien_command()
  else
    cmd = alien_command
  end
  return cmd
end

--- Takes a command and returns an Action function
---@param cmd AlienCommand
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
    local ok, parsed_command = pcall(M.parse_command, cmd)
    if not ok then
      return nil
    end
    local output = handle_output(M.run_cmd(parsed_command, opts.error_callbacks))
    redraw()
    return {
      output = output,
      object_type = object_type or require("alien.objects").get_object_type(parsed_command),
      action_args = opts.action_args,
    }
  end
end

--- Create an action with just a command (string or function)
---@param cmd string | fun(object: table, input: string | nil): string
---@param opts AlienOpts | nil
M.action = function(cmd, opts)
  local input = nil
  opts = opts or {}
  local current_element = register.get_current_element()
  local current_object_type = current_element and current_element.object_type or opts.object_type
  local translate = get_translator(current_object_type)
  local get_args = translate and commands.get_args(translate) or nil
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
      if not result then
        goto continue
      end
      object_type = result.object_type
      for _, line in ipairs(result.output) do
        table.insert(output, line)
      end
      ::continue::
    end
    return { output = output, object_type = object_type }
  end
end

return M
