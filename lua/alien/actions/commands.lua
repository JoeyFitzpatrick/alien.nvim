local is_staged = require("alien.status").is_staged

local M = {}

M.status = "git status --porcelain --untracked=all | sort -k1.4"

---
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
