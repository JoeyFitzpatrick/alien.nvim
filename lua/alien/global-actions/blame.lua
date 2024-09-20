local elements = require("alien.elements")
local action = require("alien.actions.action").action

local M = {}

M.blame = function()
  local original_win = vim.api.nvim_get_current_win()
  local current_settings = {
    scrollbind = vim.api.nvim_get_option_value("scrollbind", { win = original_win }),
    wrap = vim.api.nvim_get_option_value("wrap", { win = original_win }),
  }
  local current_line_num = vim.api.nvim_win_get_cursor(original_win)[1]
  local function setup_blame_window(win)
    vim.api.nvim_set_option_value("scrollbind", true, { win = win })
    vim.api.nvim_set_option_value("wrap", false, { win = win })
  end
  setup_blame_window(original_win)
  elements.split(
    action(function()
      return "git blame '"
        .. vim.api.nvim_buf_get_name(0)
        .. "' --date=format-local:'%Y/%m/%d %I:%M %p' | sed -E 's/ +[0-9]+\\)/)/'"
    end),
    { split = "left" },
    function(win)
      local closing_paren = string.find(vim.api.nvim_get_current_line(), ")")
      if closing_paren then
        local number_width = vim.fn.strwidth(tostring(vim.api.nvim_buf_line_count(0))) + 2
        vim.api.nvim_win_set_width(0, closing_paren + number_width)
      end
      vim.api.nvim_win_set_cursor(win, { current_line_num, 0 })
      setup_blame_window(win)
      vim.cmd("syncbind")

      local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
      vim.api.nvim_create_autocmd("WinClosed", {
        desc = "Reset original window settings",
        buffer = 0,
        callback = function()
          vim.api.nvim_win_set_cursor(original_win, vim.api.nvim_win_get_cursor(0))
          for option, value in pairs(current_settings) do
            vim.api.nvim_set_option_value(option, value, { win = original_win })
          end
        end,
        group = alien_status_group,
      })
    end
  )
end

return M
