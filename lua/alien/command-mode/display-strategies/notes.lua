local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES

local M = {}

---@param cmd string
---@return DisplayStrategy, DisplayStrategyOpts
M.get_strategy = function(cmd)
    return DISPLAY_STRATEGIES.TERMINAL_INSERT
end

return M
