local is_staged = require("alien.status").is_staged
local STATUSES = require("alien.status").STATUSES
local ERROR_CODES = require("alien.actions.error-codes")

---@alias CommandArgs LocalBranch | Commit

local M = {}

--- Create a command string or function that returns a command string.
--- If the command is a function, pass a get_args fn that returns the arguments to the command.
---@param cmd string | (fun(args?: CommandArgs): string)
---@param get_args function | nil
---@param input string | nil
M.create_command = function(cmd, get_args, input)
	if type(cmd) == "string" then
		return cmd
	end
	if not get_args then
		return cmd()
	end
	return function()
		local args = { get_args() }
		if not args or #args == 0 then
			return cmd()
		end
		table.insert(args, input)
		local unpack = unpack and unpack or table.unpack
		return cmd(unpack(args))
	end
end

--- Logic to add flags to a command string
---@param cmd string
---@param flags string
---@return string
M.add_flags = function(cmd, flags)
	local cmd_with_flags = ""
	local count = 1
	for w in string.gmatch(cmd, "%a+") do
		if count == 1 then
			cmd_with_flags = w
		else
			cmd_with_flags = cmd_with_flags .. " " .. w
		end
		if count == 2 and flags and #flags > 0 then
			cmd_with_flags = cmd_with_flags .. " " .. flags
		end
		count = count + 1
	end
	return cmd_with_flags
end

--- add flags via a UI to a command
---@param cmd string
---@return string
M.add_flags_input = function(cmd)
	local git_verb = cmd:match("%S+%s+(%S+)")
	local cmd_with_flags = ""
	vim.ui.input({ prompt = git_verb .. " flags: " }, function(input)
		cmd_with_flags = M.add_flags(cmd, input)
	end)
	return cmd_with_flags
end

--- Get the arguments to pass to create_command
---@param translate fun(string): table
---@return fun(input: string | nil): (table | fun(): table)
M.get_args = function(translate)
	return function(input)
		if input then
			return function()
				return translate(vim.api.nvim_get_current_line()), input
			end
		end
		return translate(vim.api.nvim_get_current_line())
	end
end

M.status = "git status --porcelain --untracked=all | sort -k1.4"
-- output stats for staged files, or a message if no files are staged
M.staged_stats =
	"git diff --staged --shortstat | grep -q '^' && git diff --staged --shortstat || echo 'No files staged'"
M.current_head = "printf 'HEAD: %s\n' $(git rev-parse --abbrev-ref HEAD)"
M.current_remote = "git rev-parse --symbolic-full-name --abbrev-ref HEAD@{u}"

--- Get the number of commits to pull
---@return string
M.num_commits_to_pull = function()
	local current_remote = vim.fn.system(M.current_remote)
	if vim.v.shell_error == ERROR_CODES.NO_UPSTREAM_ERROR then
		return "echo 0"
	end
	current_remote = current_remote:gsub("\n", "")
	return "git rev-list --count HEAD.." .. current_remote
end

--- Get the number of commits to push
---@return string
M.num_commits_to_push = function()
	local current_remote = vim.fn.system(M.current_remote)
	if vim.v.shell_error == ERROR_CODES.NO_UPSTREAM_ERROR then
		return "echo 0"
	end
	current_remote = current_remote:gsub("\n", "")
	return "git rev-list --count " .. current_remote .. "..HEAD"
end

return M
