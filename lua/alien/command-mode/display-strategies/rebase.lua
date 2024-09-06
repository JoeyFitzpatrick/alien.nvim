local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local utils = require("alien.command-mode.utils")
local elements = require("alien.elements")

local M = {}

local interactive_options = {
  "-i",
  "--interactive",
  "--edit-todo",
}

---@param cmd string
---@return DisplayStrategy
M.get_strategy = function(cmd)
  local options = utils.parse_command_options(cmd)
  if utils.overlap(options, interactive_options) then
    return DISPLAY_STRATEGIES.INTERACTIVE_REBASE
  end
  return DISPLAY_STRATEGIES.PRINT
end

local REBASE_FROM_ALIEN = false

M.open_interactive_rebase = function(cmd)
  local server_name = vim.v.servername
  local cmd_without_first_word_pattern = "^%S+%s+(.*)"
  cmd = "git -c core.editor='nvim --server "
    .. server_name
    .. " --remote' "
    .. string.match(cmd, cmd_without_first_word_pattern)
  local rebase_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(rebase_bufnr, true, { split = "right" })
  vim.api.nvim_buf_call(rebase_bufnr, function()
    REBASE_FROM_ALIEN = true
    vim.fn.termopen(cmd)
  end)
end

---@param cmd string
M.interactive_rebase = function(cmd)
  M.open_interactive_rebase(cmd)
  if not REBASE_FROM_ALIEN then
    return
  end

  local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
  vim.api.nvim_create_autocmd("WinClosed", {
    desc = "Alient git rebase",
    callback = function()
      if REBASE_FROM_ALIEN then
        local rebase_with_file_cmd = "git rebase --file=.git/REBASE_EDITMSG --cleanup=strip"
        elements.terminal(rebase_with_file_cmd, { enter = true, window = { split = "below" } })
        REBASE_FROM_ALIEN = false
        require("alien.elements.register").redraw_elements()
      end
    end,
    group = alien_status_group,
  })
end

return M
