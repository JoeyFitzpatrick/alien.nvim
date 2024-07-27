local M = {}

M.highlight = function(bufnr)
	vim.api.nvim_set_option_value("filetype", "git", { buf = bufnr })
end

return M
