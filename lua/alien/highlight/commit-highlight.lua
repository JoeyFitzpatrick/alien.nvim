local translate = require("alien.translators.commit-translator").translate

local M = {}

M.highlight = function(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for i, line in ipairs(lines) do
		local commit = translate(line)
		if commit then
			print("hello")
			vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienCommitHash", i - 1, commit.start, commit.ending)
		end
	end
end

return M
