local local_file = require("alien.objects.local-file-object")
local elements = require("alien.elements")
local keymaps = require("alien.config").keymaps.local_file

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	local map = function(keys, fn)
		vim.keymap.set("n", keys, function()
			fn()
		end, opts)
	end
	map(keymaps.stage_or_unstage, local_file.stage_or_unstage)
	map(keymaps.stage_or_unstage_all, local_file.stage_or_unstage_all)
	map(keymaps.restore_file, local_file.restore_file)
	map(keymaps.pull, local_file.pull)
	map(keymaps.push, local_file.push)
	map(keymaps.commit, function()
		elements.terminal("git commit")
	end)
	map(keymaps.navigate_to_file, local_file.navigate_to_file)
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

	local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = false })
	vim.api.nvim_create_autocmd("CursorMoved", {
		desc = "Diff the file under the cursor",
		buffer = bufnr,
		callback = function()
			elements.register.close_child_elements({ object_type = "diff", element_type = "terminal" })
			local width = math.floor(vim.o.columns * 0.67)
			elements.terminal(local_file.diff_native(), { width = width })
		end,
		group = alien_status_group,
	})
end

return M
