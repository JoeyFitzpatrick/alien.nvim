local window = require("alien.window")
local floating_window = require("alien.window.floating-window")

local M = {}

---@alias AlienMappings table<string, { [1]: function, [2]: string }>
---@type AlienMappings
M.mappings = {
	q = { window.close_tab, "Close tab" },
	l = { window.open_next_buffer, "Open next buffer" },
	h = { window.open_previous_buffer, "Open previous buffer" },
}
M.map = function(lhs, rhs, desc)
	M.mappings[lhs] = { rhs, desc }
end

M.set_keymaps = function()
	for keys, mapping in pairs(M.mappings) do
		vim.keymap.set(
			"n",
			keys,
			mapping[1],
			{ nowait = true, noremap = true, silent = true, buffer = 0, desc = mapping[2] }
		)
	end
	vim.keymap.set(
		"n",
		"g?",
		M.display_keymaps,
		{ nowait = true, noremap = true, silent = true, buffer = 0, desc = "Display keymaps" }
	)
end

M.set_buffer_keymaps = function(bufnr, mappings)
	for keys, fn in pairs(mappings) do
		vim.keymap.set("n", keys, fn, { nowait = true, noremap = true, silent = true, buffer = bufnr })
	end
end

---@param keymaps AlienMappings | nil
M.display_keymaps = function(keymaps)
	keymaps = keymaps or M.mappings
	local lines = {}
	for keys, mapping in pairs(keymaps) do
		table.insert(lines, keys .. " - " .. mapping[2])
	end
	floating_window.create(lines)
end

return M
