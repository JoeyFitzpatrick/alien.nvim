local M = {}

M.highlight = function(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for i in ipairs(lines) do
		vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienCommitFile", i - 1, 0, -1)
	end
end

return M
