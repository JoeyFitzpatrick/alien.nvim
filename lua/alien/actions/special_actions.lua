local commands = require("alien.actions.commands")
local output_handlers = require("alien.actions.output-handlers")

local M = {}

M.stats_and_status = function()
  require("alien.elements").buffer(commands.status, {}, function(_, bufnr)
    output_handlers.status_output_handler(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  end)
end

return M
