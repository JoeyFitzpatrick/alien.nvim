---@diagnostic disable: param-type-mismatch
local keymaps = require("alien.config").config.keymaps.commit_file
local config = require("alien.config").config.commit_file
local commands = require("alien.actions.commands")
local elements = require("alien.elements")
local translate = require("alien.translators.commit-file-translator").translate
local get_args = commands.get_args(translate)
local map = require("alien.keymaps").map

local M = {}

M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
  local translate = function()
    return require("alien.translators.commit-file-translator").translate(vim.api.nvim_get_current_line())
  end

  vim.keymap.set("n", keymaps.scroll_diff_down, function()
    local buffers = elements.register.get_child_elements({ object_type = "diff" })
    local buffer = buffers[1]
    if #buffers == 1 and buffer.channel_id then
      pcall(vim.api.nvim_chan_send, buffer.channel_id, "jj")
    end
  end, opts)
  vim.keymap.set("n", keymaps.scroll_diff_up, function()
    local buffers = elements.register.get_child_elements({ object_type = "diff" })
    local buffer = buffers[1]
    if #buffers == 1 and buffer.channel_id then
      pcall(vim.api.nvim_chan_send, buffer.channel_id, "kk")
    end
  end, opts)

  local diff_native = commands.create_command(function(commit_file)
    return "git show " .. commit_file.hash .. " -- " .. commit_file.filename
  end, get_args)

  local open_diff = function()
    local width = math.floor(vim.o.columns * 0.67)
    if vim.api.nvim_get_current_buf() == bufnr then
      ---@diagnostic disable-next-line: param-type-mismatch
      local ok, cmd = pcall(diff_native)
      if ok then
        elements.terminal(cmd, { skip_redraw = true, window = { width = width } })
      end
    end
  end

  local AUTO_DISPLAY_DIFF = config.auto_display_diff
  local set_auto_diff = function(should_display)
    AUTO_DISPLAY_DIFF = should_display
    if not AUTO_DISPLAY_DIFF then
      elements.register.close_child_elements({ object_type = "diff", element_type = "terminal" })
    else
      open_diff()
    end
  end

  local toggle_auto_diff = function()
    set_auto_diff(not AUTO_DISPLAY_DIFF)
  end

  vim.keymap.set("n", keymaps.toggle_auto_diff, toggle_auto_diff, opts)

  local ALIEN_FILENAME_PREFIX = "Alien://"
  local function get_tmp_name(hash, filename)
    return os.tmpname() .. ALIEN_FILENAME_PREFIX .. hash .. ":" .. filename
  end

  local function get_show_command(commit_file)
    return string.format("git show %s:%s", commit_file.hash, commit_file.filename)
  end

  local function set_commit_file_options(buf)
    vim.api.nvim_set_option_value("filetype", vim.filetype.match({ buf = buf }), { buf = buf })
    local set_highlight_cmd = "set winhighlight=LineNr:AlienCommitFileLineNr"
    local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
      desc = "Add linenr highlighting for commit files",
      buffer = buf,
      command = set_highlight_cmd,
      group = alien_status_group,
    })
    vim.api.nvim_create_autocmd("BufLeave", {
      desc = "Remove linenr highlighting for commit files",
      buffer = buf,
      command = "set winhighlight=",
      group = alien_status_group,
    })
    vim.cmd(set_highlight_cmd)
  end

  -- file open functions
  map(keymaps.open_in_vertical_split, function()
    set_auto_diff(false)
    local commit_file_from_action = translate()
    if not commit_file_from_action then
      return
    end
    elements.split(get_show_command(commit_file_from_action), {}, function(_, buf)
      vim.api.nvim_buf_set_name(
        0,
        ALIEN_FILENAME_PREFIX .. commit_file_from_action.hash .. "-" .. commit_file_from_action.filename
      )
      set_commit_file_options(buf)
    end)
  end, opts)

  map(keymaps.open_in_horizontal_split, function()
    set_auto_diff(false)
    local commit_file_from_action = translate()
    if not commit_file_from_action then
      return
    end
    elements.split(get_show_command(commit_file_from_action), { split_opts = { split = "above" } }, function(_, buf)
      vim.api.nvim_buf_set_name(0, commit_file_from_action.hash .. "-" .. commit_file_from_action.filename)
      set_commit_file_options(buf)
    end)
  end, opts)

  map(keymaps.open_in_tab, function()
    local commit_file_from_action = translate()
    if not commit_file_from_action then
      return
    end
    local buf = elements.tab(get_show_command(commit_file_from_action))
    vim.api.nvim_buf_set_name(0, get_tmp_name(commit_file_from_action.hash, commit_file_from_action.filename))
    set_commit_file_options(buf)
  end, opts)

  map(keymaps.open_in_window, function()
    local commit_file_from_action = translate()
    if not commit_file_from_action then
      return
    end
    local buf = elements.buffer(get_show_command(commit_file_from_action), {})
    vim.api.nvim_buf_set_name(0, get_tmp_name(commit_file_from_action.hash, commit_file_from_action.filename))
    set_commit_file_options(buf)
  end, opts)

  -- Autocmds
  local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    desc = "Diff the commit file under the cursor",
    buffer = bufnr,
    callback = function()
      if not AUTO_DISPLAY_DIFF then
        return
      end
      elements.register.close_child_elements({ object_type = "diff", element_type = "terminal" })
      if vim.api.nvim_get_current_buf() == bufnr then
        open_diff()
      end
    end,
    group = alien_status_group,
  })

  vim.api.nvim_create_autocmd("BufHidden", {
    desc = "Close open diffs when buffer is hidden",
    buffer = bufnr,
    callback = function()
      set_auto_diff(false)
    end,
    group = alien_status_group,
  })
end

return M
