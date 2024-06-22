local local_file = require("alien.objects.local-file-object")
local elements = require("alien.elements")

local M = {}

M.set_keymaps = function(bufnr, redraw)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	local map = function(keys, fn)
		vim.keymap.set("n", keys, function()
			fn()
			redraw()
		end, opts)
	end
	map("s", local_file.stage_or_unstage)
	map("a", local_file.stage_or_unstage_all)
	map("d", local_file.restore_file)
	map("<enter>", local_file.navigate_to_file)
	vim.keymap.set("n", "n", function()
		elements.terminal(local_file.diff_native())
	end, opts)
	vim.keymap.set("n", "J", function()
		local buffers = elements.get_child_buffers_of_type("diff")
		local buffer = buffers[1]
		if #buffers == 1 and buffer.channel_id then
			vim.api.nvim_chan_send(buffer.channel_id, "j")
		end
	end, opts)
	vim.keymap.set("n", "K", function()
		local buffers = elements.get_child_buffers_of_type("diff")
		local buffer = buffers[1]
		if #buffers == 1 and buffer.channel_id then
			vim.api.nvim_chan_send(buffer.channel_id, "k")
		end
	end, opts)

	local alien_status_group = vim.api.nvim_create_augroup("AlienStatus", { clear = true })
	vim.api.nvim_create_autocmd("CursorMoved", {
		desc = "Diff the file under the cursor",
		buffer = bufnr,
		callback = function()
			elements.close_child_buffers_of_type("diff")
			elements.terminal(local_file.diff_native())
		end,
		group = alien_status_group,
	})
end

return M
