local keymaps = require("alien.config").config.keymaps.commit
local elements = require("alien.elements")
local action = require("alien.actions.action").action
local multi_action = require("alien.actions.action").composite_action
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local map = require("alien.keymaps").map

local M = {}

M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
  local alien_opts = { trigger_redraw = true }
  map(keymaps.commit_info, function()
    elements.float(action(function(commit)
      return "git log -n 1 " .. commit.hash
    end))
  end, opts)

  map_action(keymaps.revert, function(commit)
    return "git revert " .. commit.hash .. " --no-commit"
  end, alien_opts, opts)

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

  map_action_with_input(keymaps.reset, function(commit, reset_type)
    return "git reset --" .. reset_type .. " " .. commit.hash
  end, { prompt = "Git reset type", items = { "mixed", "soft", "hard" } }, alien_opts, opts)
end

return M
