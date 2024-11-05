local keymaps = require("alien.config").config.keymaps.blame
local elements = require("alien.elements")
local map = require("alien.keymaps").map
local map_action = require("alien.keymaps").map_action
local commands = require("alien.actions.commands")

local M = {}

local translate = function()
  return require("alien.translators.blame-translator").translate(vim.api.nvim_get_current_line())
end

M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
  local alien_opts = { trigger_redraw = true }

  map(keymaps.commit_info, function()
    local commit = translate()
    if not commit then
      return
    end
    elements.float("git log -n 1 " .. commit.hash)
  end, opts)

  map(keymaps.display_files, function()
    local commit = translate()
    if not commit then
      return
    end

    local tree_cmd = "git diff-tree --no-commit-id --name-only " .. commit.hash .. " -r"
    elements.buffer(tree_cmd, {
      output_handler = function(lines)
        local new_lines =
          require("alien.utils").run_cmd("git log " .. commit.hash .. " -n 1 --pretty=format:'%h %cr %an ◯ %s'")
        for _, line in ipairs(lines) do
          table.insert(new_lines, line)
        end
        return new_lines
      end,
    })
  end, opts)

  map_action(keymaps.copy_commit_url, function(commit)
    commands.copy_git_commit_url(commit.hash)
  end, alien_opts, opts)
end

return M
