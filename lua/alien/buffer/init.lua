-- Buffer should do the following:
-- have a fn that receives a buffer id of some sort (this could be a file name, commit hash, etc), and a fn that gets the lines for the buffer
-- If the buffer doesn't exist, create it and use the fn to get the lines
-- if the buffer does exist, just switch to it
-- Also need a fn that closes all buffers
-- This should keep track of all Alien buffers
--

local M = {}

---@type table<string, integer>
local buffers = {}

---@param buf_name string
---@param get_lines function
---@param opts { filetype: string | nil, window: integer, post_switch: function | nil, mappings: table | nil}
---@return integer
M.create_buffer = function(buf_name, get_lines, opts)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(bufnr, buf_name)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
	vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
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

--- Switch to a buffer by name
---@param bufnr integer
---@param opts {  window: integer, post_switch: function | nil, mappings: table | nil}
---@return nil
M.switch_to_buffer = function(bufnr, opts)
	vim.api.nvim_set_current_win(opts.window)
	vim.api.nvim_set_current_buf(bufnr)
	if opts.post_switch then
		opts.post_switch()
	end
	if opts.mappings then
		require("alien.keymaps").set_buffer_keymaps(0, opts.mappings)
	end
end

---@param buf_name string
---@param get_lines function
---@param opts { filetype: string | nil, window: integer, post_switch: function | nil, mappings: table | nil}
---@return nil
M.get_buffer = function(buf_name, get_lines, opts)
	if buffers[buf_name] then
		M.switch_to_buffer(buffers[buf_name], opts)
		return
	end

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(bufnr, buf_name)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
	vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
	vim.api.nvim_set_option_value(
		"filetype",
		opts.filetype or require("plenary.filetype").detect_from_extension(buf_name),
		{ buf = bufnr }
	)

	local lines = get_lines()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

	buffers[buf_name] = bufnr
	M.switch_to_buffer(bufnr, opts)
end

M.close_all = function()
	for _, bufnr in pairs(buffers) do
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
	buffers = {}
end

return M
