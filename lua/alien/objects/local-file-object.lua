---@diagnostic disable: param-type-mismatch
local commands = require("alien.actions.commands")
local create_command = commands.create_command
local create_action = require("alien.actions.action").create_action
local translate = require("alien.translators.local-file-translator").translate

---@alias LocalFile { filename: string, file_status: string, filename_position: Position, file_status_position: Position }

local M = {}

local get_args = function()
	return translate(vim.api.nvim_get_current_line())
end

M.stage_or_unstage = create_action(create_command(commands.stage_or_unstage_file, get_args), { trigger_redraw = true })

M.stage_or_unstage_all = create_action(
	create_command(commands.stage_or_unstage_all, function()
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local local_files = {}
		for _, line in ipairs(lines) do
			local local_file = translate(line)
			table.insert(local_files, local_file)
		end
		return local_files
	end),
	{ trigger_redraw = true }
)

M.navigate_to_file = function()
	local filename = get_args().filename
	vim.api.nvim_win_close(0, true)
	vim.api.nvim_exec2("e " .. filename, {})
end

M.restore_file = create_action(create_command(commands.restore_file, get_args), { trigger_redraw = true })

M.pull = create_action(create_command(commands.pull, get_args), { trigger_redraw = true })
M.pull_with_flags = create_action(create_command(commands.pull, get_args), { trigger_redraw = true, add_flags = true })
M.push = create_action(create_command(commands.push, get_args), { trigger_redraw = true })
M.push_with_flags = create_action(create_command(commands.push, get_args), { trigger_redraw = true, add_flags = true })
M.commit = create_action(create_command(commands.commit, get_args), { trigger_redraw = true })

M.diff_native = create_command(commands.diff_native, get_args)

return M
