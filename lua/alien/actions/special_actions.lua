local commands = require("alien.actions.commands")
local output_handlers = require("alien.actions.output-handlers")

local M = {}

M.stats_and_status = function()
  require("alien.elements").buffer(commands.status, { output_handler = output_handlers.status_output_handler })
end

return M
