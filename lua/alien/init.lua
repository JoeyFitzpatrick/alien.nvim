local M = {}

M.config = { test = "test" }

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

M.float = function()
	require("alien.elements").float({
		get = function()
			return { "item from config", M.config.test }
		end,
	}, { border = "rounded", title = "test" })
end

M.split = function()
	require("alien.elements").split({
		get = function()
			return { "item from config", M.config.test }
		end,
	})
end

M.tab = function()
	require("alien.elements").tab({
		get = function()
			return { "item from config", M.config.test }
		end,
	})
end

M.buffer = function()
	require("alien.elements").buffer({
		get = function()
			return { "item from config", M.config.test }
		end,
	})
end

return M
