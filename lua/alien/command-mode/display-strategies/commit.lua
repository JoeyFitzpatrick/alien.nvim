local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES

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
---@return DisplayStrategy
M.get_strategy = function(cmd)
    return DISPLAY_STRATEGIES.PRINT
end

return M
