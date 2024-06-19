local local_file = require("alien.objects.local-file-object")

local M = {}

M.set_keymaps = function(bufnr, redraw)
	local map = function(keys, fn)
		vim.keymap.set("n", keys, function()
			fn()
			redraw()
		end, { noremap = true, silent = true, buffer = bufnr })
	end
	map("<leader>q", ":q<CR>")
	map("s", local_file.stage_or_unstage)
end

return M
