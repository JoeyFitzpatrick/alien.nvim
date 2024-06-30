local register = require("alien.elements.register")

local M = {}

--- Set keymaps by object type for the given buffer
---@param bufnr integer
---@param object_type AlienObject
M.set_object_keymaps = function(bufnr, object_type)
	if object_type == "local_file" then
		require("alien.keymaps.local_file-keymaps").set_keymaps(bufnr)
	end
end

local close_tab = function(tabnr)
	local tabs = register.get_elements({ element_type = "tab" })
	local tab = vim.tbl_filter(function(tab)
		return tab.tabnr == tabnr
	end, tabs)[1]
	if not tab then
		return
	end
	register.close_element(tab.bufnr)
end

--- Set keymaps by element type for the given buffer
---@param bufnr integer
---@param element_type ElementType
M.set_element_keymaps = function(bufnr, element_type)
	vim.keymap.set("n", "q", function()
		close_tab(vim.api.nvim_get_current_tabpage())
	end, { noremap = true, silent = true, buffer = bufnr })
end

return M
