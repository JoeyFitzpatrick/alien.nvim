---@diagnostic disable: param-type-mismatch
local keymaps = require("alien.config").keymaps.commit_file
local commands = require("alien.actions.commands")
local elements = require("alien.elements")
local translate = require("alien.translators.commit-file-translator").translate
local get_args = commands.get_args(translate)
local action = require("alien.actions.action").action
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local map = require("alien.keymaps").map

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	local alien_opts = { trigger_redraw = true }

	vim.keymap.set("n", keymaps.scroll_diff_down, function()
		local buffers = elements.register.get_child_elements({ object_type = "diff" })
		local buffer = buffers[1]
		if #buffers == 1 and buffer.channel_id then
			pcall(vim.api.nvim_chan_send, buffer.channel_id, "jj")
		end
	end, opts)
	vim.keymap.set("n", keymaps.scroll_diff_up, function()
		local buffers = elements.register.get_child_elements({ object_type = "diff" })
		local buffer = buffers[1]
		if #buffers == 1 and buffer.channel_id then
			pcall(vim.api.nvim_chan_send, buffer.channel_id, "kk")
		end
	end, opts)
	-- Autocmds
	local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
	vim.api.nvim_create_autocmd("CursorMoved", {
		desc = "Diff the commit file under the cursor",
		buffer = bufnr,
		callback = function()
			elements.register.close_child_elements({ object_type = "diff", element_type = "terminal" })
			local width = math.floor(vim.o.columns * 0.67)
			if vim.api.nvim_get_current_buf() == bufnr then
				local ok, cmd = pcall(commands.create_command(function(commit_file)
					return "git show " .. commit_file.hash .. " -- " .. commit_file.filename
				end, get_args))
				vim.print(ok, cmd)
				if ok then
					elements.terminal(cmd, { window = { width = width } })
				end
			end
		end,
		group = alien_status_group,
	})
end

return M
