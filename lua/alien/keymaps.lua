local M = {}
M.set_default_keymaps = function()
	vim.keymap.set("n", "<leader>Js", require("alien").hello)
end
return M
