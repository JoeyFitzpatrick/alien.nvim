local is_staged = require("alien.status").is_staged
local STATUSES = require("alien.status").STATUSES
local ERROR_CODES = require("alien.actions.error-codes")

local M = {}

--- Create a command string or function that returns a command string.
--- If the command is a function, pass a get_args fn that returns the arguments to the command.
---@param cmd string | (fun(args: LocalFile): string | nil)
---@param get_args function | nil
M.create_command = function(cmd, get_args)
	if type(cmd) == "string" then
		return cmd
	end
	if not get_args then
		return nil
	end
	return function()
		local args = get_args()
		if not args then
			return nil
		end
		return cmd(args)
	end
end

M.status = "git status --porcelain --untracked=all | sort -k1.4"
-- output stats for staged files, or a message if no files are staged
M.staged_stats =
	"git diff --staged --shortstat | grep -q '^' && git diff --staged --shortstat || echo 'No files staged'"
M.current_head = "printf 'HEAD: %s\n' $(git rev-parse --abbrev-ref HEAD)"
M.current_remote = "git rev-parse --symbolic-full-name --abbrev-ref HEAD@{u}"
M.pull = "git pull"
M.push = "git push"
M.commit = "git commit"

--- Get the number of commits to pull
---@return string
M.num_commits_to_pull = function()
	local current_remote = vim.fn.system(M.current_remote)
	if vim.v.shell_error == ERROR_CODES.NO_UPSTREAM_ERROR then
		return "0"
	end
	current_remote = current_remote:gsub("\n", "")
	return "git rev-list --count HEAD.." .. current_remote
end

--- Get the number of commits to push
---@return string
M.num_commits_to_push = function()
	local current_remote = vim.fn.system(M.current_remote)
	if vim.v.shell_error == ERROR_CODES.NO_UPSTREAM_ERROR then
		return "0"
	end
	current_remote = current_remote:gsub("\n", "")
	return "git rev-list --count " .. current_remote .. "..HEAD"
end

---@param local_file LocalFile
M.stage_or_unstage_file = function(local_file)
	local filename = local_file.filename
	local status = local_file.file_status
	if not is_staged(status) then
		return "git add -- " .. filename
	else
		return "git reset HEAD -- " .. filename
	end
end

M.stage_or_unstage_all = function(local_files)
	for _, local_file in ipairs(local_files) do
		local status = local_file.file_status
		if not is_staged(status) then
			return "git add -A"
		end
	end
	return "git reset"
end

M.restore_file = function(local_file)
	local filename = local_file.filename
	local status = local_file.file_status
	if status == STATUSES.UNTRACKED then
		return "git clean -f -- " .. filename
	end
	return "git restore -- " .. filename
end

M.diff_native = function(local_file)
	local status = local_file.file_status
	local filename = local_file.filename
	if status == STATUSES.UNTRACKED then
		return "git diff --no-index /dev/null " .. filename
	end
	return "git diff " .. filename
end

return M
