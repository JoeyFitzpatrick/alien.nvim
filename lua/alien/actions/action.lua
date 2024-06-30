local get_object_type = require("alien.objects").get_object_type

local M = {}

---@alias Action fun(): { output: string[], object_type: AlienObject }
---@alias MultiAction { actions: Action[], object_type: AlienObject }

--- Takes a command and returns an Action function
---@param cmd string | string[] | fun(): string
---@param opts { object_type: string | nil, trigger_redraw: boolean | nil } | nil }
---@return Action
M.create_action = function(cmd, opts)
	opts = opts or {}
	local object_type = opts.object_type
	local redraw = function()
		if opts.trigger_redraw then
			vim.schedule(require("alien.elements.register").redraw_elements)
		end
	end
	return function()
		if type(cmd) == "table" then
			---@type string[]
			local output = {}
			for _, c in ipairs(cmd) do
				for _, line in ipairs(vim.fn.systemlist(c)) do
					table.insert(output, line)
				end
			end
			redraw()
			return { output = output, object_type = object_type }
		end
		if type(cmd) == "function" then
			local fn = function()
				return { output = { vim.fn.systemlist(cmd()) }, object_type = object_type or get_object_type(cmd()) }
			end
			redraw()
			return fn()
		end
		local output = vim.fn.systemlist(cmd)
		redraw()
		return { output = output, object_type = object_type or get_object_type(cmd) }
	end
end

return M
