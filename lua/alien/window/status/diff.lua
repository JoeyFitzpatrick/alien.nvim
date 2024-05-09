local commands = require("alien.commands")
local diff = require("alien.diff")
local buffer = require("alien.buffer")
local helpers = require("alien.utils.helpers")

local M = {}

M.diff_win_ids = {}
local diff_wins = function()
	for _, win_id in ipairs(M.diff_win_ids) do
		if vim.api.nvim_win_is_valid(win_id) then
			vim.api.nvim_set_current_win(win_id)
			vim.cmd("diffthis")
		end
	end
end
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
		diff_left = last_commit_content,
		diff_right = current_content,
	})
end

return M
