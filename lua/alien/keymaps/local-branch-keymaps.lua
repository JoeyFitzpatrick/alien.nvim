local elements = require("alien.elements")
local keymaps = require("alien.config").keymaps.local_branch
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local map_action_with_element = require("alien.keymaps").map_action_with_element

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	local alien_opts = { current_object_type = "local_branch", trigger_redraw = true }

	map_action(keymaps.switch, function(branch)
		return "git switch " .. branch.branch_name
	end, alien_opts, opts)

	map_action_with_input(keymaps.new_branch, function(branch, new_branch_name)
		return "git switch --create " .. new_branch_name .. " " .. branch.branch_name
	end, { prompt = "New branch name: " }, alien_opts, opts)

	map_action_with_input(keymaps.delete, function(branch, location)
		if location == "remote" then
			return "git push origin --delete " .. branch.branch_name
		elseif location == "local" then
			return "git branch --delete " .. branch.branch_name
		end
	end, { items = { "local", "remote" }, prompt = "Delete local or remote: " }, alien_opts, opts)

	map_action_with_input(keymaps.rename, function(branch, new_branch_name)
		return "git branch -m " .. branch.branch_name .. " " .. new_branch_name
	end, { prompt = "Rename branch: " }, alien_opts, opts)

	map_action(keymaps.merge, function(branch)
		return "git merge " .. branch.branch_name
	end, alien_opts, opts)

	map_action(keymaps.rebase, function(branch)
		return "git rebase " .. branch.branch_name
	end, alien_opts, opts)

	map_action_with_element(keymaps.log, function(branch)
		return "git log " .. branch.branch_name .. " --oneline"
	end, { element = elements.buffer, object_type = "commit", trigger_redraw = false }, alien_opts, opts)
end

return M
