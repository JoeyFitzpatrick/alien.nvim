local local_branch = require("alien.objects.local-branch-object")
local elements = require("alien.elements")
local keymaps = require("alien.config").keymaps.local_branch
local commands = require("alien.actions.commands")

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	local map = function(keys, fn)
		vim.keymap.set("n", keys, function()
			fn()
		end, opts)
	end
	map(keymaps.switch, local_branch.switch)
end

return M
