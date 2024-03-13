local M = {}
M.hello = function()
	vim.print("Hello, world!")
end
M.setup = function(opts)
	opts = opts or {}
	require("alien.keymaps").set_default_keymaps()
end
return M
