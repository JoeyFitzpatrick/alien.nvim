local window = require("alien.window")

local M = {}
M.mappings = {
	q = window.close_tab,
	l = window.open_next_buffer,
	h = window.open_previous_buffer,
}
M.map = function(lhs, rhs)
	M.mappings[lhs] = rhs
end

M.set_keymaps = function()
	for keys, fn in pairs(M.mappings) do
		vim.keymap.set("n", keys, fn, { nowait = true, noremap = true, silent = true, buffer = 0 })
	end
end

M.set_buffer_keymaps = function(bufnr, mappings)
	for keys, fn in pairs(mappings) do
		vim.keymap.set("n", keys, fn, { nowait = true, noremap = true, silent = true, buffer = bufnr })
	end
end

return M
