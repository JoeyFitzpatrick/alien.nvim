local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local utils = require("alien.command-mode.utils")

local M = {}

local ui_options = {
    "list",
}

---@param cmd string
---@return DisplayStrategy
M.get_strategy = function(cmd)
    local options = utils.parse_command_options(cmd)
    if utils.overlap(options, ui_options) then
        return DISPLAY_STRATEGIES.UI
    end
    return DISPLAY_STRATEGIES.TERMINAL
end

return M
