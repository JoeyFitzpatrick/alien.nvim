local M = {}
M.get_status_lines = function()
	local status_command = require("alien.commands").status
	local git_status_output = vim.fn.systemlist(status_command)
	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, git_status_output)
		require("alien.utils").set_buffer_colors()
	end
	return set_lines
end

M.git_status = function()
	require("alien.utils").open_status_buffer(M.get_status_lines())
end

return M
