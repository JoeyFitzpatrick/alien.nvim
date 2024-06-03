local git_cli = require("alien.git-cli")
local diff = require("alien.diff")

local M = {}

M.diff_win_ids = {}
M.git_diff_current_buffer = function()
	local file = vim.api.nvim_get_current_line()
	local status = file:sub(1, 2)
	local filename = file:sub(4) -- Remove the first three characters (M, A, D, etc.)
	diff.alien_diff(filename, git_cli.diff(filename, status))
end

return M
