local local_branch = require("alien.objects.local-branch-object")
local keymaps = require("alien.config").keymaps.local_branch

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	local map = function(keys, fn)
		vim.keymap.set("n", keys, function()
			fn()
		end, opts)
	end
	map(keymaps.switch, local_branch.switch)
	map(keymaps.new_branch, local_branch.new_branch)
	map(keymaps.delete, local_branch.delete)
	map(keymaps.rename, local_branch.rename)
	map(keymaps.merge, local_branch.merge)
	map(keymaps.rebase, local_branch.rebase)
end

return M
