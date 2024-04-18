local commands = require("alien.commands")
local utils = require("alien.utils")

local FIRST_STATUS_LINE_NUMBER = 2

local M = {}
M.get_buffer_args = function()
	local lines = vim.fn.systemlist(commands.status)

	local current_branch = vim.fn.systemlist(commands.current_branch)[1] .. M.get_push_pull_string()
	table.insert(lines, 1, "Head:   " .. current_branch)
	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		utils.set_buffer_colors()
	end
	local cursor_pos = { 1, 0 }
	local post_open_hook = nil
	if #lines > 1 then
		cursor_pos = { FIRST_STATUS_LINE_NUMBER, 0 }
		post_open_hook = require("alien.status.diff").git_diff_current_buffer
	end
	return {
		set_lines = set_lines,
		cursor_pos = cursor_pos,
		post_open_hook = post_open_hook,
	}
end

M.get_push_pull_string = function()
	local push_pull_string = ""
	local num_commits_to_pull = commands.num_commits("pull")
	local num_commits_to_push = commands.num_commits("push")
	if num_commits_to_pull ~= "0" then
		push_pull_string = push_pull_string .. " ↓" .. num_commits_to_pull
	end
	if num_commits_to_push ~= "0" then
		push_pull_string = push_pull_string .. " ↑" .. num_commits_to_push
	end
	return push_pull_string
end

M.git_status = function()
	utils.open_alien_buffer(M.get_buffer_args())
end

return M
