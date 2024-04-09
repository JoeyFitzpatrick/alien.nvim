local M = {}
M.redraw_status_buffer = function()
	local set_lines = require("alien.status").get_status_lines()
	vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_get_current_buf() })
	set_lines()
	vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_get_current_buf() })
end
M.set_status_buffer_keymaps = function(bufnr)
	vim.keymap.set("n", "q", ":q<CR>", { buffer = bufnr, noremap = true, silent = true })
	vim.keymap.set("n", "a", function()
		vim.fn.system(require("alien.commands").stage_or_unstage_all())
		M.redraw_status_buffer()
	end, { buffer = bufnr, noremap = true, silent = true })
	vim.keymap.set("n", "<space>", function()
		local file = require("alien.utils").get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end

		vim.fn.system(require("alien.commands").stage_or_unstage_file(file.status, file.filename))
		M.redraw_status_buffer()
	end, { buffer = bufnr })
end

return M
