local M = {}

M.remote_editor = function()
  return "'nvim --server " .. vim.v.servername .. " --remote'"
end

return M
