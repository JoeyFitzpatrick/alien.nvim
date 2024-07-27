local keymaps = require("alien.config").keymaps.commit
local elements = require("alien.elements")
local action = require("alien.actions.action").action
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local map = require("alien.keymaps").map

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	local alien_opts = { trigger_redraw = true }
	map(keymaps.commit_info, function()
		elements.float(action(function(commit)
			return "git log -n 1 " .. commit.hash
		end))
	end, opts)

	map_action(keymaps.revert, function(commit)
		return "git revert " .. commit.hash .. " --no-commit"
	end, alien_opts, opts)

	map_action_with_input(keymaps.reword, function(commit, new_message)
		return "git rebase -i --autosquash -x \"git commit --amend -m '" .. new_message .. "'\" " .. commit.hash .. "^"
	end, { prompt = "Updated commit message: " }, alien_opts, opts)
end

return M
