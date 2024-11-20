--top
local config = require("alien.config")

local M = {}

config.config = vim.tbl_deep_extend("force", config.default_config, vim.g.alien_configuration or {})

M.setup = function()
    require("alien.command-mode").create_git_command()
    require("alien.keymaps").set_global_keymaps()
    require("alien.highlight").setup_highlights()
    require("alien.nested-buffers").setup_nested_buffers()
end

return M
--bottom
