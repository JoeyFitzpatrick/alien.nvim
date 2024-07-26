local elements = require("alien.elements")
local actions = require("alien.actions")
local action = require("alien.actions.action").action
local highlight = require("alien.highlight")
local config = require("alien.config")

local M = {}

M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	highlight.setup_colors()
	require("alien.keymaps").set_global_keymaps()
end

M.status = function()
	elements.buffer(actions.stats_and_status, { title = "AlienStatus" })
end

M.local_branches = function()
	elements.buffer(actions.local_branches, { title = "AlienBranches" })
end

return M
