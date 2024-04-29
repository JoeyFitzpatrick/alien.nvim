local commands = require("alien.commands")
local redraw_buffer = require("alien.window").redraw_buffer
local map = require("alien.keymaps").map
local set_keymaps = require("alien.keymaps").set_keymaps
local get_buffer_args = require("alien.window.branch").get_buffer_args

local get_branch_name = function()
	local line = vim.api.nvim_get_current_line()
	return require("alien.window.branch").get_branch_name_from_line(line)
end

local M = {}
M.branch_buffer_keymaps = function()
	map("s", function()
		local branch_name = get_branch_name()
		local result = vim.fn.system(commands.checkout_branch(branch_name))
		vim.notify(result)
		redraw_buffer(get_buffer_args())
		require("alien.utils.helpers").reload_named_buffers()
	end)
	map("b", function()
		require("alien.window.branch").display_branch_picker()
	end)
	map("n", function()
		local base_branch = get_branch_name()
		vim.ui.input({ prompt = "New branch name: " }, function(input)
			local result = vim.fn.system(commands.new_branch(base_branch, input))
			vim.notify(result)
		end)
		redraw_buffer(get_buffer_args())
	end)
	map("d", function()
		local branch = get_branch_name()
		vim.ui.select(
			{ "delete local branch", "delete remote branch" },
			{ prompt = "Delete branch: " },
			function(choice)
				local is_current_branch = require("alien.window.branch").is_current_branch(vim.api.nvim_get_current_line())
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
		redraw_buffer(get_buffer_args())
	end)
	set_keymaps()
end

return M
