local M = {}

M.pull = "git pull"
M.push = "git push"
M.force_push = "git push --force"
M.status = "git status --porcelain --untracked=all"
M.stage_all = "git add -A"
M.unstage_all = "git reset"
M.stage_file = "git add --"
M.unstage_file = "git reset HEAD --"
M.current_branch = "git branch --show-current"
M.current_branch_remote = "git rev-parse --symbolic-full-name --abbrev-ref HEAD@{u}"
M.num_commits_to_pull = "git rev-list --count HEAD" .. "..$(" .. M.current_branch_remote .. ")"
M.num_commits_to_push = "git rev-list --count $(" .. M.current_branch_remote .. ")..HEAD"

M.stage_or_unstage_all = function()
	local status = vim.fn.system(M.status)
	for line in status:gmatch("[^\r\n]+") do
		if line:sub(1, 1) == " " and line:sub(2, 2) ~= " " then
			return M.stage_all
		end
	end
	return M.unstage_all
end

M.stage_or_unstage_file = function(status, filename)
	if status:sub(1, 1) == " " and status:sub(2, 2) ~= " " or status == "??" then
		return M.stage_file .. " " .. filename
	else
		return M.unstage_file .. " " .. filename
	end
end

M.commit = function(message)
	return 'git commit -m "' .. message .. '"'
end

M.file_contents = function(filename)
	return "git show HEAD:" .. filename
end

return M
