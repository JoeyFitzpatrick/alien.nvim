local elements = require("alien.elements")

local M = {}

local close_tab = function(tabnr)
	local tabs = elements.register.get_elements({ element_type = "tab" })
	local tab = vim.tbl_filter(function(tab)
		return tab.tabnr == tabnr
	end, tabs)[1]
	if not tab then
		return
	end
	elements.register.close_element(tab.bufnr)
end

M.set_tab_keymaps = function(bufnr)
	vim.keymap.set("n", "q", function()
		close_tab(vim.api.nvim_get_current_tabpage())
	end, { noremap = true, silent = true, buffer = bufnr })
end

return M
