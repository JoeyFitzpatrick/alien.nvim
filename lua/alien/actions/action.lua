local get_object_type = require("alien.objects").get_object_type

local M = {}

---@alias Action fun(): { output: string[], object_type: AlienObject }
---@alias MultiAction { actions: Action[], object_type: AlienObject }
---@alias AlienCommand string | string[] | fun(): string

--- Return the output of multiple commands
--- If one of the commands is itself an array, the outputs of the commands in the array will be concatenated on a single line
---@param cmds AlienCommand[]
---@return string[]
local function get_multiple_outputs(cmds)
	local output = {}
	for _, c in ipairs(cmds) do
		if type(c) == "string" then
			for _, line in ipairs(vim.fn.systemlist(c)) do
				table.insert(output, line)
			end
		end
		if type(c) == "function" then
			for _, line in ipairs(vim.fn.systemlist(c())) do
				table.insert(output, line)
			end
		end
	end
	return output
end

--- Takes a command and returns an Action function
---@param cmd AlienCommand | AlienCommand[]
---@param opts { object_type: AlienObject | nil, trigger_redraw: boolean | nil, output_handler: nil | fun(output: string[]): string[] } | nil }
---@return Action
M.create_action = function(cmd, opts)
	opts = opts or {}
	local object_type = opts.object_type
	local redraw = function()
		if opts.trigger_redraw then
			vim.schedule(require("alien.elements.register").redraw_elements)
		end
	end
	local handle_output = function(output)
		if opts.output_handler then
			return opts.output_handler(output)
		end
		return output
	end
	return function()
		if type(cmd) == "table" then
			---@type string[]
			local output = get_multiple_outputs(cmd)
			redraw()
			return { output = handle_output(output), object_type = object_type }
		end
		if type(cmd) == "function" then
			local fn = function()
				return {
					output = { handle_output(vim.fn.systemlist(cmd())) },
					object_type = object_type or get_object_type(cmd()),
				}
			end
			redraw()
			return fn()
		end
		local output = vim.fn.systemlist(cmd)
		redraw()
		return { output = handle_output(output), object_type = object_type or get_object_type(cmd) }
	end
end

return M
