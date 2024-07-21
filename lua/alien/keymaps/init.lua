local register = require("alien.elements.register")

local M = {}

--- Set keymaps by object type for the given buffer
---@param bufnr integer
---@param object_type AlienObject
M.set_object_keymaps = function(bufnr, object_type)
	if object_type == "local_file" then
		require("alien.keymaps.local_file-keymaps").set_keymaps(bufnr)
	elseif object_type == "local_branch" then
		require("alien.keymaps.local-branch-keymaps").set_keymaps(bufnr)
	end
end

--- Set keymaps by element type for the given buffer
---@param bufnr integer
---@param element_type ElementType
M.set_element_keymaps = function(bufnr, element_type)
	vim.keymap.set("n", "q", function()
		register.close_element(bufnr)
	end, { noremap = true, silent = true, buffer = bufnr })
end

M.set_global_keymaps = require("alien.keymaps.global-keymaps").set_global_keymaps

return M
