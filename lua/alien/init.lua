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
	elements.tab(actions.stats_and_status, { title = "AlienStatus" })
	elements.split({ actions.stats, actions.stats }, { split = "above", height = 3 })
end

return M
