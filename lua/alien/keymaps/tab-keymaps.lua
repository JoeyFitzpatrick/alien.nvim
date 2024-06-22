local M = {}

local close_tab = function(tabnr)
	local tabs = require("alien.elements").tabs
	local tab = tabs[tabnr]
	if not tab or not tab.child_buffers then
		return
	end
	for _, bufnr in ipairs(tab.child_buffers) do
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
	tabs[tabnr] = nil
end

M.set_tab_keymaps = function(bufnr)
	vim.keymap.set("n", "q", function()
		close_tab(vim.api.nvim_get_current_tabpage())
	end, { noremap = true, silent = true, buffer = bufnr })
end

return M
