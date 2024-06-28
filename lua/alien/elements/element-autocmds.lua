local M = {}

local element_group = vim.api.nvim_create_augroup("AlienElement", { clear = true })
M.set_element_autocmds = function(bufnr)
	vim.api.nvim_create_autocmd("BufDelete", {
		desc = "Deregister element",
		buffer = bufnr,
		callback = function()
			require("alien.elements.register").deregister_element(bufnr, true)
		end,
		group = element_group,
	})
end

return M