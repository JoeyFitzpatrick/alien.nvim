local commit = require("alien.objects.commit-object")
local keymaps = require("alien.config").keymaps.commit
local map = require("alien.keymaps").map

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
	map(keymaps.revert, commit.revert, opts)
end

return M
