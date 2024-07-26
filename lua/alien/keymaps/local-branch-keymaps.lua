local elements = require("alien.elements")
local keymaps = require("alien.config").keymaps.local_branch
local action = require("alien.actions.action").action
local map = require("alien.keymaps").map

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	local alien_opts = { current_object_type = "local_branch", trigger_redraw = true }
	local map_action = function(keys, cmd_fn)
		map(keys, action(cmd_fn, alien_opts), opts)
	end
	local map_action_with_input = function(keys, cmd_fn, input_opts)
		if input_opts.items then
			map(keys, function()
				vim.ui.select(input_opts.items, { prompt = input_opts.prompt }, function(input)
					action(cmd_fn, alien_opts)(input)
				end)
			end, opts)
		else
			map(keys, function()
				vim.ui.input({ prompt = input_opts.prompt }, function(input)
					action(cmd_fn, alien_opts)(input)
				end)
			end, opts)
		end
	end

	map_action(keymaps.switch, function(branch)
		return "git switch " .. branch.branch_name
	end)

	map_action_with_input(keymaps.new_branch, function(branch, new_branch_name)
		return "git switch --create " .. new_branch_name .. " " .. branch.branch_name
	end, { prompt = "New branch name: " })

	map_action_with_input(keymaps.delete, function(branch, location)
		if location == "remote" then
			return "git push origin --delete " .. branch.branch_name
		elseif location == "local" then
			return "git branch --delete " .. branch.branch_name
		end
	end, { items = { "local", "remote" }, prompt = "Delete local or remote: " })

	map_action_with_input(keymaps.rename, function(branch, new_branch_name)
		return "git branch -m " .. branch.branch_name .. " " .. new_branch_name
	end, { prompt = "Rename branch: " })

	map_action(keymaps.merge, function(branch)
		return "git merge " .. branch.branch_name
	end)

	map_action(keymaps.rebase, function(branch)
		return "git rebase " .. branch.branch_name
	end)

	local map_action_with_element = function(keys, cmd_fn, action_opts)
		map(keys, function()
			action(cmd_fn, vim.tbl_extend("force", alien_opts, action_opts))()
		end, opts)
	end
	map_action_with_element(keymaps.log, function(branch)
		return "git log " .. branch.branch_name .. " --oneline"
	end, { element = elements.buffer, object_type = "commit", trigger_redraw = false })
end

return M
