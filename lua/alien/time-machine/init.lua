local M = {}

M.time_machine_bufnr = nil
M.viewed_file_bufnr = nil

local setup_viewed_file = function(bufnr)
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
end

local reset_viewed_file = function(bufnr)
	vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
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
	end
end

return M
