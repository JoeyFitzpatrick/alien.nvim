---@alias AlienExtractResult LocalFile | LocalBranch | Blame | Commit | CommitFile | Stash

local M = {}

--- Get the extractor for a given object type
---@param object_type AlienObject
M._get_extractor = function(object_type)
  if not object_type then
    return
  end
  -- Example: "commit_file" -> "alien.extractors.commit-file-extractor"
  return require("alien.extractors." .. object_type:gsub("_", "-") .. "-extractor").extract
end

--- Public API for extracting git information from a string.
---@param object_type? AlienObject
---@param str? string
---@return AlienExtractResult | nil
M.extract = function(object_type, str)
  if not object_type then
    local current_element = require("alien.elements.register").get_current_element()
    if current_element then
      object_type = current_element.object_type
    end
  end
  if not object_type then
    vim.notify("Alien couldn't figure out which git extractor to use", vim.log.levels.ERROR)
    return nil
  end

  local ok, extractor = pcall(require, "alien.extractors." .. object_type:gsub("_", "-") .. "-extractor")
  if not ok then
    vim.notify("Alien couldn't figure out which git extractor to use", vim.log.levels.ERROR)
    return nil
  end

  if not str then
    str = vim.api.nvim_get_current_line()
  end
  -- Example: "commit_file" -> "alien.extractors.commit-file-extractor"
  return extractor.extract(str)
end

return M
