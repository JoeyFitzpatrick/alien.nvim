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
M.open_status_buffer = function(callback)
	-- Create a new tab
	vim.cmd("tabnew")

	callback()
	-- Get the current buffer number
	local bufnr = vim.api.nvim_get_current_buf()

	-- Make the buffer unmodifiable
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = bufnr })
	require("alien.keymaps").set_status_buffer_keymaps(bufnr)
end

M.get_palette = function()
	local bg = get_colors("Normal")
	local red = get_colors("Error")
	local orange = get_colors("SpecialChar")
	local yellow = get_colors("PreProc")
	local green = get_colors("String")
	local cyan = get_colors("Operator")
	local blue = get_colors("Macro")
	local purple = get_colors("Include")
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

M.get_status_prefix = function(str)
	return str:sub(1, 2)
end

M.set_buffer_colors = function()
	local colors = M.get_palette()
	local line_count = vim.api.nvim_buf_line_count(0)

	for line_number = 1, line_count do
		local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

		local status_prefix = M.get_status_prefix(line)

		-- Now that we have the status prefix, check the conditions.
		if status_prefix:sub(1, 1) ~= " " and status_prefix:sub(2, 2) == " " then
			vim.cmd(string.format("highlight %s guifg=%s", "AlienStaged", colors.green))
			vim.api.nvim_buf_add_highlight(0, -1, "AlienStaged", line_number - 1, 0, -1)
		elseif status_prefix == "MM" then
			vim.cmd(string.format("highlight %s guifg=%s", "AlienPartiallyStaged", colors.orange))
			vim.api.nvim_buf_add_highlight(0, -1, "AlienPartiallyStaged", line_number - 1, 0, -1)
		elseif status_prefix == "??" or status_prefix:sub(1, 1) == " " then
			vim.cmd(string.format("highlight %s guifg=%s", "AlienUnstaged", colors.red))
			vim.api.nvim_buf_add_highlight(0, -1, "AlienUnstaged", line_number - 1, 0, -1)
		end
	end
end

M.get_file_name_from_tree = function()
	local line = vim.api.nvim_get_current_line()
	local status = line:sub(1, 2)
	local filename = line:sub(4)
	return { status = status, filename = filename }
end
return M
