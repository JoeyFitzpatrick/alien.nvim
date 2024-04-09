local M = {}

M.status = "git status --porcelain --untracked=all"
M.stage_all = "git add -A"
M.unstage_all = "git reset"
M.stage_or_unstage_all = function()
	local status = vim.fn.system(M.status)
	for line in status:gmatch("[^\r\n]+") do
		if line:sub(1, 1) == " " and line:sub(2, 2) ~= " " then
			return M.stage_all
		end
	end
	return M.unstage_all
end

return M
