local commands = require("alien.commands")

local M = {}
M.get_status_lines = function()
	local lines = vim.fn.systemlist(commands.status)
	local current_branch = vim.fn.systemlist(commands.current_branch)
	table.insert(lines, 1, "Branch: " .. current_branch[1])
	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		require("alien.utils").set_buffer_colors()
	end
	return set_lines
end

M.git_status = function()
	require("alien.utils").open_status_buffer(M.get_status_lines())
end

return M
