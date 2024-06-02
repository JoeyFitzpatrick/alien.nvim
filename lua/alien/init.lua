local M = {}

M.status = function()
	require("alien.window").git_status()
end
M.toggle_time_machine = function()
	require("alien.time-machine").toggle()
end
M.setup = function(opts)
	opts = opts or {}
	require("alien.colors").setup_colors()
end

return M
