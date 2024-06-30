local get_object_type = require("alien.objects").get_object_type

local M = {}

---@alias Action fun(): { output: string[], object_type: AlienObject }
---@alias MultiAction { actions: Action[], object_type: AlienObject }

--- Takes a command and returns an Action function
---@param cmd string | string[] | fun(): string
---@param object_type string | nil
---@return Action
M.create_action = function(cmd, object_type)
	return function()
		if type(cmd) == "table" then
			---@type string[]
			local output = {}
			for _, c in ipairs(cmd) do
				for _, line in ipairs(vim.fn.systemlist(c)) do
					table.insert(output, line)
				end
			end
			return { output = output, object_type = object_type }
		end
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
