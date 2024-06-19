local get_object_type = require("alien.objects").get_object_type

local M = {}

---@alias Action fun(): { output: string[], object_type: AlienObject }

--- Takes a command and returns an Action function
---@param cmd string | fun(): string
---@param object_type string | nil
---@return Action
M.create_action = function(cmd, object_type)
	return function()
		if type(cmd) == "function" then
			local fn = function()
				return { output = { vim.fn.systemlist(cmd()) }, object_type = object_type or get_object_type(cmd()) }
			end
			return fn()
		end
		local output = vim.fn.systemlist(cmd)
		return { output = output, object_type = object_type or get_object_type(cmd) }
	end
end

return M
