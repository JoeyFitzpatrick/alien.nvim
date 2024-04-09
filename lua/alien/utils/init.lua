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

M.find_status_prefix = function(str)
	local prefixes = {}
	for _ in str:gmatch("%S+") do
		local start_pos, end_pos = _.find(str, _, 1, true)
		table.insert(prefixes, { start_pos, end_pos })
	end

	-- Check if we have at least two non-space character groups found
	if #prefixes >= 2 then
		local second_non_space_start = prefixes[2][1]
		-- Fetch and return the previous three characters
		return str:sub(second_non_space_start - 3, second_non_space_start - 1)
	end
end

M.set_buffer_colors = function()
	local colors = M.get_palette()
	local line_count = vim.api.nvim_buf_line_count(0)

	for line_number = 1, line_count do
		local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

		local status_prefix = M.find_status_prefix(line)

		-- Now that we have the status prefix, check the conditions.
		if status_prefix == "A  " or status_prefix == "M  " then
			vim.cmd(string.format("highlight %s guifg=%s", "AlienStaged", colors.green))
			vim.api.nvim_buf_add_highlight(0, -1, "AlienStaged", line_number - 1, 0, -1)
		elseif status_prefix == "MM " then
			vim.cmd(string.format("highlight %s guifg=%s", "AlienPartiallyStaged", colors.orange))
			vim.api.nvim_buf_add_highlight(0, -1, "AlienPartiallyStaged", line_number - 1, 0, -1)
		elseif status_prefix == "?? " or status_prefix == " M " then
			vim.cmd(string.format("highlight %s guifg=%s", "AlienUnstaged", colors.red))
			vim.api.nvim_buf_add_highlight(0, -1, "AlienUnstaged", line_number - 1, 0, -1)
		end
	end
end

M.get_file_name_from_tree = function()
	local current_win = vim.api.nvim_get_current_win()
	local current_cursor_pos = vim.api.nvim_win_get_cursor(current_win)
	local current_line_num = current_cursor_pos[1]

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local current_line = lines[current_line_num]

	-- Trim the text to remove unwanted leading spaces for more reliable matching.
	current_line = current_line:match("^%s*(.-)%s*$")
	local regex_pattern = "^(%S)%s+(.+)$"
	local file_status, filename = current_line:match(regex_pattern)
	local num_spaces_current_line = #current_line - #current_line:gsub(" ", "")

	-- If no matching status, assume the file status is the first non-whitespace character sequence
	if not file_status or #file_status == 0 then
		file_status = string.match(current_line, "^(%S+)")
	end

	if not filename or #filename == 0 then
		-- If no file name on the current line, we cannot proceed.
		return nil
	end

	return { status = file_status, filename = filename }

	-- 	-- Function that checks the indentation difference
	-- 	local function check_indent(line, base_indentation)
	-- 		local line_indentation = #line - #line:gsub(" ", "")
	-- 		return line_indentation < base_indentation - 1
	-- 	end

	-- 	local path = {}
	-- 	table.insert(path, file_name)

	-- 	for i = current_line_num - 1, 1, -1 do
	-- 		if check_indent(lines[i], num_spaces_current_line) then
	-- 			local folder = lines[i]:match("^%s*(.*)")
	-- 			table.insert(path, 1, folder)
	-- 			num_spaces_current_line = #lines[i] - #lines[i]:gsub(" ", "")
	-- 		end
	-- 	end

	-- 	local full_path = table.concat(path, "/")
	-- 	return { status = file_status, filename = full_path }
end
return M
