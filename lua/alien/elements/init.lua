local keymaps = require("alien.keymaps")
local constants = require("alien.constants")
local get_object_type = require("alien.objects").get_object_type
local register = require("alien.elements.register")
local autocmds = require("alien.elements.element-autocmds")

local M = {}

M.register = register

local set_buf_options = function(bufnr)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
end

---@param lines string[]
---@param element_params Element
---@return integer
local setup_element = function(lines, element_params)
	local bufnr = vim.api.nvim_create_buf(false, true)
	element_params.bufnr = bufnr
	register.register_element(element_params)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	set_buf_options(bufnr)
	autocmds.set_element_autocmds(bufnr)
	return bufnr
end

--- Create a new Element with the given action.
--- Also do some side effects, like setting keymaps, highlighting, and buffer local vars.
---@param action Action
---@param element_params Element
---@return number, AlienObject
local function create(action, element_params)
	local result = action()
	element_params.object_type = result.object_type
	local new_bufnr = setup_element(result.output, element_params)
	local highlight = require("alien.highlight").get_highlight_by_object(result.object_type)
	highlight(new_bufnr)
	local redraw = function()
		vim.api.nvim_buf_set_lines(new_bufnr, 0, -1, false, action().output)
		highlight(new_bufnr)
	end
	keymaps.set_object_keymaps(new_bufnr, result.object_type, redraw)
	keymaps.set_element_keymaps(new_bufnr, element_params.element_type)
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
	local bufnr = create(action, { element_type = "float" })
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
	local bufnr = create(action, { element_type = "split" })
	vim.api.nvim_open_win(bufnr, true, float_opts)
	return bufnr
end

--- Create a new buffer with the given action, and open it in a new tab
---@param action Action
---@param opts { title: string | nil } | nil
---@return number
M.tab = function(action, opts)
	opts = opts or {}
	vim.cmd("tabnew")
	local bufnr = create(action, { element_type = "tab" })
	vim.api.nvim_buf_set_name(bufnr, opts.title or constants.DEFAULT_TAB_NAME)
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
	local bufnr = create(action, { element_type = "buffer" })
	vim.api.nvim_win_set_buf(buffer_opts.winnr, bufnr)
	return bufnr
end

--- Run a command in a new terminal
---@param cmd string | nil
---@param opts vim.api.keyset.win_config | nil
---@return number | nil
M.terminal = function(cmd, opts)
	if not cmd then
		return
	end
	---@type vim.api.keyset.win_config
	local default_terminal_opts = { split = "right" }
	local terminal_opts = vim.tbl_extend("force", default_terminal_opts, opts or {})
	local bufnr = vim.api.nvim_create_buf(false, true)
	local channel_id = nil
	vim.api.nvim_buf_call(bufnr, function()
		channel_id = vim.fn.termopen(cmd)
	end)
	local object_type = get_object_type(cmd)
	if not channel_id then
		error("Failed to open terminal")
	end
	register.register_element({
		element_type = "terminal",
		bufnr = bufnr,
		channel_id = channel_id,
		object_type = object_type,
	})
	autocmds.set_element_autocmds(bufnr)
	keymaps.set_element_keymaps(bufnr, "terminal")
	vim.api.nvim_open_win(bufnr, false, terminal_opts)
	return bufnr
end

return M
