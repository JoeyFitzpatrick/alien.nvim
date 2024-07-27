local register = require("alien.elements.register")
local action = require("alien.actions.action").action

local M = {}

---@param keys string
---@param fn function
---@param opts vim.keymap.set.Opts
M.map = function(keys, fn, opts)
	vim.keymap.set("n", keys, function()
		fn()
	end, opts)
end

--- Cleaner way to map an action to a keymap
---@param keys string
---@param cmd_fn function
---@param alien_opts AlienOpts
---@param opts vim.keymap.set.Opts
M.map_action = function(keys, cmd_fn, alien_opts, opts)
	M.map(keys, action(cmd_fn, alien_opts), opts)
end

---@param keys string
---@param cmd_fn function
---@param input_opts { prompt: string, items: any[] | nil }
---@param alien_opts AlienOpts
---@param opts vim.keymap.set.Opts
M.map_action_with_input = function(keys, cmd_fn, input_opts, alien_opts, opts)
	if input_opts.items then
		M.map(keys, function()
			vim.ui.select(input_opts.items, { prompt = input_opts.prompt }, function(input)
				action(cmd_fn, alien_opts)(input)
			end)
		end, opts)
	else
		M.map(keys, function()
			vim.ui.input({ prompt = input_opts.prompt }, function(input)
				action(cmd_fn, alien_opts)(input)
			end)
		end, opts)
	end
end

--- Set keymaps by object type for the given buffer
---@param bufnr integer
---@param object_type AlienObject
M.set_object_keymaps = function(bufnr, object_type)
	if object_type == "local_file" then
		require("alien.keymaps.local_file-keymaps").set_keymaps(bufnr)
	elseif object_type == "local_branch" then
		require("alien.keymaps.local-branch-keymaps").set_keymaps(bufnr)
	elseif object_type == "commit" then
		require("alien.keymaps.commit-keymaps").set_keymaps(bufnr)
	end
end

--- Set keymaps by element type for the given buffer
---@param bufnr integer
---@param element_type ElementType
M.set_element_keymaps = function(bufnr, element_type)
	vim.keymap.set("n", "q", function()
		register.close_element(bufnr)
	end, { noremap = true, silent = true, buffer = bufnr })
end

M.set_global_keymaps = require("alien.keymaps.global-keymaps").set_global_keymaps

return M
