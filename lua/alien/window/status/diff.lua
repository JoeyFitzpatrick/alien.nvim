local commands = require("alien.commands")
local diff = require("alien.diff")

local M = {}

M.diff_win_ids = {}
M.git_diff_current_buffer = function()
	local file = vim.api.nvim_get_current_line()
	local filename = file:sub(4) -- Remove the first three characters (M, A, D, etc.)
	-- Read the file contents from the last commit
	local last_commit_content = vim.fn.systemlist(commands.file_contents(filename))
	if vim.v.shell_error ~= 0 then
		last_commit_content = { "" }
	end
	local current_content = vim.fn.systemlist("bat " .. filename)
	diff.alien_diff({
		filename = filename,
		diff_left = function()
			return last_commit_content
		end,
		diff_right = function()
			return current_content
		end,
	})
end

return M
