local status = require("alien.window.status")
local branch = require("alien.window.branch")
local helpers = require("alien.utils.helpers")
local constants = require("alien.window.constants")
local diff = require("alien.window.status.diff")

local function to_hex(dec)
	local hex = ""
	if type(dec) == "string" then
		hex = dec
	else
		hex = string.format("%x", dec)
	end
	local new_hex = ""
	if #hex < 6 then
		new_hex = string.rep("0", 6 - #hex) .. hex
	else
		new_hex = hex
	end
	return new_hex
end

local function get_colors(name)
	local success, color = pcall(vim.api.nvim_get_hl, 0, { name = name })
	if not success then
		print("Could not retrieve highlight group:", name)
		return nil
	end

	if color["link"] then
		return to_hex(get_colors(color["link"]))
	elseif color["reverse"] and color["bg"] then
		return to_hex(color["bg"])
	elseif color["fg"] then
		return to_hex(color["fg"])
	end
end

local M = {}
local get_next_buffer_type = function(buffer_type)
	local index = helpers.next_index(constants.BUFFER_TYPE_ARRAY, buffer_type)
	return constants.BUFFER_TYPE_ARRAY[index]
end
local get_previous_buffer_type = function(buffer_type)
	local index = helpers.prev_index(constants.BUFFER_TYPE_ARRAY, buffer_type)
	return constants.BUFFER_TYPE_ARRAY[index]
end
M.close_tab = function()
	local current_tab = vim.api.nvim_get_current_tabpage()
	vim.cmd("bdelete")
	if vim.api.nvim_get_current_tabpage() == current_tab then
		vim.cmd("tabclose")
	end
end
M.open_next_buffer = function()
	local buffer_type = vim.api.nvim_buf_get_var(0, require("alien.window.constants").ALIEN_BUFFER_TYPE)
	local next_buffer_type = get_next_buffer_type(buffer_type)
	M.close_tab()
	M.open_window(next_buffer_type)
end
M.open_previous_buffer = function()
	local buffer_type = vim.api.nvim_buf_get_var(0, require("alien.window.constants").ALIEN_BUFFER_TYPE)
	local prev_buffer_type = get_previous_buffer_type(buffer_type)
	M.close_tab()
	M.open_window(prev_buffer_type)
end
M.open_alien_buffer = function(opts)
	local buffer_type = opts.buffer_type
	local set_lines = opts.set_lines
	local cursor_pos = opts.cursor_pos
	local post_open_hook = opts.post_open_hook
	local set_keymaps = opts.set_keymaps
	local set_colors = opts.set_colors
	-- Create a new tab
	vim.cmd("tabnew")
	vim.cmd("setlocal norelativenumber")

	set_lines()
	vim.api.nvim_buf_set_var(0, require("alien.window.constants").ALIEN_BUFFER_TYPE, buffer_type)

	vim.api.nvim_win_set_cursor(0, cursor_pos)
	-- Get the current buffer number
	local bufnr = vim.api.nvim_get_current_buf()

	-- local TAB_LABEL = "Alien | Git Status"
	-- vim.api.nvim_buf_set_name(bufnr, TAB_LABEL)
	-- Make the buffer unmodifiable
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = bufnr })
	vim.api.nvim_buf_set_var(bufnr, require("alien.window.status.constants").IS_ALIEN_GIT_STATUS_BUFFER, true)
	if set_colors then
		set_colors(bufnr)
	end
	if set_keymaps then
		set_keymaps(bufnr)
	end
	if post_open_hook then
		post_open_hook()
	end
end

M.redraw_buffer = function(buffer_args)
	vim.api.nvim_set_option_value("modifiable", true, { buf = vim.api.nvim_get_current_buf() })
	buffer_args.set_lines()
	buffer_args.set_colors()
	vim.api.nvim_set_option_value("modifiable", false, { buf = vim.api.nvim_get_current_buf() })
end

M.git_status = function()
	M.open_alien_buffer(status.get_buffer_args())
	local alien_status_group = vim.api.nvim_create_augroup("AlienStatus", { clear = true })
	vim.api.nvim_create_autocmd("CursorMoved", {
		desc = "Diff the file under the cursor",
		buffer = 0,
		callback = diff.git_diff_current_buffer,
		group = alien_status_group,
	})
end

M.git_branches = function()
	M.open_alien_buffer(branch.get_buffer_args())
end

M.open_window = function(type)
	if type == constants.BUFFER_TYPES.STATUS then
		M.git_status()
	elseif type == constants.BUFFER_TYPES.BRANCHES then
		M.git_branches()
	end
end

M.get_palette = function()
	local bg = get_colors("Normal")
	local red = get_colors("Error")
	local orange = get_colors("SpecialChar")
	local yellow = "e9b770"
	-- local yellow = get_colors("PreProc")
	local green = get_colors("String")
	local cyan = get_colors("Operator")
	local blue = get_colors("Macro")
	local purple = "e1a2da"
	-- local purple = get_colors("Include")
	return {
		bg = "#" .. bg,
		red = "#" .. red,
		orange = "#" .. orange,
		yellow = "#" .. yellow,
		green = "#" .. green,
		cyan = "#" .. cyan,
		blue = "#" .. blue,
		purple = "#" .. purple,
	}
end

M.get_file_name_from_tree = function()
	local line = vim.api.nvim_get_current_line()
	local git_status = line:sub(1, 2)
	local filename = line:sub(4)
	return { status = git_status, filename = filename }
end
return M
