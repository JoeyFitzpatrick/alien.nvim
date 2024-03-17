local M = {}
function M.git_status()
	local git_status_output = vim.fn.systemlist("git status")
	vim.api.nvim_command("enew")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, git_status_output)
end

return M
