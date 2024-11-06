local M = {}

--- Add a spinner to a buffer at a given line number.
---@param bufnr integer
---@param position integer[]
M.start_spinner = function(bufnr, position)
  local spinner_chars = { "|", "/", "-", "\\" }
  local spinner_index = 1
  local timer = vim.loop.new_timer()

  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
  vim.api.nvim_buf_set_text(bufnr, position[1], position[2], position[1], position[2] + 1, { "  " })
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

  local function update_spinner()
    vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
    vim.api.nvim_buf_set_text(
      bufnr,
      position[1],
      position[2] + 1,
      position[1],
      position[2] + 2,
      { spinner_chars[spinner_index] }
    )
    vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

    spinner_index = (spinner_index % #spinner_chars) + 1
  end

  timer:start(0, 100, vim.schedule_wrap(update_spinner))

  return timer
end

M.stop_spinner = function(timer, bufnr, position)
  if timer and timer:is_active() then
    timer:stop()
    timer:close()
    pcall(vim.api.nvim_buf_set_text, bufnr, position[1], position[2], position[1], position[2] + 1, { "" })
  end
  pcall(vim.api.nvim_set_option_value, "modifiable", false, { buf = bufnr })
end

return M
