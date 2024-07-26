local keymaps = require("alien.config").keymaps.commit
local elements = require("alien.elements")
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local map_action_with_element = require("alien.keymaps").map_action_with_element

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	local alien_opts = { current_object_type = "commit", trigger_redraw = true }
	map_action_with_element(keymaps.commit_info, function(commit)
		return "git log -n 1 " .. commit.hash
	end, { element = elements.float, object_type = "commit", trigger_redraw = false }, alien_opts, opts)
end

return M
