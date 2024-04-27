local commands = require("alien.commands")

local M = {}

M.diff_win_ids = {}
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
	local filetype = vim.fn.fnamemodify(filename, ":e") -- Extract the file extension

	-- Read the file contents from the last commit
	local last_commit_content = vim.fn.systemlist(commands.file_contents(filename))
	if vim.v.shell_error ~= 0 then
		last_commit_content = { "" }
	end

	local window_height = vim.api.nvim_win_get_height(0)
	local split_height = math.floor(window_height * 0.65)
	vim.cmd("bo " .. split_height .. " split " .. filename)
	M.diff_win_ids = { vim.api.nvim_get_current_win() }
	-- Create a non-writable, non-file buffer with the file contents
	vim.cmd("vnew")
	M.diff_win_ids[2] = vim.api.nvim_get_current_win()
	vim.api.nvim_set_option_value("buftype", "nofile", { scope = "local" })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { scope = "local" })
	vim.api.nvim_set_option_value("filetype", filetype, { scope = "local" })
	vim.api.nvim_buf_set_lines(0, 0, -1, false, last_commit_content)

	-- Set diff mode for both windows
	vim.cmd("wincmd l") -- Move to the new (right) window
	vim.cmd("diffthis")
	vim.cmd("wincmd h") -- Move to the original (left) window
	vim.cmd("diffthis")

	-- Restore the original state
	vim.api.nvim_set_current_win(current_window)
	vim.api.nvim_win_set_cursor(0, cursor_pos)
end

return M
