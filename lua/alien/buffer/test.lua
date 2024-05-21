local bufnr = vim.api.nvim_create_buf(false, true)
vim.api.nvim_open_win(bufnr, true, {
	relative = "editor",
	width = 40,
	height = 10,
	row = 10,
	col = 10,
	style = "minimal",
})
vim.fn.termopen("git diff -- lua/alien/time-machine/init.lua")
-- local channel = vim.api.nvim_open_term(bufnr, {})
-- vim.api.nvim_chan_send(channel, "echo 'Hello, World!'\n")
