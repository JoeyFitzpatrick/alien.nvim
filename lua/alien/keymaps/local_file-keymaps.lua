local create_action = require("alien.actions.action").create_action
local action = require("alien.actions.action").action
local is_staged = require("alien.status").is_staged
local elements = require("alien.elements")
local keymaps = require("alien.config").keymaps.local_file
local commands = require("alien.actions.commands")
local create_command = commands.create_command
local map = require("alien.keymaps").map
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local translate = require("alien.translators.local-file-translator").translate
local get_args = commands.get_args(translate)
local STATUSES = require("alien.status").STATUSES

local COMMIT_FROM_ALIEN = false

local M = {}
--comment

M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
  local alien_opts = { trigger_redraw = true }
  map_action(keymaps.stage_or_unstage, function(local_file)
    local filename = local_file.filename
    local status = local_file.file_status
    if not is_staged(status) then
      return "git add -- " .. filename
    else
      return "git reset HEAD -- " .. filename
    end
  end, alien_opts, opts)
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
  map_action(keymaps.restore_file, function(local_file)
    local filename = local_file.filename
    local status = local_file.file_status
    if status == STATUSES.UNTRACKED then
      return "git clean -f -- " .. filename
    end
    return "git restore -- " .. filename
  end, alien_opts, opts)
  map_action(keymaps.pull, function()
    return "git pull"
  end, alien_opts, opts)
  map_action(keymaps.push, function()
    return "git push"
  end, alien_opts, opts)
  map_action(keymaps.pull_with_flags, function()
    return "git pull"
  end, { add_flags = true, trigger_redraw = true }, opts)
  map_action(keymaps.push_with_flags, function()
    return "git push"
  end, { add_flags = true, trigger_redraw = true }, opts)

  map(keymaps.commit, function()
    local server_name = vim.v.servername
    local cmd = "git -c core.editor='nvim --server " .. server_name .. " --remote' commit"

    local commit_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(commit_bufnr, true, { split = "right" })
    vim.api.nvim_buf_call(commit_bufnr, function()
      COMMIT_FROM_ALIEN = true
      vim.fn.termopen(cmd)
    end)
  end, opts)

  map(keymaps.commit_with_flags, function()
    local cmd = commands.add_flags_input("git commit")
    elements.terminal(cmd, { window = { split = "right" } })
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
    local filename = get_args().filename
    vim.api.nvim_win_close(0, true)
    vim.api.nvim_exec2("e " .. filename, {})
  end, opts)

  local diff_native = commands.create_command(function(local_file)
    local status = local_file.file_status
    local filename = local_file.filename
    if status == STATUSES.UNTRACKED then
      return "git diff --no-index /dev/null " .. filename
    end
    return "git diff " .. filename
  end, get_args)

  vim.keymap.set("n", keymaps.diff, function()
    elements.terminal(diff_native())
  end, opts)
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

  local alien_status_group = vim.api.nvim_create_augroup("Alien", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    desc = "Diff the file under the cursor",
    buffer = bufnr,
    callback = function()
      elements.register.close_child_elements({ object_type = "diff", element_type = "terminal" })
      local width = math.floor(vim.o.columns * 0.67)
      if vim.api.nvim_get_current_buf() == bufnr then
        ---@diagnostic disable-next-line: param-type-mismatch
        local ok, cmd = pcall(diff_native)
        if ok then
          elements.terminal(cmd, { window = { width = width } })
        end
      end
    end,
    group = alien_status_group,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    desc = "Alient git commit",
    callback = function()
      if COMMIT_FROM_ALIEN then
        vim.fn.system("git commit --file=.git/COMMIT_EDITMSG --cleanup=strip")
        COMMIT_FROM_ALIEN = false
        require("alien.elements.register").redraw_elements()
      end
    end,
    group = alien_status_group,
  })
end

return M
