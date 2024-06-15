local M = {}

M.setup_colors = function()
	local colors = require("alien.window").get_palette()
	-- foreground colors
	vim.cmd(string.format("highlight %s guifg=%s", "AlienStaged", colors.green))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienCurrentBranch", colors.green))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienPartiallyStaged", colors.orange))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienUnstaged", colors.red))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienBranchName", colors.purple))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienBranchStar", colors.purple))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienTimeMachineCommit", colors.purple))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienPushPullString", colors.yellow))

	-- background colors
	vim.cmd(string.format("highlight %s guibg=%s", "AlienTimeMachineCurrentCommit", colors.orange))
	vim.cmd(string.format("highlight %s guibg=%s", "AlienDiffNew", colors.green_bg_dark))
	vim.cmd(string.format("highlight %s guibg=%s", "AlienDiffOld", colors.red_bg_dark))
end

return M
