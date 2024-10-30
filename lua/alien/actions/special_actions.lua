local commands = require("alien.actions.commands")
local create_action = require("alien.actions.action").create_action
local output_handlers = require("alien.actions.output-handlers")

local M = {}

M.stats_and_status = create_action(commands.status, {
  object_type = "local_file",
  output_handler = output_handlers.status_output_handler,
})

return M
