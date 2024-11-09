local M = {}

---@alias Blame Commit
---@return Blame | nil
M.extract = require("alien.extractors.commit-extractor").extract

return M
