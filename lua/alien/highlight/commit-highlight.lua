local M = {}

M.highlight = function(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    local commit = require("alien.translators.commit-translator").translate(line)
    if commit then
      vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienCommitHash", i - 1, commit.start, commit.ending)
      local name = line:match("^[^\t]*\t[^\t]*\t([^\t]*)")
      if name then
        local name_start, name_end = line:find(name)
        vim.api.nvim_buf_add_highlight(bufnr, -1, "AlienCommitAuthorName", i - 1, name_start - 1, name_end)
      end
    end
  end
end

return M
