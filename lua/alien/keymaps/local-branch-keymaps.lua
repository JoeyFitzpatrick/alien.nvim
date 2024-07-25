local local_branch = require("alien.objects.local-branch-object")
local keymaps = require("alien.config").keymaps.local_branch
local map = require("alien.keymaps").map

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	map(keymaps.switch, local_branch.switch, opts)
	map(keymaps.new_branch, local_branch.new_branch, opts)
	map(keymaps.delete, local_branch.delete, opts)
	map(keymaps.rename, local_branch.rename, opts)
	map(keymaps.merge, local_branch.merge, opts)
	map(keymaps.rebase, local_branch.rebase, opts)
end

return M
