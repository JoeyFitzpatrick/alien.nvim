local get_object_type = require("alien.objects").get_object_type
local commands = require("alien.actions.commands")

local M = {}

---@alias Action fun(): { output: string[], object_type: AlienObject }
---@alias MultiAction { actions: Action[], object_type: AlienObject }
---@alias AlienCommand string | fun(): string

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

--- Parses a command from an AlienCommand, which is a very lenient data type
---@param alien_command AlienCommand
---@param add_flags boolean | nil
---@return string
M.parse_command = function(alien_command, add_flags)
	local cmd = nil
	if type(alien_command) == "function" then
		cmd = alien_command()
	else
		cmd = alien_command
	end
	if add_flags then
		cmd = commands.add_flags_input(cmd)
	end
	return cmd
end

--- Takes a command and returns an Action function
---@param cmd AlienCommand | AlienCommand[]
---@param opts { object_type: AlienObject | nil, trigger_redraw: boolean | nil, add_flags: boolean | nil, output_handler: nil | fun(output: string[]): string[] } | nil }
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
				local cmd_fn_result = M.parse_command(cmd, opts.add_flags)
				return {
					output = { handle_output(vim.fn.systemlist(cmd_fn_result)) },
					object_type = object_type or get_object_type(cmd()),
				}
			end
			redraw()
			return fn()
		end
		local output = vim.fn.systemlist(M.parse_command(cmd, opts.add_flags))
		redraw()
		return { output = handle_output(output), object_type = object_type or get_object_type(cmd) }
	end
end

return M
