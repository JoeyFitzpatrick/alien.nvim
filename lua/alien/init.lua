local setup_colors = function()
	local colors = require("alien.utils").get_palette()
	vim.cmd(string.format("highlight %s guifg=%s", "AlienStaged", colors.green))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienPartiallyStaged", colors.orange))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienUnstaged", colors.red))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienBranchName", colors.purple))
	vim.cmd(string.format("highlight %s guifg=%s", "AlienPushPullString", colors.yellow))

	--	vim.cmd([[
	--		hi DiffAdd      gui=none    guifg=NONE          guibg=#bada9f
	--		hi diffAdded      gui=none    guifg=NONE          guibg=#bada9f
	--		hi DiffChange   gui=none    guifg=NONE          guibg=#e5d5ac
	--		hi diffChanged   gui=none    guifg=NONE          guibg=#e5d5ac
	--		hi DiffDelete   gui=bold    guifg=#ff8080       guibg=#ffb0b0
	--		hi diffRemoved   gui=bold    guifg=#ff8080       guibg=#ffb0b0
	--		hi DiffText     gui=none    guifg=NONE          guibg=#8cbee2
	--	]])
end

local M = {}
M.status = function()
	require("alien.status").git_status()
end
M.setup = function(opts)
	opts = opts or {}
	setup_colors()
end
return M
