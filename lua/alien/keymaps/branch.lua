local commands = require("alien.commands")
local window = require("alien.window")
local diff = require("alien.status.diff")
local redraw_status_buffer = require("alien.keymaps").redraw_status_buffer

local keymap_opts = function(bufnr)
	return { buffer = bufnr, noremap = true, silent = true }
end

local M = {}
M.set_status_buffer_keymaps = function(bufnr)
	require("alien.keymaps").set_general_keymaps(bufnr)
	local map = function(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, keymap_opts(bufnr))
	end
end

return M
