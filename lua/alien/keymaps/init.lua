local commands = require("alien.commands")
local utils = require("alien.utils")
local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local M = {}
M.redraw_status_buffer = function()
	local set_lines = require("alien.status").get_status_lines()
	vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_get_current_buf() })
	set_lines()
	vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_get_current_buf() })
end
M.set_status_buffer_keymaps = function(bufnr)
	vim.keymap.set("n", "q", ":q<CR>", keymap_opts(bufnr))
	vim.keymap.set("n", "a", function()
		vim.fn.system(commands.stage_or_unstage_all())
		M.redraw_status_buffer()
	end, keymap_opts(bufnr))
	vim.keymap.set("n", "s", function()
		local file = utils.get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end

		vim.fn.system(commands.stage_or_unstage_file(file.status, file.filename))
		M.redraw_status_buffer()
	end, keymap_opts(bufnr))
end

return M
