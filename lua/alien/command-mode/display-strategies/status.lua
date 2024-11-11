local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local utils = require("alien.command-mode.utils")

local M = {}

---@param cmd string
---@return DisplayStrategy
M.get_strategy = function(cmd)
    local options = utils.parse_command_options(cmd)
    if #options == 0 then
        return DISPLAY_STRATEGIES.UI
    end
    return DISPLAY_STRATEGIES.PRINT
end

return M
