local M = {}

---@alias Object "commit" | "local_file" | "commit_file" | nil
---@alias Action { get: fun(): string[], object_type: Object }

---@param get fun(): string[]
---@return number
local function create(get)
	local lines = get()
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	return bufnr
end

--- Create a new buffer with the given action, and open it in a floating window
---@param action Action
---@param opts vim.api.keyset.win_config | nil
---@return number
M.float = function(action, opts)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	---@type vim.api.keyset.win_config
	local default_float_opts = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
	}
	local float_opts = vim.tbl_extend("force", default_float_opts, opts or {})
	local bufnr = create(action.get)
	vim.api.nvim_open_win(bufnr, true, float_opts)
	return bufnr
end

--- Create a new buffer with the given action, and open it in a new split
---@param action Action
---@param opts vim.api.keyset.win_config | nil
---@return number
M.split = function(action, opts)
	---@type vim.api.keyset.win_config
	local default_split_opts = {
		split = "right",
	}
	local float_opts = vim.tbl_extend("force", default_split_opts, opts or {})
	local bufnr = create(action.get)
	vim.api.nvim_open_win(bufnr, true, float_opts)
	return bufnr
end

--- Create a new buffer with the given action, and open it in a new tab
---@param action Action
---@param opts { title: string | nil } | nil
---@return number
M.tab = function(action, opts)
	opts = opts or {}
	local bufnr = create(action.get)
	vim.api.nvim_buf_set_name(bufnr, opts.title or "Alien")
	vim.cmd("tabnew")
	local winnr = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(winnr, bufnr)
	return bufnr
end

--- Create a new buffer with the given action, and open it in a target window
---@param action Action
---@param opts { winnr: number | nil} | nil
---@return number
M.buffer = function(action, opts)
	local default_buffer_opts = { winnr = vim.api.nvim_get_current_win() }
	local buffer_opts = vim.tbl_extend("force", default_buffer_opts, opts or {})
	local bufnr = create(action.get)
	vim.api.nvim_win_set_buf(buffer_opts.winnr, bufnr)
	return bufnr
end

--- Run a command in a new terminal
---@param cmd string
---@param opts vim.api.keyset.win_config | nil
---@return number
M.terminal = function(cmd, opts)
	---@type vim.api.keyset.win_config
	local default_terminal_opts = { split = "right" }
	local terminal_opts = vim.tbl_extend("force", default_terminal_opts, opts or {})
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(bufnr, true, terminal_opts)
	vim.api.nvim_buf_call(bufnr, function()
		vim.fn.termopen(cmd, {
			on_exit = function()
				vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
				vim.cmd(string.format([[silent! %dwindo wincmd p]], bufnr))
			end,
		})
	end)
	return bufnr
end

return M
