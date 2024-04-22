local window = require("alien.window")

local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local delete_non_alien_mappings = function(str)
	local bufnr = vim.api.nvim_get_current_buf()
	local keymaps = vim.api.nvim_buf_get_keymap(bufnr, "n")
	for _, keymap in pairs(keymaps) do
		if string.sub(keymap["lhs"], 1, string.len(str)) == str then
			vim.api.nvim_buf_del_keymap(bufnr, "n", keymap["lhs"])
		end
	end
end

local M = {}
M.mappings = {
	{ "q", "<cmd>tabclose<CR>" },
	{ "l", window.open_next_buffer },
	{ "h", window.open_previous_buffer },
}
M.map = function(lhs, rhs)
	table.insert(M.mappings, { lhs, rhs })
end
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

M.set_keymaps = function()
	local bufnr = vim.api.nvim_get_current_buf()
	delete_non_alien_mappings("<space>")
	for _, mapping in pairs(M.mappings) do
		local lhs = mapping[1]
		local rhs = mapping[2]
		delete_non_alien_mappings(lhs)
		vim.keymap.set("n", lhs, rhs, keymap_opts(bufnr))
	end
end

return M
