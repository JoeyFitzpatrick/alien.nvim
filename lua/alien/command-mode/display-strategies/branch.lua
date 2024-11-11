local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local utils = require("alien.command-mode.utils")

local M = {}

local interactive_options = {
    "--edit-description",
}

local ui_options = {
    "--color",
    "--no-color",
    "-i",
    "--ignore-case",
    "--omit-empty",
    "--no-column",
    "-r",
    "--remotes",
    "-a",
    "--all",
    "-l",
    "--list",
    "-v",
    "-vv",
    "--verbose",
    "--abbrev",
    "--no-abbrev",
    "--contains",
    "--no-contains",
    "--merged",
    "--no-merged",
    "--sort",
    "--points-at",
    "--format",
}

---@param cmd string
---@return DisplayStrategy
M.get_strategy = function(cmd)
    local options = utils.parse_command_options(cmd)
    if #options == 0 then
        return DISPLAY_STRATEGIES.UI
    end
    if utils.overlap(options, ui_options) then
        return DISPLAY_STRATEGIES.UI
    end
    if utils.overlap(options, interactive_options) then
        return DISPLAY_STRATEGIES.INTERACTIVE_BRANCH
    end
    return DISPLAY_STRATEGIES.PRINT
end

return M
