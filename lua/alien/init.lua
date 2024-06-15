local M = {}

M.config = { test = "test" }

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

M.test = function()
	require("alien.elements").create("split", function()
		return { M.config.test }
	end)
end

return M
