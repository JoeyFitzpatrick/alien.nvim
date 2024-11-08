local M = {}

--- Takes a line of text and attempts to return the file name and status
---@param str string
---@return LocalBranch | nil
M.extract = function(str)
  local status_start = 1
  local status_end = 1
  local is_current_branch = str:sub(status_start, status_end) == "*"
  local branch_name_start = 3
  local branch_name = str:sub(branch_name_start):match("^(%S*)")
  return {
    branch_name = branch_name,
    is_current_branch = is_current_branch,
    branch_name_position = { start = branch_name_start, ending = #branch_name + 2 },
  }
end

return M
