local commands = require("alien.commands")
local utils = require("alien.utils")
local diff = require("alien.status.diff")

local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local M = {}
M.redraw_status_buffer = function()
	local set_lines = require("alien.status").get_status_lines()
	vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_get_current_buf() })
	set_lines()
	vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_get_current_buf() })
end
M.set_status_buffer_keymaps = function(bufnr)
	vim.keymap.set("n", "q", ":q<CR>", keymap_opts(bufnr))

	vim.keymap.set("n", "a", function()
		vim.fn.system(commands.stage_or_unstage_all())
		M.redraw_status_buffer()
	end, keymap_opts(bufnr))

	vim.keymap.set("n", "<space>", function()
		local file = utils.get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end

		vim.fn.system(commands.stage_or_unstage_file(file.status, file.filename))
		M.redraw_status_buffer()
	end, keymap_opts(bufnr))

	vim.keymap.set("n", "p", function()
		local result = "git pull: \n" .. vim.fn.system(commands.pull)
		vim.notify(result)
		M.redraw_status_buffer()
	end, keymap_opts(bufnr))

	vim.keymap.set("n", "P", function()
		local result = "git push: \n" .. vim.fn.system(commands.push)
		vim.notify(result)
		M.redraw_status_buffer()
	end, keymap_opts(bufnr))

	-- TODO: make this work without leader
	-- probably the same as lazygit: allow force push after attempting a regular push
	vim.keymap.set("n", "<leader>P", function()
		local result = "git force push: \n" .. vim.fn.system(commands.force_push)
		vim.notify(result)
		M.redraw_status_buffer()
	end, keymap_opts(bufnr))

	vim.keymap.set("n", "C", function()
		vim.ui.input({ prompt = "Commit message: " }, function(input)
			local result = "git commit: \n" .. vim.fn.system(commands.commit(input))
			vim.notify(result)
		end)
		M.redraw_status_buffer()
	end, keymap_opts(bufnr))

	vim.keymap.set("n", "j", function()
		vim.cmd("normal! j")
		diff.git_diff_current_buffer()
	end, keymap_opts(bufnr))

	vim.keymap.set("n", "k", function()
		vim.cmd("normal! k")
		diff.git_diff_current_buffer()
	end, keymap_opts(bufnr))
end

return M
