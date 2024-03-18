local function to_hex(dec)
	print(type(dec))
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
M.open_unmod_tab = function(callback)
	-- Create a new tab
	vim.cmd("tabnew")

	callback()
	-- Get the current buffer number
	local bufnr = vim.api.nvim_get_current_buf()

	-- Make the buffer unmodifiable
	vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = bufnr })
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

M.set_buffer_colors = function()
	local colors = M.get_palette()
	local line_count = vim.api.nvim_buf_line_count(0)

	for line_number = 1, line_count do
		local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

		local first_char = line:match("%s*(%S)")
		if first_char == "M" or first_char == "D" or first_char == "?" then
			vim.cmd(string.format("highlight %s guifg=%s", "AlienRemove", colors.red))
			vim.api.nvim_buf_add_highlight(0, -1, "AlienRemove", line_number - 1, 0, -1)
		elseif first_char == "A" then
			vim.cmd(string.format("highlight %s guifg=%s", "AlienAdd", colors.green))
			vim.api.nvim_buf_add_highlight(0, -1, "AlienAdd", line_number - 1, 0, -1)
		end
	end
end
return M
