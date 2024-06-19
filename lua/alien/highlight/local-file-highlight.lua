---@alias Position { start: number, ending: number }

local M = {}

M.highlight = function(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for i, line in ipairs(lines) do
		local local_file = require("alien.translators.local-file-translator").translate(line)
		if not local_file then
			goto continue
		end
		local start = local_file.file_status_position.start
		local ending = local_file.file_status_position.ending
		if require("alien.status").is_staged(local_file.file_status) then
			vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienStaged", i - 1, start, ending)
			vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienStagedBg", i - 1, 0, -1)
		else
			vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienUnstaged", i - 1, start, ending)
			vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienUnstagedBg", i - 1, 0, -1)
		end
		::continue::
	end
end

return M