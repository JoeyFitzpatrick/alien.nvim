local TERM_PREFIX = "term://"
local create_shell_buf_name = function(cmd)
	return cmd
	-- return TERM_PREFIX .. cmd
end

local M = {}

---@type table<string, integer>
local buffers = {}
vim.keymap.set("n", "<leader>b", function()
	print(vim.inspect(buffers))
end)

---@param buf_name string
---@param get_lines function
---@param opts { filetype: string | nil, window: integer, post_switch: function | nil, mappings: table | nil, terminal: boolean | nil}
---@return integer
M.create_buffer = function(buf_name, get_lines, opts)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(bufnr, buf_name)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
	vim.api.nvim_set_option_value(
		"filetype",
		opts.filetype or require("plenary.filetype").detect_from_extension(buf_name),
		{ buf = bufnr }
	)

	local lines = get_lines()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

	buffers[buf_name] = bufnr
	return bufnr
end

M.create_shell_buffer = function(cmd, opts)
	local bufnr = vim.api.nvim_create_buf(false, true)
	local buf_name = create_shell_buf_name(cmd)
	vim.api.nvim_buf_set_name(bufnr, buf_name)
	vim.api.nvim_buf_call(bufnr, function()
		vim.fn.termopen(cmd)
	end)
	buffers[buf_name] = bufnr
	return bufnr
end

--- Switch to a buffer by name
---@param bufnr integer
---@param opts {  window: integer, post_switch: function | nil, mappings: table | nil}
---@return nil
M.switch_to_buffer = function(bufnr, opts)
	vim.api.nvim_set_current_win(opts.window)
	vim.api.nvim_set_current_buf(bufnr)
end

---@param buf_name string
---@param get_lines function
---@param opts { filetype: string | nil, window: integer, post_switch: function | nil, mappings: table | nil, terminal: boolean | nil}
---@return nil
M.get_buffer = function(buf_name, get_lines, opts)
	if buffers[buf_name] then
		M.switch_to_buffer(buffers[buf_name], opts)
		return
	end

	local bufnr = M.create_buffer(buf_name, get_lines, opts)
	M.switch_to_buffer(bufnr, opts)
	if opts.post_switch then
		opts.post_switch()
	end
	if opts.mappings then
		require("alien.keymaps").set_buffer_keymaps(0, opts.mappings)
	end
end

M.get_shell_buffer = function(cmd, opts)
	local buf_name = create_shell_buf_name(cmd)
	if buffers[buf_name] then
		M.switch_to_buffer(buffers[buf_name], opts)
		return
	end
	local bufnr = M.create_shell_buffer(cmd, opts)
	M.switch_to_buffer(bufnr, opts)
end

M.close_all = function()
	for _, bufnr in pairs(buffers) do
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
	buffers = {}
end

return M
