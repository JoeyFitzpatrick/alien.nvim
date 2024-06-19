local elements = require("alien.elements")
local actions = require("alien.actions")
local highlight = require("alien.highlight")

local M = {}

M.config = { test = "test" }

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	highlight.setup_colors()
end

M.status = function()
	elements.tab(actions.status, { title = "AlienStatus" })
end

return M
