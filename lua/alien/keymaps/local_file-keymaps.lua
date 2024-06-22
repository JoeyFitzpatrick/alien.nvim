local local_file = require("alien.objects.local-file-object")
local elements = require("alien.elements")
local objects = require("alien.objects")

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
		local window = elements.get_window_by_object_type(objects.OBJECT_TYPES.DIFF)
		if window and window.channel_id then
			vim.api.nvim_chan_send(window.channel_id, "j")
		end
	end, opts)
	vim.keymap.set("n", "K", function()
		local window = elements.get_window_by_object_type(objects.OBJECT_TYPES.DIFF)
		if window and window.channel_id then
			vim.api.nvim_chan_send(window.channel_id, "k")
		end
	end, opts)
end

return M
