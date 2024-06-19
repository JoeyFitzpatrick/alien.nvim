local M = {}

--- Set keymaps by object type for the given buffer
---@param bufnr number
---@param object_type AlienObject
---@param redraw fun(): nil
M.set_keymaps = function(bufnr, object_type, redraw)
	if object_type == "local_file" then
		require("alien.keymaps.local_file-keymaps").set_keymaps(bufnr, redraw)
	end
end

return M
