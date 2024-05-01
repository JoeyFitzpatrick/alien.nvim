local constants = require("alien.window.status.constants")
local STATUSES = constants.STATUSES

local M = {}

M.pull = "git pull"
M.push = "git push"
M.force_push = "git push --force"
-- sort by file name
M.status = "git status --porcelain --untracked=all | sort -k1.4"
M.stage_all = "git add -A"
M.unstage_all = "git reset"
M.stage_file = "git add --"
M.unstage_file = "git reset HEAD --"
M.current_branch = "git branch --show-current"
M.current_branch_remote = "git rev-parse --symbolic-full-name --abbrev-ref HEAD@{u}"
M.local_branches = "git branch --list"
-- remove the "remotes/origin/" prefix from remote branches, and remove duplicates
M.all_branches = "git branch --all --sort=-committerdate | head -n 100 | sed 's|remotes/origin/||' | awk '!seen[$0]++'"

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
	if status:sub(1, 1) == " " and status:sub(2, 2) ~= " " or status == STATUSES.UNTRACKED then
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

M.restore_file = function(file)
	if file.status == STATUSES.UNTRACKED then
		return "git clean -f -- " .. file.filename
	end
	return "git restore -- " .. file.filename
end

M.num_commits = function(pull_or_push)
	local current_remote = vim.fn.system(M.current_branch_remote)
	if vim.v.shell_error == constants.NO_UPSTREAM_ERROR then
		return "0"
	end
	current_remote = current_remote:gsub("\n", "")
	local pull_command = "git rev-list --count HEAD.." .. current_remote
	print(pull_command)
	local push_command = "git rev-list --count " .. current_remote .. "..HEAD"
	local command = pull_or_push == "pull" and pull_command or push_command
	local result = vim.fn.system(command)
	if vim.v.shell_error == 0 then
		return result:gsub("\n", "")
	end
	return "0"
end

M.checkout_branch = function(branch)
	return "git switch " .. branch
end

M.new_branch = function(existing_branch, new_branch)
	return "git switch --create " .. new_branch .. " " .. existing_branch
end

M.delete_remote_branch = function(branch)
	return "git push origin --delete " .. branch
end

M.delete_local_branch = function(branch)
	return "git branch --delete " .. branch
end

M.push_branch_upstream = function()
	local current_branch = vim.fn.system(M.current_branch)
	--TODO: get the remote programatically
	local current_remote = "origin"
	return "git push --set-upstream " .. current_remote .. " " .. current_branch
end

M.staged_stats = function()
	local stats = vim.fn.systemlist("git diff --staged --shortstat")[1]
	print(type(stats))
	if not stats then
		return "No staged changes"
	end
	return stats
end

M.all_commits_for_file = function(filename)
	return "git log --oneline -- " .. filename
end

M.file_contents_at_commit = function(commit, filename)
	return "git show " .. commit .. ":" .. filename
end

M.open_commit_in_github = function(commit_hash)
	return "gh browse " .. commit_hash
end

return M
