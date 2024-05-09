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
	for _, win_id in ipairs(M.diff_win_ids) do
		if vim.api.nvim_win_is_valid(win_id) then
			vim.api.nvim_win_close(win_id, true)
		end
	end
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_window = vim.api.nvim_get_current_win()
	local file = vim.api.nvim_get_current_line()
	local filename = file:sub(4) -- Remove the first three characters (M, A, D, etc.)
	-- Read the file contents from the last commit
	local last_commit_content = vim.fn.systemlist(commands.file_contents(filename))
	if vim.v.shell_error ~= 0 then
		last_commit_content = { "" }
	end

	local window_height = vim.api.nvim_win_get_height(0)
	local split_height = math.floor(window_height * 0.65)
	vim.cmd("bo " .. split_height .. " new")
	helpers.buf_set_temporary(vim.api.nvim_get_current_buf())
	buffer.get_buffer("alien-status-" .. filename, function()
		return vim.fn.systemlist("bat " .. filename)
	end, { window = vim.api.nvim_get_current_win() })
	M.diff_win_ids = { vim.api.nvim_get_current_win() }
	-- Create a non-writable, non-file buffer with the file contents
	vim.cmd("vnew")
	helpers.buf_set_temporary(vim.api.nvim_get_current_buf())
	M.diff_win_ids[2] = vim.api.nvim_get_current_win()
	buffer.get_buffer("alien-last-commit-" .. filename, function()
		return last_commit_content
	end, { window = vim.api.nvim_get_current_win() })

	diff_wins()
	-- Restore the original state
	vim.api.nvim_set_current_win(current_window)
	vim.api.nvim_win_set_cursor(0, cursor_pos)
end

return M
