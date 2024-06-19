local commands = require("alien.actions.commands")
local create_action = require("alien.actions.action").create_action
local translate = require("alien.translators.local-file-translator").translate

---@alias LocalFile { filename: string, file_status: string, filename_position: Position, file_status_position: Position }

local M = {}

local get_args = function()
	return translate(vim.api.nvim_get_current_line())
end

M.stage_or_unstage = create_action(commands.create_command(commands.stage_or_unstage_file, get_args))

return M
