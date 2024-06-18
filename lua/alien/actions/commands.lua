local is_staged = require("alien.status").is_staged

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

return M
