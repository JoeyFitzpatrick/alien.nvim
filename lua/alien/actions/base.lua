local commands = require("alien.actions.commands")
local create_action = require("alien.actions.action").create_action

local M = {}

M.status = create_action(commands.status)
M.stats_and_status = create_action(commands.stats_and_status, "local_file")

return M
