local M = {}
M.status = function()
	require("alien.status").git_status()
end
M.setup = function(opts)
	opts = opts or {}
	local colors = require("alien.utils").get_palette()
	vim.cmd(string.format("highlight %s guifg=%s", "AlienStaged", colors.green))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienPartiallyStaged", colors.orange))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienUnstaged", colors.red))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienBranchName", colors.yellow))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienPushPullString", colors.purple))
end
return M
