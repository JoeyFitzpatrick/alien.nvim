local create_action = require("alien.actions").create_action
local action = require("alien.actions").action
local is_staged = require("alien.status").is_staged
local elements = require("alien.elements")
local keymaps = require("alien.config").config.keymaps.local_file
local config = require("alien.config").config.local_file
local commands = require("alien.actions.commands")
local create_command = commands.create_command
local map = require("alien.keymaps").map
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local translate = require("alien.translators.local-file-translator").translate
local get_args = commands.get_args(translate)
local utils = require("alien.utils")
local STATUSES = require("alien.status").STATUSES

local M = {}

M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
  local alien_opts = { trigger_redraw = true }

  local function set_command_keymap(mapping, command)
    local alien_command_name = require("alien.config").config.command_mode_commands[1]
    vim.keymap.set("n", mapping, "<cmd>" .. alien_command_name .. " " .. command .. "<CR>", opts)
  end

  local diff_native = commands.create_command(function(local_file)
    local status = local_file.file_status
    local filename = local_file.filename
    if status == STATUSES.UNTRACKED then
      return "git diff --no-index /dev/null " .. filename
    end
    if is_staged(status) then
      return "git diff --staged " .. filename
    end
    return "git diff " .. filename
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

  map(keymaps.vimdiff, function()
    local current_file = translate(vim.api.nvim_get_current_line())
    if not current_file then
      return
    end
    set_auto_diff(false)
    local head_file_bufnr = elements.buffer(action(function(local_file)
      return "git show HEAD:" .. local_file.filename
    end, { object_type = "local_file" }))
    vim.cmd("diffthis")
    vim.cmd("rightbelow vsplit " .. current_file.raw_filename)
    vim.cmd("diffthis")
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
    vim.api.nvim_set_option_value("filetype", filetype, { buf = head_file_bufnr })
  end, opts)

  map_action(keymaps.stage_or_unstage, function(local_file)
    local filename = local_file.filename
    local status = local_file.file_status
    if not is_staged(status) then
      return "git add -- " .. filename
    else
      return "git reset HEAD -- " .. filename
    end
  end, alien_opts, opts)

  local visual_stage_or_unstage_fn = function(local_files)
    local should_stage = false
    local filenames = ""
    for _, local_file in ipairs(local_files) do
      local status = local_file.file_status
      if not is_staged(status) then
        should_stage = true
      end
      filenames = filenames .. " " .. local_file.filename
    end
    if should_stage then
      return "git add " .. filenames
    end
    return "git reset " .. filenames
  end

  vim.keymap.set(
    "v",
    keymaps.stage_or_unstage,
    create_action(
      create_command(visual_stage_or_unstage_fn, function()
        local start_line, end_line = utils.get_visual_line_nums()
        local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
        local local_files = {}
        for _, line in ipairs(lines) do
          local local_file = translate(line)
          table.insert(local_files, local_file)
        end
        return local_files
      end),
      { trigger_redraw = true }
    ),
    opts
  )

  local stage_or_unstage_all_fn = function(local_files)
    for _, local_file in ipairs(local_files) do
      local status = local_file.file_status
      if not is_staged(status) then
        return "git add -A"
      end
    end
    return "git reset"
  end

  map(
    keymaps.stage_or_unstage_all,
    create_action(
      create_command(stage_or_unstage_all_fn, function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local local_files = {}
        for _, line in ipairs(lines) do
          local local_file = translate(line)
          table.insert(local_files, local_file)
        end
        return local_files
      end),
      { trigger_redraw = true }
    ),
    opts
  )

  map_action_with_input(keymaps.restore, function(local_file, restore_type)
    local filename = local_file.filename
    local status = local_file.file_status
    if restore_type == "just this file" then
      if status == STATUSES.UNTRACKED then
        return "git clean -f -- " .. filename
      end
      return "git restore -- " .. filename
    elseif restore_type == "nuke working tree" then
      return "git reset --hard HEAD && git clean -fd"
    elseif restore_type == "hard reset" then
      return "git reset --hard HEAD"
    elseif restore_type == "mixed reset" then
      return "git reset --mixed HEAD"
    elseif restore_type == "soft reset" then
      return "git reset --soft HEAD"
    end
  end, {
    prompt = "restore type: ",
    items = { "just this file", "nuke working tree", "hard reset", "mixed reset", "soft reset" },
  }, alien_opts, opts)

  set_command_keymap(keymaps.pull, "pull")
  set_command_keymap(keymaps.push, "push")

  map(keymaps.commit, function()
    set_auto_diff(false)
    elements.terminal("git commit", { enter = true, window = { split = "right" } })
  end, opts)

  map_action_with_input(keymaps.stash, function(_, stash_name)
    return "git stash push -m " .. stash_name
  end, { prompt = "Stash name: " }, alien_opts, opts)

  map(keymaps.stash_with_flags, function()
    vim.ui.select({ "staged" }, { prompt = "Stash type:" }, function(stash_type)
      vim.ui.input({ prompt = "Stash name: " }, function(input)
        local cmd = "git stash push --" .. stash_type .. " -m " .. input
        action(cmd, alien_opts)()
      end)
    end)
  end, opts)

  map(keymaps.navigate_to_file, function()
    local filename = get_args().raw_filename
    vim.api.nvim_win_close(0, true)
    vim.api.nvim_exec2("e " .. filename, {})
  end, opts)

  -- TODO: get this prefix from config
  local command_mode_prefix = "G"
  vim.keymap.set("n", keymaps.amend, "<cmd>" .. command_mode_prefix .. " commit --amend --reuse-message HEAD<CR>")

  local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    desc = "Diff the file under the cursor",
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
