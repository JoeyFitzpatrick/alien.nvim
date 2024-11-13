local M = {}

M.get_alien_command = function(command)
    local alien_command_name = require("alien.config").config.command_mode_commands[1]
    return "<cmd>" .. alien_command_name .. " " .. command .. "<CR>"
end

return M
