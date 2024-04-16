local commands = require("alien.commands")
local utils = require("alien.utils")
local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local function git_diff_current_buffer()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_window = vim.api.nvim_get_current_win()
	local filename = vim.api.nvim_get_current_line()
	filename = filename:sub(4) -- Remove the first three characters (M, A, D, etc.)
	local filetype = vim.fn.fnamemodify(filename, ":e") -- Extract the file extension

	-- Read the file contents from the last commit
	local git_command = "git show HEAD:" .. filename
	local last_commit_content = vim.fn.systemlist(git_command)
	if vim.v.shell_error ~= 0 then
		print("Error reading from git. Make sure you are in a git repository and the file is tracked.")
		return
	end

	vim.cmd("bo vsplit " .. filename)
	-- Create a non-writable, non-file buffer with the file contents
	vim.cmd("vnew")
	vim.api.nvim_set_option_value("buftype", "nofile", { scope = "local" })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { scope = "local" })
	vim.api.nvim_set_option_value("filetype", filetype, { scope = "local" })
	vim.api.nvim_buf_set_lines(0, 0, -1, false, last_commit_content)

	-- Set diff mode for both windows
	vim.cmd("wincmd l") -- Move to the new (right) window
	vim.cmd("diffthis")
	vim.cmd("wincmd h") -- Move to the original (left) window
	vim.cmd("diffthis")

	-- Restore the original state
	vim.api.nvim_set_current_win(current_window)
	vim.api.nvim_win_set_cursor(0, cursor_pos)
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

	vim.keymap.set("n", "s", function()
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

	vim.keymap.set("n", "S", git_diff_current_buffer, keymap_opts(bufnr))
end

return M
