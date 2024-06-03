local floating_window = require("alien.window.floating-window")

local M = {}

M.notify = function(message)
	if type(message) ~= "string" then
		message = vim.inspect(message)
	end
	vim.notify(message)
end

--- Create a floating window with an error message
---@param lines string[]
M.notify_error = function(lines)
	local make_text_red = function(bufnr)
		vim.api.nvim_set_option_value("filetype", "error", { buf = bufnr })
	end
	floating_window.create(lines, make_text_red)
	error(table.concat(lines, "\n"))
end

return M
