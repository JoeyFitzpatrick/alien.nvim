local M = {}

M.STATUSES = {
	UNTRACKED = "??",
	MODIFIED_UNSTAGED = " M",
	MODIFIED_STAGED = "M ",
	ADDED = "A ",
}

M.is_valid_status = function(status)
	for _, valid_status in pairs(M.STATUSES) do
		if valid_status == status then
			return true
		end
	end
	return false
end

M.is_staged = function(status)
	local staged_statuses = {
		M.STATUSES.MODIFIED_STAGED,
		M.STATUSES.ADDED,
	}
	return staged_statuses[status] ~= nil
end

return M
