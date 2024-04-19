local commands = require("alien.commands")
local window_constants = require("alien.window.constants")
local STATUSES = require("alien.status.constants").STATUSES

local FIRST_STATUS_LINE_NUMBER = 3
local get_status_prefix = function(str)
	return str:sub(1, 2)
end

local M = {}
M.set_buffer_colors = function()
	local line_count = vim.api.nvim_buf_line_count(0)

	local HEAD_LINE = 2
	local line = vim.api.nvim_buf_get_lines(0, HEAD_LINE - 1, HEAD_LINE, false)[1]

	-- Split the line by whitespace using gmatch and store the parts in a table
	local parts = {}
	for part in line:gmatch("%S+") do
		table.insert(parts, part)
	end

	-- Add highlight for the second part of the line with "AlienBranchName" color
	if parts[2] then
		local start_col = #parts[1] + 1 -- Calculate the start column for the second part
		-- Loop through the line to find the exact start position of the second part
		for i = start_col, #line do
			if line:sub(i, i + #parts[2] - 1) == parts[2] then
				start_col = i - 1
				break
			end
		end
		vim.api.nvim_buf_add_highlight(0, -1, "AlienBranchName", HEAD_LINE - 1, start_col, start_col + #parts[2])
	end

	-- Add highlight for the third part of the line with "AlienPushPullString" color
	if parts[3] then
		local start_col = #parts[1] + #parts[2] + 2 -- Calculate the start column for the third part
		-- Loop through the line to find the exact start position of the third part
		for i = start_col, #line do
			if line:sub(i, i + #parts[3] - 1) == parts[3] then
				start_col = i - 1
				break
			end
		end
		vim.api.nvim_buf_add_highlight(0, -1, "AlienPushPullString", HEAD_LINE - 1, start_col, start_col + #parts[3])
	end

	for line_number = FIRST_STATUS_LINE_NUMBER, line_count do
		line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

		local status_prefix = get_status_prefix(line)

		-- Now that we have the status prefix, check the conditions.
		if status_prefix:sub(1, 1) ~= " " and status_prefix:sub(2, 2) == " " then
			vim.api.nvim_buf_add_highlight(0, -1, "AlienStaged", line_number - 1, 0, -1)
		elseif status_prefix == "MM" then
			vim.api.nvim_buf_add_highlight(0, -1, "AlienPartiallyStaged", line_number - 1, 0, -1)
		elseif status_prefix == STATUSES.UNTRACKED or status_prefix:sub(1, 1) == " " then
			vim.api.nvim_buf_add_highlight(0, -1, "AlienUnstaged", line_number - 1, 0, -1)
		end
	end
end

M.get_buffer_args = function()
	local lines = vim.fn.systemlist(commands.status)
	local buffer_type = window_constants.BUFFER_TYPES.STATUS

	local current_branch = vim.fn.systemlist(commands.current_branch)[1] .. M.get_push_pull_string()
	table.insert(lines, 1, "Head:   " .. current_branch)
	table.insert(lines, 1, window_constants.BUFFER_TYPE_STRING[buffer_type])
	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	end
	local cursor_pos = { 1, 0 }
	local post_open_hook = nil
	if #lines > 1 then
		cursor_pos = { FIRST_STATUS_LINE_NUMBER, 0 }
		post_open_hook = require("alien.status.diff").git_diff_current_buffer
	end
	return {
		buffer_type = buffer_type,
		set_lines = set_lines,
		cursor_pos = cursor_pos,
		post_open_hook = post_open_hook,
		set_keymaps = require("alien.keymaps.status").set_status_buffer_keymaps,
		set_colors = M.set_buffer_colors,
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

return M
