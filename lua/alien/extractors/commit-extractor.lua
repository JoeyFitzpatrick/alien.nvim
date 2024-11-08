local M = {}

---@alias Commit { hash: string, start: integer, ending: integer }

local function is_only_zeros(input)
  return input:match("^0*$") ~= nil
end

---@param line string
---@return string | nil
local function extract_git_hash(line)
  local pattern = "%x+" -- Pattern to match hexadecimal characters
  for match in line:gmatch(pattern) do
    if #match >= 7 and #match <= 40 then
      return match
    end
  end
  return nil
end

--- Takes a line of text and attempts to return the commit hash
---@param str string
---@return Commit | nil
M.extract = function(str)
  local first_word = str:match("%S+")
  if not first_word then
    return nil
  end
  local hash = extract_git_hash(str)
  if not hash then
    return nil
  end
  if is_only_zeros(hash) then
    vim.notify("No commit found", vim.log.levels.ERROR)
    error("no commit found")
  end
  return { hash = hash, start = 0, ending = #first_word }
end

return M
