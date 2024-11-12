local keymaps = require("alien.config").config.keymaps.global

local M = {}

M.set_global_keymaps = function()
    vim.keymap.set("n", keymaps.branch_picker, function()
        require("alien.global-actions.global-actions").git_branches()
    end, { noremap = true, silent = true })
end

return M
