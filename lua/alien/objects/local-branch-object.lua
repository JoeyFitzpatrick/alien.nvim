---@diagnostic disable: param-type-mismatch
local commands = require("alien.actions.commands")
local create_command = commands.create_command
local create_action = require("alien.actions.action").create_action
local translate = require("alien.translators.local-branch-translator").translate

---@alias LocalBranch { branch_name: string, is_current_branch: boolean, branch_name_position: Position }

local M = {}

local get_args = commands.get_args(translate)

local create_simple_action = function(cmd, opts)
	return create_action(create_command(cmd, get_args), opts)
end

M.switch = create_simple_action(commands.switch, { trigger_redraw = true })

M.new_branch = function()
	vim.ui.input({ prompt = "New branch name: " }, function(input)
		create_action(create_command(commands.new_branch, get_args(input)), { trigger_redraw = true })()
	end)
end

M.delete = function()
	vim.ui.select({ "local", "remote" }, "Delete local or remote: ", function(choice)
		create_action(create_command(commands.delete_branch, get_args(choice)), { trigger_redraw = true })()
	end)
end

M.rename = function()
	vim.ui.input({ prompt = "Rename branch: " }, function(input)
		create_action(create_command(commands.rename_branch, get_args(input)), { trigger_redraw = true })()
	end)
end
M.merge = create_simple_action(commands.merge_branch)
M.rebase = create_simple_action(commands.rebase_branch)

return M
