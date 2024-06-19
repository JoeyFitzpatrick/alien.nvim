local local_file = require("alien.objects.local-file-object")
local elements = require("alien.elements")

local M = {}

M.set_keymaps = function(bufnr, redraw)
	local map = function(keys, fn)
		vim.keymap.set("n", keys, function()
			fn()
			redraw()
		end, { noremap = true, silent = true, buffer = bufnr })
	end
	map("q", function()
		vim.api.nvim_win_close(0, true)
	end)
	map("s", local_file.stage_or_unstage)
	map("a", local_file.stage_or_unstage_all)
	map("<enter>", local_file.navigate_to_file)
	vim.keymap.set("n", "n", function()
		elements.terminal(local_file.diff_native())
	end, { buffer = bufnr })
	-- map("J", local_file.scroll_diff_down)
	-- map("K", local_file.scroll_diff_up)
end

return M
