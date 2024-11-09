local M = {}

local element_group = vim.api.nvim_create_augroup("Alien", { clear = true })
M.set_element_autocmds = function(bufnr)
  vim.api.nvim_create_autocmd({ "BufDelete", "WinClosed" }, {
    desc = "Deregister element",
    buffer = bufnr,
    callback = function()
      require("alien.elements.register").deregister_element(bufnr)
    end,
    group = element_group,
  })
end

--- Set object-type-specific autocmds
---@param bufnr integer
---@param object_type AlienObject | nil
M.set_object_autocmds = function(bufnr, object_type)
  if not object_type then
    return
  end
end

return M
