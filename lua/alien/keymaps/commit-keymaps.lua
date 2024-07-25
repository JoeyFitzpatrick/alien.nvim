local keymaps = require("alien.config").keymaps.commit
local elements = require("alien.elements")
local map = require("alien.keymaps").map
local action = require("alien.actions.action").action

local M = {}

M.set_keymaps = function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }

	local commit_info_cmd = function(commit)
		return "git log -n 1 " .. commit.hash
	end
	local commit_info = action(commit_info_cmd, { object_type = "commit", element = elements.float })

	map(keymaps.commit_info, function()
		vim.ui.input({ prompt = "test: " }, function(input)
			commit_info(input)
		end)
	end, opts)
end

return M
