local M = {}
M.set_status_buffer_keymaps = function(bufnr)
	vim.keymap.set("n", "q", ":q<CR>", { buffer = bufnr, noremap = true, silent = true })
	vim.keymap.set("n", "a", function()
		vim.fn.system(require("alien.commands").stage_or_unstage_all())
		local set_lines = require("alien.status").get_status_lines()
		vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
		set_lines()
		vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
	end, { buffer = bufnr, noremap = true, silent = true })
	vim.keymap.set("n", "<space>", function()
		local file = require("alien.utils").get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end
		vim.print(file.filename)
		-- print(file.filename, file.status)
	end, { buffer = bufnr })
end

return M
