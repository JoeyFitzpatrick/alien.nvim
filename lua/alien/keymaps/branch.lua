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
		local result = vim.fn.system(commands.checkout_branch(branch_name))
		vim.notify(result)
		redraw_branch_buffer()
		require("alien.utils.helpers").reload_named_buffers()
	end)
	map("b", function()
		require("alien.branch").display_branch_picker()
	end)
	map("n", function()
		local line = vim.api.nvim_get_current_line()
		local base_branch = require("alien.branch").get_branch_name_from_line(line)
		vim.ui.input({ prompt = "New branch name: " }, function(input)
			local result = vim.fn.system(commands.new_branch(base_branch, input))
			vim.notify(result)
		end)
		redraw_branch_buffer()
	end)
end

return M
