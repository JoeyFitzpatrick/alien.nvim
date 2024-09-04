local keymaps = require("alien.config").keymaps.global
local global_actions = require("alien.global-actions.global-actions")

local M = {}

M.set_global_keymaps = function()
  vim.keymap.set("n", keymaps.branch_picker, global_actions.git_branches, { noremap = true, silent = true })
end

return M
