local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local utils = require("alien.command-mode.utils")

local M = {}

local print_options = {
    "-C",
    "--reuse-message",
    "--squash",
    "--long",
    "--short",
    "--porcelain",
    "-z",
    "--null",
    "-F",
    "--file",
    "-m",
    "--message",
    "--allow-empty",
    "--allow-message",
    "--no-edit",
    "--dry-run",
}

---@param cmd string
---@return DisplayStrategy, DisplayStrategyOpts
M.get_strategy = function(cmd)
    local options = utils.parse_command_options(cmd)
    if utils.overlap(options, print_options) then
        return DISPLAY_STRATEGIES.TERMINAL
    end
    return DISPLAY_STRATEGIES.TERMINAL, { dynamic_resize = false }
end

return M
