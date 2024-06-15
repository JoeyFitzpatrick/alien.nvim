local M = {}

---
---@param action fun(): string[]
---@return string[]
local run_action = function(action)
	return action()
end

---@param bufnr number
---@param opts table | nil
local split = function(bufnr, opts)
	opts = opts or {}
	vim.cmd.split(opts)
	vim.api.nvim_win_set_buf(0, bufnr)
end

---@param type "float" | "split" | "tab" | "buffer"
---@param action fun(): string[]
---@param opts table | nil
M.create = function(type, action, opts)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, run_action(action))
	if type == "split" then
		split(bufnr, opts)
	end
end

return M
