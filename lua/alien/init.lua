local setup_colors = function()
	local colors = require("alien.window").get_palette()
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

local setup_autocmds = function()
	vim.api.nvim_create_augroup("AlienGitStatus", { clear = true })

	-- Create an autocommand for the BufEnter event that checks for our custom variable
	vim.api.nvim_create_autocmd("BufEnter", {
		group = "AlienGitStatus",
		pattern = "*", -- This pattern could be more specific or left as '*' to check all entering buffers
		callback = function(args)
			local bufnr = args.buf -- Get the buffer number from the autocommand arguments
			local status, is_alien_git_status =
				pcall(vim.api.nvim_buf_get_var, bufnr, require("alien.status.constants").IS_ALIEN_GIT_STATUS_BUFFER)
			is_alien_git_status = status and is_alien_git_status

			-- Check if this is indeed the buffer we are interested in
			if is_alien_git_status then
				-- Set 'timeout' to false for this specific buffer
				vim.api.nvim_set_option_value("timeoutlen", 0, {})
			end
		end,
	})
end

local M = {}
M.status = function()
	require("alien.status").git_status()
end
M.branches = function()
	require("alien.branch").git_branches()
end
M.setup = function(opts)
	opts = opts or {}
	setup_colors()
	setup_autocmds()
end
return M
