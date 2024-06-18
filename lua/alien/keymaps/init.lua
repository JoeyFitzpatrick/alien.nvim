local M = {}

--- Set keymaps by object type for the given buffer
---@param bufnr number
---@param object_type AlienObject
M.set_keymaps = function(bufnr, object_type)
	if object_type == "local_file" then
		require("alien.keymaps.local_file").set_keymaps(bufnr)
	end
end

return M
