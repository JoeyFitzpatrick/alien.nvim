local commands = require("alien.commands")
local diff = require("alien.diff")

local M = {}

M.diff_win_ids = {}
M.git_diff_current_buffer = function()
	local file = vim.api.nvim_get_current_line()
	local filename = file:sub(4) -- Remove the first three characters (M, A, D, etc.)
	if vim.v.shell_error ~= 0 then
		last_commit_content = { "" }
	end
	diff.alien_diff_1({
		filename = filename,
		cmd = commands.diff_file(filename),
	})
	-- local last_commit_content = vim.fn.systemlist(commands.file_contents(filename))
	-- local current_content = vim.fn.systemlist("bat " .. filename)
	-- diff.alien_diff_2({
	-- 	filename = filename,
	-- 	diff_left = function()
	-- 		return last_commit_content
	-- 	end,
	-- 	diff_right = function()
	-- 		return current_content
	-- 	end,
	-- })
end

return M
