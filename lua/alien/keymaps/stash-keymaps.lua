local keymaps = require("alien.config").keymaps.stash
local elements = require("alien.elements")
local action = require("alien.actions.action").action
local multi_action = require("alien.actions.action").multi_action
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local map = require("alien.keymaps").map

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	local alien_opts = { trigger_redraw = true }

	map_action(keymaps.apply, function(stash)
		return string.format("git stash apply stash@{%s}", stash.index)
	end, alien_opts, opts)

	map_action(keymaps.pop, function(stash)
		return string.format("git stash pop stash@{%s}", stash.index)
	end, alien_opts, opts)
end

return M
