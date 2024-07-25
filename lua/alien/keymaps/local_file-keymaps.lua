local local_file = require("alien.objects.local-file-object")
local elements = require("alien.elements")
local keymaps = require("alien.config").keymaps.local_file
local commands = require("alien.actions.commands")
local map = require("alien.keymaps").map

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	map(keymaps.stage_or_unstage, local_file.stage_or_unstage, opts)
	map(keymaps.stage_or_unstage_all, local_file.stage_or_unstage_all, opts)
	map(keymaps.restore_file, local_file.restore_file, opts)
	map(keymaps.pull, local_file.pull, opts)
	map(keymaps.push, local_file.push, opts)
	map(keymaps.pull_with_flags, local_file.pull_with_flags, opts)
	map(keymaps.push_with_flags, local_file.push_with_flags, opts)
	map(keymaps.commit, function()
		vim.ui.input({ prompt = "Commit message: " }, function(input)
			elements.terminal("git commit -m '" .. input .. "'", { window = { split = "right" } })
		end)
	end, opts)
	map(keymaps.commit_with_flags, function()
		local cmd = commands.add_flags_input("git commit")
		elements.terminal(cmd, { window = { split = "right" } })
	end, opts)
	map(keymaps.navigate_to_file, local_file.navigate_to_file, opts)
	vim.keymap.set("n", keymaps.diff, function()
		elements.terminal(local_file.diff_native())
	end, opts)
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

	local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
	vim.api.nvim_create_autocmd("CursorMoved", {
		desc = "Diff the file under the cursor",
		buffer = bufnr,
		callback = function()
			elements.register.close_child_elements({ object_type = "diff", element_type = "terminal" })
			local width = math.floor(vim.o.columns * 0.67)
			if vim.api.nvim_get_current_buf() == bufnr then
				local ok, cmd = pcall(local_file.diff_native)
				if ok then
					elements.terminal(cmd, { window = { width = width } })
				end
			end
		end,
		group = alien_status_group,
	})
end

return M
