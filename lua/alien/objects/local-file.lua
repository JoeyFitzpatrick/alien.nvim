local commands = require("alien.actions.commands")
local create_action = require("alien.actions.action").create_action
local translate = require("alien.translators.local-file").translate

---@alias LocalFile { filename: string, file_status: string }

local M = {}

local get_stage_or_unstage_cmd = function()
	local args = translate(vim.api.nvim_get_current_line())
	if not args then
		return nil
	end
	return commands.stage_or_unstage_file(args)
end

M.stage_or_unstage = create_action(get_stage_or_unstage_cmd)

return M
