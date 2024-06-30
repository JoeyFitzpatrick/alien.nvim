local get_object_type = require("alien.objects").get_object_type

local M = {}

---@alias Action fun(): { output: string[], object_type: AlienObject }
---@alias MultiAction { actions: Action[], object_type: AlienObject }

--- Return the output of multiple commands
--- If one of the commands is itself an array, the outputs of the commands in the array will be concatenated on a single line
---@param cmds Array<string | string[]>
---@return string[]
local function get_multiple_outputs(cmds)
	local output = {}
	for _, c in ipairs(cmds) do
		if type(c) == "string" then
			for _, line in ipairs(vim.fn.systemlist(c)) do
				table.insert(output, line)
			end
		end
		if type(c) == "table" then
			for i, cmd in ipairs(c) do
				for _, line in ipairs(vim.fn.systemlist(cmd)) do
					if i == 1 then
						table.insert(output, line)
					else
						output[#output] = output[#output] .. " " .. line
					end
				end
			end
		end
	end
	return output
end

--- Takes a command and returns an Action function
---@param cmd string | (string | string[])[] | fun(): string
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
			local output = get_multiple_outputs(cmd)
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
