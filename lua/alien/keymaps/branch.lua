local commands = require("alien.commands")
local window = require("alien.window")
local diff = require("alien.status.diff")
local redraw_branch_buffer = require("alien.keymaps").redraw_branch_buffer

local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local M = {}
M.set_status_buffer_keymaps = function(bufnr)
	require("alien.keymaps").set_general_keymaps(bufnr)
	local map = function(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, keymap_opts(bufnr))
	end
	map("<space>", function()
		local line = vim.api.nvim_get_current_line()
		local branch_name = require("alien.branch").get_branch_name_from_line(line)
		local result = vim.fn.system(commands.checkout_local_branch(branch_name))
		vim.notify(result)
	end)
end

return M
