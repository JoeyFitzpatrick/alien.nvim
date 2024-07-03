local elements = require("alien.elements")
local actions = require("alien.actions")
local highlight = require("alien.highlight")

local M = {}

M.config = {
	local_file = {
		display_diff = true,
	},
	keymaps = {
		local_file = {
			stage_or_unstage = "s",
			stage_or_unstage_all = "a",
			restore_file = "d",
			pull = "p",
			push = "<leader>p",
			commit = "c",
			navigate_to_file = "<enter>",
			diff = "n",
			scroll_diff_down = "J",
			scroll_diff_up = "K",
		},
	},
}

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	highlight.setup_colors()
end

M.status = function()
	elements.tab(actions.stats_and_status, { title = "AlienStatus" })
end

return M
