local M = {}
M.open_unmod_tab = function(callback)
	-- Create a new tab
	vim.cmd("tabnew")

	callback()
	-- Get the current buffer number
	local bufnr = vim.api.nvim_get_current_buf()

	-- Make the buffer unmodifiable
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = bufnr })

	-- Don't ask to save when closing
	vim.api.nvim_buf_set_option(bufnr, "bufhidden", "hide")

	-- Additional settings could be set here if needed
end
return M
