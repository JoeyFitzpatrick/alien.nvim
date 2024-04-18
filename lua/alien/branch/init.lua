local window = require("alien.window")
local commands = require("alien.commands")

local M = {}
M.get_buffer_args = function()
	local lines = vim.fn.systemlist(commands.local_branches)
	table.insert(lines, 1, "Branches")
	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		window.set_buffer_colors()
	end
	return {
		buffer_type = window.BUFFER_TYPES.BRANCHES,
		set_lines = set_lines,
		cursor_pos = { 1, 0 },
		set_keymaps = require("alien.keymaps.branch").set_status_buffer_keymaps,
	}
end

M.git_branches = function()
	window.open_alien_buffer(M.get_buffer_args())
end

return M
