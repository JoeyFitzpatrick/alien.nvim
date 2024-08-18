local M = {}

---@alias Commit { hash: string, start: integer, ending: integer }

--- Takes a line of text and attempts to return the commit hash
---@param str string
---@return Commit | nil
M.translate = function(str)
  local first_word = str:match("%S+")
  if not first_word then
    return nil
  end
  return { hash = first_word, start = 0, ending = #first_word }
end

return M
