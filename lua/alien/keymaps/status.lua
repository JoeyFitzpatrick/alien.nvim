local commands = require("alien.commands")
local git_cli = require("alien.git-cli")
local window = require("alien.window")
local redraw_buffer = window.redraw_buffer
local get_buffer_args = require("alien.window.status").get_buffer_args
local map = require("alien.keymaps").map
local set_keymaps = require("alien.keymaps").set_keymaps

local M = {}
M.set_status_buffer_keymaps = function()
	map("a", function()
		git_cli.stage_or_unstage_all()
		redraw_buffer(get_buffer_args())
	end, "Stage all")
	map("s", function()
		local file = window.get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end

		git_cli.stage_or_unstage_file(file.status, file.filename)
		redraw_buffer(get_buffer_args())
	end, "Stage/unstage file")
	map("p", function()
		local result = "git pull: \n" .. vim.fn.system(commands.pull)
		vim.notify(result)
		redraw_buffer(get_buffer_args())
	end, "Pull")
	map("P", function()
		local result = vim.fn.system(commands.push)
		if result:find("fatal: The current branch fake has no upstream branch.") then
			result = git_cli.push_branch_upstream()
		end
		vim.notify(result)
		redraw_buffer(get_buffer_args())
	end, "Push")

	map("<leader>P", function()
		local result = "git force push: \n" .. vim.fn.system(commands.force_push)
		vim.notify(result)
		redraw_buffer(get_buffer_args())
	end, "Force push")

	map("c", function()
		vim.ui.input({ prompt = "Commit message: " }, function(input)
			local result = "git commit: \n" .. git_cli.commit(input)
			vim.notify(result)
		end)
		redraw_buffer(get_buffer_args())
	end, "Commit")
	map("d", function()
		local file = window.get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end
		git_cli.restore_file(file)
		redraw_buffer(get_buffer_args())
	end, "Restore file")
	map("<enter>", function()
		local file = window.get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end
		window.close_tab()
		vim.api.nvim_exec2("e " .. file.filename, {})
	end, "Restore file")
	set_keymaps("window")
end

return M
