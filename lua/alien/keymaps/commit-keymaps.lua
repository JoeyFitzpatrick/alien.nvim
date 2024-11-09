local keymaps = require("alien.config").config.keymaps.commit
local elements = require("alien.elements")
local map_action = require("alien.keymaps").map_action
local map_action_with_input = require("alien.keymaps").map_action_with_input
local map = require("alien.keymaps").map
local commands = require("alien.actions.commands")

local extract = function()
  return require("alien.extractors.commit-extractor").extract(vim.api.nvim_get_current_line())
end

local M = {}

M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr, nowait = true }
  local alien_opts = { trigger_redraw = true }

  map(keymaps.commit_info, function()
    local commit = extract()
    if not commit then
      return
    end
    elements.float("git log -n 1 " .. commit.hash)
  end, opts)

  map_action(keymaps.revert, function(commit)
    return "git revert " .. commit.hash .. " --no-commit"
  end, alien_opts, opts)

  map(keymaps.display_files, function()
    local commit = extract()
    if not commit then
      return
    end

    local tree_cmd = "git diff-tree --no-commit-id --name-only " .. commit.hash .. " -r"
    elements.window(tree_cmd, {
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

  map_action_with_input(keymaps.reset, function(commit, reset_type)
    return "git reset --" .. reset_type .. " " .. commit.hash
  end, { prompt = "Git reset type", items = { "mixed", "soft", "hard" } }, alien_opts, opts)
end

return M
