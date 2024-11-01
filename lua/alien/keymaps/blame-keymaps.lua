local keymaps = require("alien.config").config.keymaps.blame
local elements = require("alien.elements")
local action = require("alien.actions").action
local multi_action = require("alien.actions").composite_action
local map = require("alien.keymaps").map
local map_action = require("alien.keymaps").map_action
local commands = require("alien.actions.commands")

local M = {}

M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
  local alien_opts = { trigger_redraw = true }
  map(keymaps.commit_info, function()
    elements.float(action(function(commit)
      return "git log -n 1 " .. commit.hash
    end))
  end, opts)

  map(keymaps.display_files, function()
    elements.buffer(multi_action({
      function(commit)
        return "git log " .. commit.hash .. " -n 1 --pretty=format:'%h %cr %an ◯ %s'"
      end,
      function(commit)
        return "git diff-tree --no-commit-id --name-only " .. commit.hash .. " -r"
      end,
    }))
  end, opts)

  map_action(keymaps.copy_commit_url, function(commit)
    commands.copy_git_commit_url(commit.hash)
  end, alien_opts, opts)
end

return M
