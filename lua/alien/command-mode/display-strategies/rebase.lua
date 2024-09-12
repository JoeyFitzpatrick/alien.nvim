local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES

local M = {}

local interactive_options = {
  "-i",
  "--interactive",
  "--edit-todo",
}

---@param cmd string
---@return DisplayStrategy
M.get_strategy = function(cmd)
  return DISPLAY_STRATEGIES.PRINT
end

return M
