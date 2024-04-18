local utils = require("alien.utils")

local M = {}
M.get_buffer_args = function()
	local lines = {}
	table.insert(lines, 1, "Branches")
	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		utils.set_buffer_colors()
	end
	return {
		set_lines = set_lines,
		cursor_pos = { 1, 0 },
	}
end

M.git_branches = function()
	utils.open_alien_buffer(M.get_buffer_args())
end

return M
