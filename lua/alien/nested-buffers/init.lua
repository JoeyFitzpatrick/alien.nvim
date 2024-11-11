local constants = require("alien.nested-buffers.constants")

local M = {}

M.setup_nested_buffers = function()
    local in_terminal_buffer = (os.getenv(constants.alien_pipe_path_host_env_var) ~= nil)

    if in_terminal_buffer then
        require("alien.nested-buffers.client")
    else
        require("alien.nested-buffers.server")
    end
end

return M
