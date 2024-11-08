local M = {}

M.highlight = function(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    local stash = require("alien.extractors.stash-extractor").extract(line)
    if not stash then
      goto continue
    end
    vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienStashName", i - 1, stash.name_start, stash.name_end)
  end
  ::continue::
end

return M
