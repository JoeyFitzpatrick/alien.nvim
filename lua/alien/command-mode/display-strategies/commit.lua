local DISPLAY_STRATEGIES = require("alien.command-mode.constants").DISPLAY_STRATEGIES
local utils = require("alien.command-mode.utils")
local elements = require("alien.elements")

local M = {}

local print_options = {
  "-C",
  "--reuse-message",
  "--squash",
  "--long",
  "--short",
  "--porcelain",
  "-z",
  "--null",
  "-F",
  "--file",
  "-m",
  "--message",
  "--allow-empty",
  "--allow-message",
  "--no-edit",
  "--dry-run",
}

---@param cmd string
---@return DisplayStrategy
M.get_strategy = function(cmd)
  local options = utils.parse_command_options(cmd)
  if utils.overlap(options, print_options) then
    return DISPLAY_STRATEGIES.PRINT
  end
  return DISPLAY_STRATEGIES.PRINT
end

local COMMIT_FROM_ALIEN = false

M.open_interactive_commit = function(cmd)
  local server_name = vim.v.servername
  local cmd_without_first_word_pattern = "^%S+%s+(.*)"
  cmd = "git -c core.editor='nvim --server "
    .. server_name
    .. " --remote' "
    .. string.match(cmd, cmd_without_first_word_pattern)
  local commit_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(commit_bufnr, true, { split = "right" })
  vim.api.nvim_buf_call(commit_bufnr, function()
    COMMIT_FROM_ALIEN = true
    vim.fn.termopen(cmd)
  end)
end

---@param cmd string
M.interactive_commit = function(cmd)
  M.open_interactive_commit(cmd)
  if not COMMIT_FROM_ALIEN then
    return
  end

  local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
  vim.api.nvim_create_autocmd("WinClosed", {
    desc = "Alient git commit",
    callback = function()
      if COMMIT_FROM_ALIEN then
        local commit_with_file_cmd = "git commit --file=.git/COMMIT_EDITMSG --cleanup=strip"
        elements.terminal(commit_with_file_cmd, { enter = true, window = { split = "below" } })
        COMMIT_FROM_ALIEN = false
        require("alien.elements.register").redraw_elements()
      end
    end,
    group = alien_status_group,
  })
end

return M
