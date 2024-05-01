local commands = require("alien.commands")
local diff = require("alien.diff")
local CURRENT_CHANGES = "Current changes"

local M = {}

M.time_machine_bufnr = nil
M.viewed_file_bufnr = nil
M.current_file_contents = nil
M.current_time_machine_line_num = nil

local set_commit_highlights = function()
	if M.time_machine_bufnr == nil then
		return
	end
	local commit_hash_length = 7
	for i = 0, vim.api.nvim_buf_line_count(M.time_machine_bufnr) - 1 do
		vim.api.nvim_buf_add_highlight(M.time_machine_bufnr, -1, "AlienTimeMachineCommit", i, 0, commit_hash_length)
	end
end

local set_current_line_highlight = function()
	if M.current_time_machine_line_num ~= nil then
		vim.api.nvim_buf_clear_namespace(
			M.time_machine_bufnr,
			vim.api.nvim_create_namespace("AlienTimeMachineCurrentCommit"),
			0,
			-1
		)
		vim.api.nvim_buf_add_highlight(
			M.time_machine_bufnr,
			vim.api.nvim_create_namespace("AlienTimeMachineCurrentCommit"),
			"AlienTimeMachineCurrentCommit",
			M.current_time_machine_line_num,
			0,
			-1
		)
	end
end

local setup_viewed_file = function(bufnr)
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
	M.current_file_contents = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

local reset_viewed_file = function(bufnr)
	vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.current_file_contents)
	M.current_file_contents = nil
	vim.keymap.del("n", "<c-n>", { buffer = bufnr })
	vim.keymap.del("n", "<c-p>", { buffer = bufnr })
end

local get_current_file = function()
	local filename = vim.api.nvim_buf_get_name(M.viewed_file_bufnr)
	local relative_filename = vim.fn.fnamemodify(filename, ":.")
	return relative_filename
end

local get_current_commit_hash = function()
	local line_num = M.current_time_machine_line_num or vim.api.nvim_win_get_cursor(0)[1] - 1
	local line = vim.api.nvim_buf_get_lines(M.time_machine_bufnr, line_num, line_num + 1, false)[1]
	local commit_hash = line:gmatch("%S+")()
	return commit_hash
end

local load_file = function()
	local commit_hash = get_current_commit_hash()
	vim.api.nvim_set_option_value("modifiable", true, { buf = M.viewed_file_bufnr })
	local lines = {}
	if commit_hash == CURRENT_CHANGES:gmatch("%S+")() then
		lines = M.current_file_contents
	else
		lines = vim.fn.systemlist(commands.file_contents_at_commit(commit_hash, get_current_file()))
	end
	vim.api.nvim_buf_set_lines(M.viewed_file_bufnr, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = M.viewed_file_bufnr })
	set_current_line_highlight()
end

local time_machine_prev = function()
	if M.current_time_machine_line_num == nil then
		M.current_time_machine_line_num = 0
		load_file()
		return
	end
	local num_lines = vim.api.nvim_buf_line_count(M.time_machine_bufnr)
	if M.current_time_machine_line_num < num_lines - 1 then
		M.current_time_machine_line_num = M.current_time_machine_line_num + 1
		load_file()
	end
end

local time_machine_next = function()
	if M.current_time_machine_line_num > 0 then
		M.current_time_machine_line_num = M.current_time_machine_line_num - 1
		load_file()
	end
end

local set_keymaps = function()
	vim.keymap.set("n", "s", function()
		if M.current_time_machine_line_num == nil then
			M.current_time_machine_line_num = 0
		else
			M.current_time_machine_line_num = vim.api.nvim_win_get_cursor(0)[1] - 1
		end
		load_file()
	end, { buffer = M.time_machine_bufnr })
	vim.keymap.set("n", "<c-p>", time_machine_next, { buffer = M.viewed_file_bufnr })
	vim.keymap.set("n", "<c-n>", time_machine_prev, { buffer = M.viewed_file_bufnr })
	vim.keymap.set("n", "<c-p>", time_machine_next, { buffer = M.time_machine_bufnr })
	vim.keymap.set("n", "<c-n>", time_machine_prev, { buffer = M.time_machine_bufnr })
	vim.keymap.set("n", "q", M.close_time_machine, { buffer = M.time_machine_bufnr })
	vim.keymap.set("n", "o", function()
		vim.fn.system(commands.open_commit_in_github(get_current_commit_hash()))
	end, { buffer = M.time_machine_bufnr })
	vim.keymap.set("n", "d", function()
		diff.alien_diff({
			filename = get_current_file(),
			diff_left = vim.fn.systemlist(
				commands.file_contents_at_commit(get_current_commit_hash(), get_current_file())
			),
			diff_right = M.current_file_contents,
		})
	end)
	vim.api.nvim_set_option_value("modifiable", false, { buf = M.viewed_file_bufnr })
end

local setup_time_machine_buffer = function()
	set_keymaps()
	set_commit_highlights()
	vim.api.nvim_set_option_value("modifiable", false, { buf = M.time_machine_bufnr })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = M.time_machine_bufnr })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = M.time_machine_bufnr })
	vim.cmd("setlocal nowrap")
end

local load_time_machine_lines = function()
	local relative_filename = get_current_file()
	local commits = vim.fn.systemlist(commands.all_commits_for_file(relative_filename))
	if vim.v.shell_error ~= 0 then
		commits = { "Error: no commits found" }
	end
	table.insert(commits, 1, CURRENT_CHANGES)
	vim.api.nvim_buf_set_lines(M.time_machine_bufnr, 0, -1, false, commits)
end

M.close_time_machine = function()
	if M.time_machine_bufnr then
		vim.cmd("bdelete " .. M.time_machine_bufnr)
		M.time_machine_bufnr = nil
		reset_viewed_file(M.viewed_file_bufnr)
		M.viewed_file_bufnr = nil
	end
end
M.toggle = function()
	if M.time_machine_bufnr then
		M.close_time_machine()
	else
		M.viewed_file_bufnr = vim.api.nvim_get_current_buf()
		setup_viewed_file(M.viewed_file_bufnr)
		local window_width = vim.api.nvim_win_get_width(0)
		local split_width = math.floor(window_width * 0.25)
		-- vim.cmd("bo " .. split_height .. " split " .. filename)
		vim.cmd(split_width .. " vnew")
		M.time_machine_bufnr = vim.api.nvim_get_current_buf()
		load_time_machine_lines()
		setup_time_machine_buffer()
	end
end

return M
