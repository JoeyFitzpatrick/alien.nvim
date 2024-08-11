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

-- Steps:
-- Get current buffer wrap settings
-- Set current buf to wrap
-- Set new buf to wrap
-- Set new buf and old buf to have synced line nums, using syncbind and scrollbind
-- Set autocmd such that when the blame buffer is closed, the original buffer has wrap set back to what it was, and scrollbind and syncbind are turned off (if needed)
-- Highlight fn should parse commit hash into hex, and make that the color for the hash
-- Also color the date
-- Format the date
-- Add some actions
M.blame = function()
	elements.split(
		action(function()
			return "git blame '"
				.. vim.api.nvim_buf_get_name(0)
				.. "' --date=format-local:'%Y/%m/%d %I:%M %p' | sed -E 's/ +[0-9]+\\)/)/'"
		end),
		{ split = "left" },
		function(win)
			vim.api.nvim_set_option_value("wrap", false, { win = win })
		end
	)
end

return M
