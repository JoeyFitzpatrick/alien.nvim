local M = {}

--- Adds Delta-like highlighting to the diff output in the buffer
---@param bufnr number
M.highight_diff_output = function(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for i, line in ipairs(lines) do
		if line:sub(1, 1) == "+" then
			vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienDiffNew", i - 1, 0, -1)
		elseif line:sub(1, 1) == "-" then
			vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienDiffOld", i - 1, 0, -1)
		end
	end
end

return M
