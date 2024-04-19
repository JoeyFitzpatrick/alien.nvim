local window = require("alien.window")

local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local M = {}
M.redraw_status_buffer = function()
	local buffer_args = require("alien.status").get_buffer_args()
	vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_get_current_buf() })
	buffer_args.set_lines()
	buffer_args.set_colors()
	vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_get_current_buf() })
end
M.redraw_branch_buffer = function()
	local buffer_args = require("alien.branch").get_buffer_args()
	vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_get_current_buf() })
	buffer_args.set_lines()
	buffer_args.set_colors()
	vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_get_current_buf() })
end
M.set_general_keymaps = function(bufnr)
	local map = function(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, keymap_opts(bufnr))
	end
	map("q", "<cmd>tabclose<CR>")
	map("l", window.open_next_buffer)
	map("h", window.open_previous_buffer)
end

return M
