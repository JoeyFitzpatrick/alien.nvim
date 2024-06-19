local M = {}

M.STATUSES = {
	UNTRACKED = "??",
	MODIFIED_UNSTAGED = " M",
	MODIFIED_STAGED = "M ",
	MODIFIED_PARTIALLY_STAGED = "MM",
	ADDED = "A ",
	DELETED_UNSTAGED = " D",
	DELETED_STAGED = "D ",
	RENAMED_UNSTAGED = " R",
	RENAMED_STAGED = "R ",
	COPIED_UNSTAGED = " C",
	COPIED_STAGED = "C ",
	ADDED_UNSTAGED = " A",
	DELETED_BOTH_STAGED_UNSTAGED = "DD",
	ADDED_BOTH_STAGED_UNSTAGED = "AA",
	DELETED_MODIFIED_UNSTAGED = "DM",
	UNMERGED = "UU",
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
		M.STATUSES.DELETED_STAGED,
		M.STATUSES.RENAMED_STAGED,
		M.STATUSES.COPIED_STAGED,
	}
	return vim.tbl_contains(staged_statuses, status)
end

return M
