local commands = require("alien.commands")

local FIRST_BRANCH_LINE_NUMBER = 3

local M = {}
M.is_current_branch = function(line)
	return line:sub(1, 1) == "*"
end

M.set_buffer_colors = function()
	local line_count = vim.api.nvim_buf_line_count(0)
	for line_number = FIRST_BRANCH_LINE_NUMBER, line_count do
		local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

		if M.is_current_branch(line) then
			vim.api.nvim_buf_add_highlight(0, -1, "AlienStaged", line_number - 1, 0, -1)
		end
	end
end

M.get_buffer_args = function()
	local lines = vim.fn.systemlist(commands.local_branches)
	table.insert(lines, 1, "Branches")
	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	end
	return {
		buffer_type = require("alien.window").BUFFER_TYPES.BRANCHES,
		set_lines = set_lines,
		cursor_pos = { FIRST_BRANCH_LINE_NUMBER, 0 },
		set_keymaps = require("alien.keymaps.branch").set_status_buffer_keymaps,
		set_colors = M.set_buffer_colors,
	}
end

return M
