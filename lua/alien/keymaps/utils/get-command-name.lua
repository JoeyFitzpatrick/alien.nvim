local M = {}

M.get_command_name = function()
    return require("alien.config").config.command_mode_commands[1]
end

return M
