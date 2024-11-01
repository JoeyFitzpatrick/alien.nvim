local elements = require("alien.elements")
local keymaps = require("alien.config").config.keymaps.local_branch
local action = require("alien.actions").action
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local map = require("alien.keymaps").map
local set_command_keymap = require("alien.keymaps").set_command_keymap
local ERROR_CODES = require("alien.actions.error-codes")

local translate = function()
  return require("alien.translators.local-branch-translator").translate(vim.api.nvim_get_current_line())
end

---@alias LocalBranch { branch_name: string }

local M = {}

M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
  local alien_opts = { trigger_redraw = true }

  map_action(keymaps.switch, function(branch)
    return "git switch " .. branch.branch_name
  end, alien_opts, opts)

  map_action_with_input(keymaps.new_branch, function(branch, new_branch_name)
    return "git switch --create " .. new_branch_name .. " " .. branch.branch_name
  end, { prompt = "New branch name: " }, alien_opts, opts)

  local delete_branch_prompt = function(delete_branch_cmd)
    vim.ui.select(
      { "yes", "no" },
      { prompt = "This branch is not fully merged. Are you sure you want to delete it?" },
      function(selection)
        if selection == "yes" then
          action(delete_branch_cmd .. " -D", alien_opts)()
        end
      end
    )
  end

  map_action_with_input(
    keymaps.delete,
    function(branch, location)
      if location == "remote" then
        return "git push origin --delete " .. branch.branch_name
      elseif location == "local" then
        return "git branch --delete " .. branch.branch_name
      end
    end,
    { items = { "local", "remote" }, prompt = "Delete local or remote: " },
    { trigger_redraw = true, error_callbacks = { [ERROR_CODES.BRANCH_NOT_FULLY_MERGED] = delete_branch_prompt } },
    opts
  )

  map_action_with_input(keymaps.rename, function(branch, new_branch_name)
    return "git branch -m " .. branch.branch_name .. " " .. new_branch_name
  end, { prompt = "Rename branch: " }, alien_opts, opts)

  map_action(keymaps.merge, function(branch)
    return "git merge " .. branch.branch_name
  end, alien_opts, opts)

  map_action(keymaps.rebase, function(branch)
    return "git rebase " .. branch.branch_name
  end, alien_opts, opts)

  map(keymaps.log, function()
    local branch = translate()
    if not branch then
      return
    end
    elements.buffer("git log " .. branch.branch_name .. " --pretty=format:'%h %cr %an ◯ %s'")
  end, opts)

  set_command_keymap(keymaps.pull, "pull", opts)
  set_command_keymap(keymaps.push, "push", opts)
end

return M
