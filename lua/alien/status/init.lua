local M = {}
M.get_status_lines = function()
	local status_command = require("alien.commands").status
	local git_status_output = vim.fn.systemlist(status_command)

	-- Parse the output into a tree structure
	local file_tree = {}
	for _, line in ipairs(git_status_output) do
		-- Split the line into status code and file path
		local status, file_path = line:sub(1, 2), line:sub(4)
		-- Create a hierarchy of directories and files
		local path_parts = vim.split(file_path, "/")
		local current_level = file_tree
		for i, part in ipairs(path_parts) do
			if i == #path_parts then
				-- If it's a file, add it with the status code
				current_level[part] = status
			else
				-- If it's a directory, traverse or create a new level
				current_level[part] = current_level[part] or {}
				current_level = current_level[part]
			end
		end
	end

	local function format_tree(level, indent)
		local lines = {}

		-- Utility to determine if a directory has from a single subdirectory to extend name formatting.
		local function has_single_subdirectory(value)
			local keys = vim.tbl_keys(value)
			return #keys == 1 and type(value[keys[1]]) == "table"
		end

		for name, value in pairs(level) do
			if type(value) == "table" then
				-- Detect whether to extend the line for a directory with a single subdir.
				local sub_keys = vim.tbl_keys(value)
				if #sub_keys == 1 and type(value[sub_keys[1]]) == "table" then
					-- Extend the current line name with the subdirectory name.
					local concatenated_name = name .. "/" .. sub_keys[1]
					-- Repeat the process to see if the subdirectory itself has a single subdirectory.
					while has_single_subdirectory(value[sub_keys[1]]) do
						value = value[sub_keys[1]]
						sub_keys = vim.tbl_keys(value)
						concatenated_name = concatenated_name .. "/" .. sub_keys[1]
					end
					-- Append the final directory name and the subdirectories' lines.
					table.insert(lines, indent .. concatenated_name)
					vim.list_extend(lines, format_tree(value[sub_keys[1]], indent .. "  "))
				else
					-- A directory with multiple items gets its own line.
					table.insert(lines, indent .. name .. "/")
					vim.list_extend(lines, format_tree(value, indent .. "  "))
				end
			else
				-- File entries are added directly.
				table.insert(lines, indent .. value .. " " .. name)
			end
		end

		return lines
	end

	local tree_lines = format_tree(file_tree, "")

	local set_lines = function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, tree_lines)
		require("alien.utils").set_buffer_colors()
	end
	return set_lines
end

M.git_status = function()
	require("alien.utils").open_status_buffer(M.get_status_lines())
end

return M
