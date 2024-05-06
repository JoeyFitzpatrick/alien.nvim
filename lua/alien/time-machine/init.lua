local commands = require("alien.commands")
local diff = require("alien.diff")
local buffer = require("alien.buffer")
local floating_window = require("alien.window.floating-window")
local keymaps = require("alien.keymaps")

local CURRENT_CHANGES = "Current changes"

local M = {}

M.time_machine_bufnr = nil
M.viewed_file_bufnr = nil
M.viewed_file_window = nil
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

local get_lines = function()
	local commit_hash = get_current_commit_hash()
	local lines = {}
	if commit_hash == CURRENT_CHANGES:gmatch("%S+")() then
		lines = M.current_file_contents
	else
		lines = vim.fn.systemlist(commands.file_contents_at_commit(commit_hash, get_current_file()))
	end
	return lines
end

-- We set these buffer-specfic mappings further down in the file
local mappings = {}

local load_file = function()
	local buffer_name = get_current_commit_hash()
	local filename = get_current_file()
	buffer.get_buffer(buffer_name, function()
		return get_lines()
	end, {
		filetype = vim.fn.fnamemodify(filename, ":e"),
		window = M.viewed_file_window,
		post_switch = function()
			set_current_line_highlight()
		end,
		mappings = mappings,
	})
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

mappings["<c-p>"] = time_machine_next
mappings["<c-n>"] = time_machine_prev

local set_keymaps = function()
	local map = function(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, { buffer = M.time_machine_bufnr })
	end
	map("s", function()
		if M.time_machine_bufnr == vim.api.nvim_get_current_buf() then
			M.current_time_machine_line_num = vim.api.nvim_win_get_cursor(0)[1] - 1
		end
		if M.current_time_machine_line_num == nil then
			M.current_time_machine_line_num = 0
		else
			M.current_time_machine_line_num = vim.api.nvim_win_get_cursor(0)[1] - 1
		end
		load_file()
	end)
	map("<c-p>", time_machine_next)
	map("<c-n>", time_machine_prev)
	map("q", M.close_time_machine)
	map("o", function()
		vim.fn.system(commands.open_commit_in_github(get_current_commit_hash()))
	end)
	map("d", function()
		diff.alien_diff({
			filename = get_current_file(),
			diff_left = vim.fn.systemlist(
				commands.file_contents_at_commit(get_current_commit_hash(), get_current_file())
			),
			diff_right = M.current_file_contents,
		})
	end)
	map("i", function()
		local lines = vim.fn.systemlist(commands.commit_metadata(get_current_commit_hash()))
		local post_render_callback = function(bufnr)
			local first_word_length = function(line)
				return string.find(line, "%s") or #line
			end
			for i = 0, 2, 1 do
				vim.api.nvim_buf_add_highlight(
					bufnr,
					-1,
					"AlienTimeMachineCommit",
					i,
					0,
					first_word_length(lines[i + 1])
				)
			end
		end
		floating_window.create(lines, post_render_callback)
	end)
	map("g?", keymaps.display_keymaps)
end

local setup_time_machine_buffer = function()
	set_keymaps()
	set_commit_highlights()
	vim.api.nvim_set_option_value("modifiable", false, { buf = M.time_machine_bufnr })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = M.time_machine_bufnr })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = M.time_machine_bufnr })
	vim.api.nvim_set_option_value("winfixwidth", true, { win = vim.api.nvim_get_current_win() })
	vim.api.nvim_set_option_value("buflisted", false, { buf = M.time_machine_bufnr })
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
	end
	if M.viewed_file_bufnr then
		M.current_file_contents = nil
		M.viewed_file_bufnr = nil
		M.viewed_file_window = nil
	end
	buffer.close_all()
end
M.toggle = function()
	if M.time_machine_bufnr then
		M.close_time_machine()
	else
		M.viewed_file_bufnr = vim.api.nvim_get_current_buf()
		M.viewed_file_window = vim.api.nvim_get_current_win()
		M.current_file_contents = vim.api.nvim_buf_get_lines(M.viewed_file_bufnr, 0, -1, false)
		local window_width = vim.api.nvim_win_get_width(0)
		local split_width = math.floor(window_width * 0.25)
		vim.cmd(split_width .. " vnew")
		M.time_machine_bufnr = vim.api.nvim_get_current_buf()
		load_time_machine_lines()
		setup_time_machine_buffer()

		local alien_time_machine_group = vim.api.nvim_create_augroup("AlienTimeMachine", { clear = true })
		vim.api.nvim_create_autocmd("BufWinLeave", {
			desc = "Close time machine when time machine window is closed",
			buffer = M.time_machine_bufnr,
			callback = function()
				vim.api.nvim_set_current_win(M.viewed_file_window)
				vim.api.nvim_set_current_buf(M.viewed_file_bufnr)
				buffer.close_all()
			end,
			group = alien_time_machine_group,
		})
	end
end

return M
