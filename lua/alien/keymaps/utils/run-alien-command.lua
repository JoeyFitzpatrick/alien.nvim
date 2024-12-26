local M = {}

---@param cmd string
M.run_alien_command = function(cmd)
    local alien_command_name = require("alien.keymaps.utils.get-command-name").get_command_name()
    vim.cmd(alien_command_name .. " " .. cmd)
end

return M
