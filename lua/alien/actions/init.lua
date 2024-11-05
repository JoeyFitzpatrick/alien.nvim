local commands = require("alien.actions.commands")
local register = require("alien.elements.register")
local get_translator = require("alien.translators").get_translator

local M = {}

---@class ActionResult
---@field output string[]
---@field object_type AlienObject

---@alias Action fun(): (ActionResult | nil)
---@alias MultiAction { actions: Action[], object_type: AlienObject }
---@alias AlienCommand string | fun(): string

---@class AlienOpts
---@field object_type AlienObject|nil
---@field trigger_redraw boolean|nil
---@field error_callbacks table<integer, function>|nil
---@field output_handler nil|fun(output: string[]):string[]
---@field input string|nil

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
    local output = handle_output(require("alien.utils").run_cmd(parsed_command, opts.error_callbacks))
    redraw()
    return {
      output = output,
      object_type = object_type or require("alien.objects").get_object_type(parsed_command),
    }
  end
end

--- Create an action with just a command (string or function)
---@param cmd string | fun(object: table, input: string | nil): string
---@param opts AlienOpts | nil
M.action = function(cmd, opts)
  opts = opts or {}
  local input = opts.input
  local current_element = register.get_current_element()
  local current_object_type = current_element and current_element.object_type or opts.object_type
  local translate = get_translator(current_object_type)
  local get_args = translate and commands.get_args(translate) or nil
  local command = commands.create_command(cmd, get_args, input, current_element)
  local action_fn = M.create_action(command, opts)
  return action_fn()
end

return M
