local constants = require("alien.window.status.constants")
local STATUSES = constants.STATUSES
local DATE_FORMAT = "--date=format-local:'%A, %Y/%m/%d, %I:%M %p'" -- current user's timezone

--- Run a shell command and return the output.
--- Returns the output as a single string, unless output_mode is "multiline", in which case it is returned as a list of strings.
---@param command string
---@param output_mode "singleline" | "multiline" | nil
---@return fun(): string | fun(): string[]
local function run_cmd(command, output_mode)
	return function()
		local output = nil
		if output_mode == "multiline" then
			output = vim.fn.systemlist(command)
		else
			output = vim.fn.system(command)
		end
		if vim.v.shell_error == 0 then
			return output
		end
		vim.notify(vim.v.shell_error, vim.log.levels.ERROR)
		return output_mode == "multiline" and { "" } or ""
	end
end

local M = {}

M.pull = run_cmd("git pull")
M.push = run_cmd("git push")
M.force_push = run_cmd("git push --force")
-- sort by file name
M.status = run_cmd("git status --porcelain --untracked=all | sort -k1.4", "multiline")
M.stage_all = run_cmd("git add -A")
M.unstage_all = run_cmd("git reset")
M.current_branch = run_cmd("git branch --show-current")
M.local_branches = run_cmd("git branch --list", "multiline")
-- remove the "remotes/origin/" prefix from remote branches, and remove duplicates
M.all_branches = run_cmd(
	"git branch --all --sort=-committerdate | head -n 100 | sed 's|remotes/origin/||' | awk '!seen[$0]++'",
	"multiline"
)

M.stage_or_unstage_all = function()
	local status = M.status()
	for _, line in ipairs(status) do
		if line:sub(1, 1) == " " and line:sub(2, 2) ~= " " then
			return M.stage_all()
		end
	end
	return M.unstage_all()
end

M.stage_or_unstage_file = function(status, filename)
	if status:sub(1, 1) == " " and status:sub(2, 2) ~= " " or status == STATUSES.UNTRACKED then
		return run_cmd("git add -- " .. filename)
	else
		return run_cmd("git reset HEAD -- " .. filename)
	end
end

M.commit = function(message)
	return run_cmd('git commit -m "' .. message .. '"')
end

M.file_contents = function(filename)
	return run_cmd("git show HEAD:" .. filename, "multiline")
end

M.restore_file = function(file)
	if file.status == STATUSES.UNTRACKED then
		return run_cmd("git clean -f -- " .. file.filename)
	end
	return run_cmd("git restore -- " .. file.filename)
end

M.num_commits = function(pull_or_push)
	local current_remote = vim.fn.system("git rev-parse --symbolic-full-name --abbrev-ref HEAD@{u}")
	if vim.v.shell_error == constants.NO_UPSTREAM_ERROR then
		return "0"
	end
	current_remote = current_remote:gsub("\n", "")
	local pull_command = "git rev-list --count HEAD.." .. current_remote
	local push_command = "git rev-list --count " .. current_remote .. "..HEAD"
	local command = pull_or_push == "pull" and pull_command or push_command
	local result = vim.fn.system(command)
	if vim.v.shell_error == 0 then
		return result:gsub("\n", "")
	end
	return "0"
end

M.checkout_branch = function(branch)
	return run_cmd("git switch " .. branch)
end

M.new_branch = function(existing_branch, new_branch)
	return run_cmd("git switch --create " .. new_branch .. " " .. existing_branch)
end

M.delete_remote_branch = function(branch)
	return run_cmd("git push origin --delete " .. branch)
end

M.delete_local_branch = function(branch)
	return run_cmd("git branch --delete " .. branch)
end

M.push_branch_upstream = function()
	local current_branch = M.current_branch()
	--TODO: get the remote programatically
	local current_remote = "origin"
	return "git push --set-upstream " .. current_remote .. " " .. current_branch
end

M.staged_stats = function()
	local stats = vim.fn.systemlist("git diff --staged --shortstat")[1]
	if not stats then
		return "No staged changes"
	end
	return stats
end

M.all_commits_for_file = function(filename)
	return run_cmd("git log --oneline -- " .. filename, "multiline")
end

M.file_contents_at_commit = function(commit, filename)
	return run_cmd("git show " .. commit .. ":" .. filename, "multiline")
end

M.commit_metadata = function(commit)
	return run_cmd("git show --no-patch " .. DATE_FORMAT .. " " .. commit, "multiline")
end

M.open_commit_in_github = function(commit_hash)
	return run_cmd("gh browse " .. commit_hash)
end

return M
