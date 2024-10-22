local M = {}

---@alias Commit { hash: string, start: integer, ending: integer }

local function is_only_zeros(input)
  return input:match("^0*$") ~= nil
end

--- Takes a line of text and attempts to return the commit hash
---@param str string
---@return Commit | nil
M.translate = function(str)
  local first_word = str:match("%S+")
  if not first_word then
    return nil
  end
  if is_only_zeros(first_word) then
    vim.notify("No commit found", vim.log.levels.ERROR)
    error("no commit found")
  end
  return { hash = first_word, start = 0, ending = #first_word }
end

return M
