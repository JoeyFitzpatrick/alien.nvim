local M = {}
M.status = function()
	require("alien.status").git_status()
end
M.setup = function(opts)
	opts = opts or {}
end
return M
