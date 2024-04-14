local commands = require("alien.commands")
local utils = require("alien.utils")

local M = {}
M.get_status_lines = function()
	local lines = vim.fn.systemlist(commands.status)

	local current_branch = vim.fn.systemlist(commands.current_branch)[1] .. M.get_push_pull_string()
	table.insert(lines, 1, "Branch: " .. current_branch)
	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		utils.set_buffer_colors()
	end
	return set_lines
end

M.get_push_pull_string = function()
	local push_pull_string = ""
	local num_commits_to_pull = vim.fn.systemlist(commands.num_commits_to_pull)[1]
	local num_commits_to_push = vim.fn.systemlist(commands.num_commits_to_push)[1]
	if num_commits_to_pull ~= "0" then
		push_pull_string = push_pull_string .. " ↓" .. num_commits_to_pull
	end
	if num_commits_to_push ~= "0" then
		push_pull_string = push_pull_string .. " ↑" .. num_commits_to_push
	end
	return push_pull_string
end

M.git_status = function()
	utils.open_status_buffer(M.get_status_lines())
end

return M
