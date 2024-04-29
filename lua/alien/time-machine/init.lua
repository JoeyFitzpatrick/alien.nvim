local M = {}

M.time_machine_win_num = nil

M.toggle = function()
	if M.time_machine_win_num then
		vim.cmd("bdelete")
		M.time_machine_win_num = nil
	else
		local window_width = vim.api.nvim_win_get_width(0)
		local split_width = math.floor(window_width * 0.25)
		-- vim.cmd("bo " .. split_height .. " split " .. filename)
		vim.cmd(split_width .. " vnew")
		M.time_machine_win_num = vim.api.nvim_get_current_win()
	end
end

return M
