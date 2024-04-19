local window = require("alien.window")

local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local M = {}
M.redraw_status_buffer = function()
	local buffer_args = require("alien.status").get_buffer_args()
	vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_get_current_buf() })
	buffer_args.set_lines()
	vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_get_current_buf() })
end
M.set_general_keymaps = function(bufnr)
	local map = function(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, keymap_opts(bufnr))
	end
	map("q", "<cmd>tabclose<CR>")
	map("l", function()
		local buffer_type = vim.api.nvim_buf_get_var(bufnr, require("alien.window.constants").ALIEN_BUFFER_TYPE)
		local next_buffer_type = window.get_next_buffer_type(buffer_type)
		window.open_window(next_buffer_type)
	end)
end

return M
