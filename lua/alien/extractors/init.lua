local M = {}

--- Get the extractor for a given object type
---@param object_type AlienObject
M.get_extractor = function(object_type)
  if not object_type then
    return
  end
  -- Example: "commit_file" -> "alien.extractors.commit-file-extractor"
  return require("alien.extractors." .. object_type:gsub("_", "-") .. "-extractor").extract
end

return M
