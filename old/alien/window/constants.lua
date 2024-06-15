local M = {}

M.ALIEN_BUFFER_TYPE = "alien_buffer_type"
M.BUFFER_TYPES = {
	STATUS = "status",
	BRANCHES = "branches",
}
M.BUFFER_TYPE_ARRAY = { M.BUFFER_TYPES.STATUS, M.BUFFER_TYPES.BRANCHES }
M.BUFFER_TYPE_STRING = {
	[M.BUFFER_TYPES.STATUS] = "[Status] -- Branches",
	[M.BUFFER_TYPES.BRANCHES] = "Status -- [Branches]",
}

return M
