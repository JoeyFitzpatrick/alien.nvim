local commands = require("alien.commands")

local M = {}

M.time_machine_bufnr = nil
M.viewed_file_bufnr = nil
M.current_file_contents = nil

local setup_viewed_file = function(bufnr)
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
	M.current_file_contents = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

local reset_viewed_file = function(bufnr)
	vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.current_file_contents)
	M.current_file_contents = nil
end

local get_current_file = function()
	local filename = vim.api.nvim_buf_get_name(M.viewed_file_bufnr)
	local relative_filename = vim.fn.fnamemodify(filename, ":.")
	return relative_filename
end

local set_keymaps = function(bufnr)
	vim.keymap.set("n", "s", function()
		local line = vim.api.nvim_get_current_line()
		local commit_hash = line:gmatch("%S+")()
		vim.api.nvim_set_option_value("modifiable", true, { buf = M.viewed_file_bufnr })
		vim.api.nvim_buf_set_lines(
			M.viewed_file_bufnr,
			0,
			-1,
			false,
			vim.fn.systemlist(commands.file_contents_at_commit(commit_hash, get_current_file()))
		)
	end, { buffer = bufnr })
	vim.api.nvim_set_option_value("modifiable", false, { buf = M.viewed_file_bufnr })
end

local setup_time_machine_buffer = function(bufnr)
	set_keymaps(bufnr)
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = bufnr })
	vim.cmd("setlocal nowrap")
end

local load_time_machine_lines = function()
	local relative_filename = get_current_file()
	local commits = vim.fn.systemlist(commands.all_commits_for_file(relative_filename))
	if vim.v.shell_error ~= 0 then
		commits = { "Error: no commits found" }
	end
	vim.api.nvim_buf_set_lines(M.time_machine_bufnr, 0, -1, false, commits)
end

M.toggle = function()
	if M.time_machine_bufnr then
		vim.cmd("bdelete " .. M.time_machine_bufnr)
		M.time_machine_bufnr = nil
		reset_viewed_file(M.viewed_file_bufnr)
		M.viewed_file_bufnr = nil
	else
		M.viewed_file_bufnr = vim.api.nvim_get_current_buf()
		setup_viewed_file(M.viewed_file_bufnr)
		local window_width = vim.api.nvim_win_get_width(0)
		local split_width = math.floor(window_width * 0.25)
		-- vim.cmd("bo " .. split_height .. " split " .. filename)
		vim.cmd(split_width .. " vnew")
		M.time_machine_bufnr = vim.api.nvim_get_current_buf()
		load_time_machine_lines()
		setup_time_machine_buffer(M.time_machine_bufnr)
	end
end

return M
