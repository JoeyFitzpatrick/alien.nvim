---@diagnostic disable: param-type-mismatch
local commands = require("alien.actions.commands")
local create_command = commands.create_command
local create_action = require("alien.actions.action").create_action
local translate = require("alien.translators.local-branch-translator").translate

---@alias LocalBranch { branch_name: string, is_current_branch: boolean, branch_name_position: Position }

local M = {}

local get_args = function()
	return translate(vim.api.nvim_get_current_line())
end

local create_simple_action = function(cmd, opts)
	return create_action(create_command(cmd, get_args), opts)
end

M.switch = create_simple_action(commands.switch, { trigger_redraw = true })
local new_branch_cmd = function()
	local branch = get_args()
	local new_branch_name = ""
	vim.ui.input({ prompt = "new branch name: " }, function(ui_input)
		new_branch_name = ui_input
	end)
	return commands.new_branch(branch, new_branch_name)
end
M.new_branch = create_action(new_branch_cmd, { trigger_redraw = true })

return M
