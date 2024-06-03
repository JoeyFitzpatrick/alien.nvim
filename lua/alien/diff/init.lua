local buffer = require("alien.buffer")

local M = {}
M.highlight = require("alien.diff.highlight")

M.diff_win_ids = {}
M.close_diff = function()
	for _, win_id in ipairs(M.diff_win_ids) do
		if vim.api.nvim_win_is_valid(win_id) then
			vim.api.nvim_win_close(win_id, true)
		end
	end
end

local split_horizontal = function()
	local window_height = vim.api.nvim_win_get_height(0)
	local split_height = math.floor(window_height * 0.65)

	vim.cmd("bo " .. split_height .. " split")
end

local split_vertical = function()
	local window_width = vim.o.columns
	local split_width = math.floor(window_width * 0.65)

	vim.cmd("bo " .. split_width .. " vsplit")
end
---
---@param filename string
---@param diff_fn fun(): string[]
M.alien_diff = function(filename, diff_fn)
	M.close_diff()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_window = vim.api.nvim_get_current_win()

	split_vertical()
	M.diff_win_ids = { vim.api.nvim_get_current_win() }
	buffer.get_buffer("diff-" .. filename, diff_fn, { window = 0, highlight = M.highlight.highight_diff_output })

	-- Restore the original state
	vim.api.nvim_set_current_win(current_window)
	vim.api.nvim_win_set_cursor(0, cursor_pos)
end
M.alien_diff_old = function(params)
	M.close_diff()
	local filename = params.filename
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_window = vim.api.nvim_get_current_win()

	split_horizontal()
	buffer.get_buffer("diff-right-" .. filename, params.diff_right, { window = 0 })
	M.diff_win_ids = { vim.api.nvim_get_current_win() }
	vim.cmd("vsplit")
	M.diff_win_ids[2] = vim.api.nvim_get_current_win()
	buffer.get_buffer("diff-left-" .. filename, params.diff_left, { window = 0 })

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
