local commands = require("alien.commands")
local window = require("alien.window")
local diff = require("alien.status.diff")
local redraw_status_buffer = require("alien.keymaps").redraw_status_buffer

local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local M = {}
M.set_status_buffer_keymaps = function(bufnr)
	require("alien.keymaps").set_general_keymaps(bufnr)
	local map = function(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, keymap_opts(bufnr))
	end

	map("a", function()
		vim.fn.system(commands.stage_or_unstage_all())
		redraw_status_buffer()
	end)
	map("<space>", function()
		local file = window.get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end

		vim.fn.system(commands.stage_or_unstage_file(file.status, file.filename))
		redraw_status_buffer()
	end)
	map("p", function()
		local result = "git pull: \n" .. vim.fn.system(commands.pull)
		vim.notify(result)
		redraw_status_buffer()
	end)
	map("P", function()
		local result = vim.fn.system(commands.push)
		if result:find("fatal: The current branch fake has no upstream branch.") then
			result = vim.fn.system(commands.push_branch_upstream())
		end
		vim.notify(result)
		redraw_status_buffer()
	end)

	-- TODO: make this work without leader
	-- probably the same as lazygit: allow force push after attempting a regular push
	map("<leader>P", function()
		local result = "git force push: \n" .. vim.fn.system(commands.force_push)
		vim.notify(result)
		redraw_status_buffer()
	end)

	map("c", function()
		vim.ui.input({ prompt = "Commit message: " }, function(input)
			local result = "git commit: \n" .. vim.fn.system(commands.commit(input))
			vim.notify(result)
		end)
		redraw_status_buffer()
	end)
	map("j", function()
		vim.cmd("normal! j")
		diff.git_diff_current_buffer()
	end)
	map("k", function()
		vim.cmd("normal! k")
		diff.git_diff_current_buffer()
	end)
	map("d", function()
		local file = window.get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end
		vim.fn.system(commands.restore_file(file))
		redraw_status_buffer()
	end)
end

return M
