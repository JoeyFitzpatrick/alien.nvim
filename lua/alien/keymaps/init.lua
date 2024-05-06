local window = require("alien.window")
local floating_window = require("alien.window.floating-window")
local helpers = require("alien.utils.helpers")

local M = {}

---@alias AlienMappings table<string, { [1]: function, [2]: string }>
---@type AlienMappings
M.window_mappings = {
	q = { window.close_tab, "Close tab" },
	l = { window.open_next_buffer, "Open next buffer" },
	h = { window.open_previous_buffer, "Open previous buffer" },
}

---@type AlienMappings
M.mappings = {}

local clear_mappings = function()
	M.mappings = {}
end

M.map = function(lhs, rhs, desc)
	M.mappings[lhs] = { rhs, desc }
end

---@param type "window" | "buffer" | "none"
M.set_keymaps = function(type)
	local mappings = M.mappings
	if type == "window" then
		mappings = vim.tbl_extend("force", mappings, M.window_mappings)
	end
	for keys, mapping in pairs(mappings) do
		vim.keymap.set(
			"n",
			keys,
			mapping[1],
			{ nowait = true, noremap = true, silent = true, buffer = 0, desc = mapping[2] }
		)
	end
	vim.keymap.set("n", "g?", function()
		M.display_keymaps(helpers.copy(mappings))
	end, { nowait = true, noremap = true, silent = true, buffer = 0, desc = "Display keymaps" })
	clear_mappings()
end

M.set_buffer_keymaps = function(bufnr, mappings)
	for keys, fn in pairs(mappings) do
		vim.keymap.set("n", keys, fn, { nowait = true, noremap = true, silent = true, buffer = bufnr })
	end
end

---@param keymaps AlienMappings
M.display_keymaps = function(keymaps)
	local lines = {}
	for keys, mapping in pairs(keymaps) do
		table.insert(lines, keys .. " - " .. mapping[2])
	end
	floating_window.create(lines)
end

return M
