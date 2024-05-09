local helpers = require("alien.utils.helpers")
local buffer = require("alien.buffer")

local M = {}
M.utils = require("alien.diff.utils")

M.diff_win_ids = {}
M.close_diff = function()
	for _, win_id in ipairs(M.diff_win_ids) do
		if vim.api.nvim_win_is_valid(win_id) then
			vim.api.nvim_win_close(win_id, true)
		end
	end
end
local close_diff_keymap = {
	"n",
	"q",
	function()
		M.close_diff()
	end,
}
M.alien_diff = function(params)
	M.close_diff()
	local filename = params.filename
	local diff_left = params.diff_left
	local diff_right = params.diff_right
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_window = vim.api.nvim_get_current_win()
	local filetype = vim.fn.fnamemodify(filename, ":e") -- Extract the file extension

	local window_height = vim.api.nvim_win_get_height(0)
	local split_height = math.floor(window_height * 0.65)

	vim.cmd("bo " .. split_height .. " split")
	buffer.get_buffer("diff-right-" .. filename, function()
		return diff_right
	end, { filetype = filetype, window = 0 })
	M.diff_win_ids = { vim.api.nvim_get_current_win() }
	vim.cmd("vsplit")
	M.diff_win_ids[2] = vim.api.nvim_get_current_win()
	buffer.get_buffer("diff-left-" .. filename, function()
		return diff_left
	end, { filetype = filetype, window = 0 })

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
