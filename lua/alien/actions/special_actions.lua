local commands = require("alien.actions.commands")
local buffer = require("alien.elements").buffer
local status_output_handler = require("alien.actions.output-handlers").status_output_handler

local M = {}

M.stats_and_status = function()
  buffer(commands.status, { output_handler = status_output_handler })
end

return M
