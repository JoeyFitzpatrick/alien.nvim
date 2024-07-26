local keymaps = require("alien.config").keymaps.commit
local elements = require("alien.elements")
local map = require("alien.keymaps").map
local action = require("alien.actions.action").action

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	local alien_opts = { current_object_type = "commit", trigger_redraw = true }
	local map_action = function(keys, cmd_fn)
		map(keys, action(cmd_fn, alien_opts), opts)
	end
	local map_action_with_element = function(keys, cmd_fn, action_opts)
		map(keys, action(cmd_fn, vim.tbl_extend("force", alien_opts, action_opts)), opts)
	end
	map_action_with_element(keymaps.commit_info, function(commit)
		return "git log -n 1 " .. commit.hash
	end, { element = elements.float, object_type = "commit", trigger_redraw = false })
end

return M
