local M = {}

M = vim.tbl_extend("force", M, require("alien.translators.local-file-translator"))

return M
