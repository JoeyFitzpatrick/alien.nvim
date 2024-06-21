local keymaps = require("alien.keymaps")
local constants = require("alien.constants")

local M = {}

---@alias Window {winnr: number, bufnr: number, channel_id: number | nil, object_type: AlienObject}

---@type Window[]
M.windows = {}

---@return Window | nil
M.get_window_by_object_type = function(object_type)
	if not object_type then
		return nil
	end
	local window = vim.tbl_filter(function(window)
		return window.object_type == object_type
	end, M.windows)[1]
	if not window then
		return nil
	end
	local winnr = vim.tbl_contains(vim.api.nvim_list_wins(), window.winnr)
	if winnr then
		return window
	end
end

local set_buf_options = function(bufnr)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
end

--- Create a new Element with the given action.
--- Also do some side effects, like setting keymaps, highlighting, and buffer local vars.
---@param action Action
---@return number, AlienObject
local function create(action)
	local result = action()
	local lines = result.output
	local new_bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(new_bufnr, 0, -1, false, lines)
	set_buf_options(new_bufnr)
	local highlight = require("alien.highlight").get_highlight_by_object(result.object_type)
	highlight(new_bufnr)
	local redraw = function()
		vim.api.nvim_buf_set_lines(new_bufnr, 0, -1, false, action().output)
		highlight(new_bufnr)
	end
	keymaps.set_keymaps(new_bufnr, result.object_type, redraw)
	return new_bufnr, result.object_type
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
	local bufnr = create(action)
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
	local bufnr = create(action)
	vim.api.nvim_open_win(bufnr, true, float_opts)
	return bufnr
end

--- Create a new buffer with the given action, and open it in a new tab
---@param action Action
---@param opts { title: string | nil } | nil
---@return number
M.tab = function(action, opts)
	opts = opts or {}
	local bufnr = create(action)
	-- vim.api.nvim_buf_set_name(bufnr, opts.title or "Alien")
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
	local bufnr = create(action)
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
	local object_type = require("alien.objects").get_object_type(cmd)
	local window = M.get_window_by_object_type(object_type)
	if window then
		vim.api.nvim_win_set_buf(window.winnr, bufnr)
	else
		local winnr = vim.api.nvim_open_win(bufnr, false, terminal_opts)
		local channel_id = nil
		vim.api.nvim_buf_call(bufnr, function()
			channel_id = vim.fn.termopen(cmd, {
				on_exit = function()
					-- vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
					vim.cmd(string.format([[silent! %dwindo wincmd p]], bufnr))
				end,
			})
		end)
		table.insert(M.windows, { winnr = winnr, bufnr = bufnr, channel_id = channel_id, object_type = object_type })
	end
	return bufnr
end

return M
