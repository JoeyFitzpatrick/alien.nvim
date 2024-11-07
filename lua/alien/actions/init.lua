local commands = require("alien.actions.commands")
local register = require("alien.elements.register")
local get_translator = require("alien.translators").get_translator

local M = {}

---@class ActionResult
---@field output string[]
---@field object_type AlienObject

---@alias Action fun(): (ActionResult | nil)
---@alias AlienCommand string | fun(): string

---@class AlienOpts: BaseOpts
---@field trigger_redraw boolean|nil
---@field error_callbacks table<integer, function>|nil
---@field output_handler nil|fun(output: string[]):string[]
---@field input string|nil

--- Converts an AlienCommand (string | function) to a string if it is a function
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
---@return ActionResult | nil
M.run_action = function(cmd, opts)
  opts = opts or {}
  local ok, parsed_command = pcall(M.parse_command, cmd)
  if not ok then
    return nil
  end
  local output = require("alien.utils").run_cmd(parsed_command, opts.error_callbacks)
  if opts.output_handler then
    output = opts.output_handler(output)
  end
  if opts.trigger_redraw then
    require("alien.elements.register").redraw_elements()
  end
  return {
    output = output,
    object_type = opts.object_type or require("alien.objects").get_object_type(parsed_command),
  }
end

--- Create an action with just a command (string or function)
---@param cmd string | fun(object: table, input: string | nil): string
---@param opts AlienOpts | BaseOpts |  nil
---@return ActionResult | nil
M.action = function(cmd, opts)
  ---@cast opts AlienOpts
  opts = opts or {}
  local input = opts.input
  local current_element = register.get_current_element()
  local current_object_type = current_element and current_element.object_type or opts.object_type
  local translate = get_translator(current_object_type)
  local get_args = translate and commands.get_args(translate) or nil
  local command = commands.create_command(cmd, get_args, input, current_element)
  return M.run_action(command, opts)
end

return M
