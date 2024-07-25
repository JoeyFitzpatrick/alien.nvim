---@diagnostic disable: param-type-mismatch
local commands = require("alien.actions.commands")
local create_command = commands.create_command
local create_action = require("alien.actions.action").create_action
local translate = require("alien.translators.commit-translator").translate

---@alias Commit { hash: string }

local M = {}

local get_args = commands.get_args(translate)

local create_simple_action = function(cmd, opts)
	return create_action(create_command(cmd, get_args), opts)
end

M.revert = create_simple_action(commands.revert, { trigger_redraw = true })

return M
