local M = {}

M.notify = function(message)
	if type(message) ~= "string" then
		message = vim.inspect(message)
	end
	vim.notify(message)
end

return M
