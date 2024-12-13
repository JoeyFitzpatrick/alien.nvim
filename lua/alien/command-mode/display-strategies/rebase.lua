local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local utils = require("alien.command-mode.utils")

local M = {}

local interactive_options = {
    "-i",
    "--interactive",
}

---@param cmd string
---@return DisplayStrategy, DisplayStrategyOpts
M.get_strategy = function(cmd)
    local options = utils.parse_command_options(cmd)
    if utils.overlap(options, interactive_options) then
        return DISPLAY_STRATEGIES.TERMINAL, { dynamic_resize = false }
    end
    return DISPLAY_STRATEGIES.TERMINAL
end

return M
