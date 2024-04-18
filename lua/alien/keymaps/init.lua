local commands = require("alien.commands")
local window = require("alien.window")
local diff = require("alien.status.diff")

local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local M = {}
M.redraw_status_buffer = function()
	local buffer_args = require("alien.status").get_buffer_args()
	vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_get_current_buf() })
	buffer_args.set_lines()
	vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_get_current_buf() })
end
M.set_status_buffer_keymaps = function(bufnr)
	local map = function(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, keymap_opts(bufnr))
	end

	map("q", "<cmd>tabclose<CR>")
	map("a", function()
		vim.fn.system(commands.stage_or_unstage_all())
		M.redraw_status_buffer()
	end)
	map("<space>", function()
		local file = window.get_file_name_from_tree()
		if not file then
			print("no file found")
			return
		end

		vim.fn.system(commands.stage_or_unstage_file(file.status, file.filename))
		M.redraw_status_buffer()
	end)
	map("p", function()
		local result = "git pull: \n" .. vim.fn.system(commands.pull)
		vim.notify(result)
		M.redraw_status_buffer()
	end)
	map("P", function()
		local result = "git push: \n" .. vim.fn.system(commands.push)
		vim.notify(result)
		M.redraw_status_buffer()
	end)

	-- TODO: make this work without leader
	-- probably the same as lazygit: allow force push after attempting a regular push
	map("<leader>P", function()
		local result = "git force push: \n" .. vim.fn.system(commands.force_push)
		vim.notify(result)
		M.redraw_status_buffer()
	end)

	map("c", function()
		vim.ui.input({ prompt = "Commit message: " }, function(input)
			local result = "git commit: \n" .. vim.fn.system(commands.commit(input))
			vim.notify(result)
		end)
		M.redraw_status_buffer()
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
		M.redraw_status_buffer()
	end)
end

return M
