---@alias Stash { index: string, name: string, name_start: number, name_end: number }

local M = {}

--- Takes a line of text and attempts to return the stash index and name
---@param str string
---@return Stash | nil
M.translate = function(str)
	local index = string.match(str, "stash@{(%d+)}")
	local stash_name = string.match(str, ":%sOn%s[^:]+:%s(.+)")
	local start_index, end_index = string.find(str, stash_name or "")
	return { index = index, name = stash_name, name_start = start_index - 1, name_end = end_index }
end

return M
