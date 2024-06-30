local elements = require("alien.elements")
local actions = require("alien.actions")
local highlight = require("alien.highlight")

local M = {}

M.config = {
	local_file = {
		display_diff = true,
	},
}

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	highlight.setup_colors()
end

M.status = function()
	elements.tab(actions.stats_twice, { title = "AlienStatus" })
	elements.split(actions.stats_and_status, { split = "below", height = vim.o.lines - 8 })
end

return M
