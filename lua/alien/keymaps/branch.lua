local commands = require("alien.commands")
local window = require("alien.window")
local diff = require("alien.status.diff")
local redraw_branch_buffer = require("alien.keymaps").redraw_branch_buffer

local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local get_branch_name = function()
	local line = vim.api.nvim_get_current_line()
	return require("alien.branch").get_branch_name_from_line(line)
end

local M = {}
M.set_status_buffer_keymaps = function(bufnr)
	require("alien.keymaps").set_general_keymaps(bufnr)
	local map = function(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, keymap_opts(bufnr))
	end
	map("<space>", function()
		local branch_name = get_branch_name()
		local result = vim.fn.system(commands.checkout_branch(branch_name))
		vim.notify(result)
		redraw_branch_buffer()
		require("alien.utils.helpers").reload_named_buffers()
	end)
	map("b", function()
		require("alien.branch").display_branch_picker()
	end)
	map("n", function()
		local base_branch = get_branch_name()
		vim.ui.input({ prompt = "New branch name: " }, function(input)
			local result = vim.fn.system(commands.new_branch(base_branch, input))
			vim.notify(result)
		end)
		redraw_branch_buffer()
	end)
	map("d", function()
		local branch = get_branch_name()
		vim.ui.select(
			{ "delete local branch", "delete remote branch" },
			{ prompt = "Delete branch: " },
			function(choice)
				local is_current_branch = require("alien.branch").is_current_branch(vim.api.nvim_get_current_line())
				if choice == "delete local branch" and is_current_branch then
					vim.notify("Cannot delete current branch")
				elseif choice == "delete local branch" then
					local result = vim.fn.system(commands.delete_local_branch(branch))
					vim.notify(result)
				else
					local result = vim.fn.system(commands.delete_remote_branch(branch))
					vim.notify(result)
				end
			end
		)
		redraw_branch_buffer()
	end)
end

return M
